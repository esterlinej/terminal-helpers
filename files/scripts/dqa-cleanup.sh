acylhost="acyl.shave.io"
envs=$(kubectl get ns |grep nitro |awk '{print $1}')
for e in $envs;
  do
    temp=$(echo "$e" |cut -d- -f3-)
    status=$(curl -H "Content-Type: application/json" -H "API-Key: $ACYL_TOKEN" "https://${acylhost}/v2/envs/${temp}" |jq .status;)
	  if [ "$status" == '"Failure"' ] || [ "$status" == '"Destroyed"' ]
		  then echo $(kubectl delete ns $e)
		  else echo "Will not delete: $e"
	  fi
  done