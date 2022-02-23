aws route53 list-resource-record-sets --hosted-zone-id ZWO3AS7ZABYMT --query "ResourceRecordSets[?ResourceRecords[?Value == 'amino-ingress.kube-uw2-110.shave.io'] && Type == 'CNAME'].Name" --max-items 8000 --page-size 8000 | jq . | tee ~/Downloads/bash_scripts/results.json

jq -c '.[]' results.json | egrep -v "recovery|oxalis" | jq .| tee ~/Downloads/bash_scripts/results2.json

envs=$(kubectl get ns |grep amino |awk '{print $1}')

for e in $envs;
do 
temp=$(echo "$e" | cut -d- -f4-)
status=$(curl -H "Content-Type: application/json" -H "API-Key: $ACYL_TOKEN" "https://acyl.boogies.io/v2/envs/${temp}" | jq .status;)
	if [ "$status" == '"Failure"' ] || [ "$status" == '"Destroyed"' ]
		then echo "Nothing to be added"
		else echo "$temp" >> dqa_list.txt
	fi
done

filecontent2=( `cat "results2.json" `)

for t in  "${filecontent2[@]}"
do 
temp="${t%\"}"
temp="${temp#\"}"
echo "$temp" >> temporary_list.txt
done

dqa_content=( `cat "dqa_list.txt" `)
temporary_content=( `cat "temporary_list.txt" `)

for i in "${dqa_content[@]}"
do
	for j in "${temporary_content[@]}"
	do
		if [[ $j == *"$i"* ]]
			then echo "$j" >> final_list.txt
			else echo "Nothing to be done here"
		fi
	done
done

final_content=( `cat "final_list.txt" `)

Array3=(`echo ${final_content[@]} ${temporary_content[@]} | tr ' ' '\n' | sort | uniq -u `)

for e in "${Array3[@]}"
do 
echo "$e" >> cname_list.txt
done

cname_list=( `cat "cname_list.txt" `)

for d in "${cname_list[@]}"
do 
JSON_FILE=`mktemp`

(
cat <<EOF
{
	"Comment": "Delete single record set",
	"Changes": [
		{
			"Action": "DELETE",
			"ResourceRecordSet": {
				"Name": "$d",
				"Type": "CNAME",
				"TTL": 64,
				"ResourceRecords": [
					{
						"Value": "amino-ingress.kube-uw2-110.shave.io"
					}
				]
			}
		}
	]
}
EOF
) > $JSON_FILE

echo "Deleting DNS Record set"
aws route53 change-resource-record-sets --hosted-zone-id ZWO3AS7ZABYMT --change-batch file://$JSON_FILE
echo "$d"
echo "Deleting record set ..."
echo
echo "Operation Completed."
rm $JSON_FILE
done