#!/bin/bash

# This script is used to create/renew certs for an openVPN server.
# Dependencies: AWS CLI, nginx, jq, openvpnas

mydomainemail = "user@mydomain.com"

echoerr() {
    echo "ERROR - $(date): $@" 1>&2
}

echoinfo() {
    echo "INFO - $(date): $@"
}

applycert() {
    echoinfo "applying cert"
    echoinfo "stopping VPN server..."
    sudo systemctl stop openvpnas
    sudo systemctl stop nginx
    sleep 10

    echoinfo "Processing cert, creating cs.ca_bundle, cs.priv_key, cs.cert files..."

    if ! sudo /usr/local/openvpn_as/scripts/confdba -mk cs.ca_bundle -v "$(sudo cat /etc/letsencrypt/live/${HOSTNAME}/fullchain.pem)" >/dev/null; then
        echoerr "Failed to import cs.ca_bundle"
    fi

    if ! sudo /usr/local/openvpn_as/scripts/confdba -mk cs.priv_key -v "$(sudo cat /etc/letsencrypt/live/${HOSTNAME}/privkey.pem)" >/dev/null; then
        echoerr "Failed to import cs.priv_key"
    fi

    if ! sudo /usr/local/openvpn_as/scripts/confdba -mk cs.cert -v "$(sudo cat /etc/letsencrypt/live/${HOSTNAME}/cert.pem)" >/dev/null; then
        echoerr "Failed to import cs.cert"
    fi

    sleep 10

    echoinfo "Scripts are processed."
    sudo systemctl start openvpnas
}

days_valid=$(sudo certbot certificates | grep "Certificate Name: ${HOSTNAME}" -A 4 | grep Expiry | awk '{print $6}')

if [ "${days_valid}" == "EXPIRY)" ]; then
    echoinfo "Certificate expired. Renewing it."
    command_type="renew"
elif [ "${days_valid}" -lt 30 ]; then
    echoinfo "Certificate valid for ${days_valid}. Renewing it."
    command_type="renew"
elif [[ "${days_valid}" == "" ]]; then
    echoinfo "No certificate found. Creating it."
    command_type="create"
else
    echoinfo "Certificate is valid for ${days_valid} days. No certificate to renew.".
    echoinfo "Verifying live certificate"

    certificate_file=$(mktemp)

    echo -n | openssl s_client -servername "localhost" -connect "localhost":943 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${certificate_file}
    date=$(openssl x509 -in ${certificate_file} -enddate -noout | sed "s/.*=\(.*\)/\1/")
    date_s=$(date -d "${date}" +%s)
    now_s=$(date -d now +%s)
    date_diff=$(( (date_s - now_s) / 86400 ))

    if [[ ${date_diff} < ${days_valid} ]]; then
        echoinfo "Letsencrypt certificate newer than running certificate. Applying it"
        applycert
        exit 0
    else
        exit 0
    fi
fi


VPN_SECURITY_GROUP=$(curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/`cat /sys/class/net/eth0/address`/security-group-ids | awk 'NR==1{print $1}')
AWS_REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document/ | jq -r .region)

if [[ ${VPN_SECURITY_GROUP} == "" ]] || [[ ${AWS_REGION} == "" ]]; then
    echoerr "Failed to identify metadata for the VPN certificate renewal process. Found \"${VPN_SECURITY_GROUP}\" security group. Found \"${AWS_REGION}\ region."
    exit 1
fi

if aws ec2 authorize-security-group-ingress --group-id "${VPN_SECURITY_GROUP}" --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0}]' --region "${AWS_REGION}"; then
    echoinfo "Opened \"${VPN_SECURITY_GROUP}\" port 80."
else
    echoerr "Failed to open port 80 on security group \"${VPN_SECURITY_GROUP}\". Continuing attempt..."
fi

closesg() {
    if aws ec2 revoke-security-group-ingress --group-id "${VPN_SECURITY_GROUP}" --ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0}]' --region "${AWS_REGION}"; then
        echoinfo "Closed port 80 on \"${VPN_SECURITY_GROUP}\""
    else
        echoerr "Failed to close port 80 on security group \"${VPN_SECURITY_GROUP}\"."
    fi

}

# copy current certs incase something goes wrong and they are overwritten with an invalid cert
mkdir -p "/home/openvpnas/.secrets/openvpn/"
sudo cp -rf "/usr/local/openvpn_as/etc/web-ssl" "/home/openvpnas/.secrets/openvpn/"

sudo systemctl start nginx
if [[ ${command_type} == "renew" ]]; then
    echoinfo "running certbot renew..."
    if sudo /usr/bin/certbot renew; then
        echoinfo "cert renewed..."
    else
        echoerr "certbot renew failed."
        closesg
        exit 1
    fi
elif [[ ${command_type} == "create" ]]; then
    echoinfo "running certbot create..."
    if sudo /usr/bin/certbot certonly --nginx -d "${HOSTNAME}" -n --agree-tos --email "${mydomainemail}"; then
        echoinfo "New cert created"
    else
        echoerr "Failed to create certificate."
        closesg
        exit 1
    fi
fi
sudo systemctl stop nginx

applycert
exit 0
