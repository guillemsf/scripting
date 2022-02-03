#/bin/bash


region=eu-west-1
rrsetout=file.json
hostzoneid={.......}
instanceid=`aws ec2 describe-instances --filters "Name=tag:Name,Values=THE_TAG_OF_INSTANCE" --query 'Reservations[*].Instances[*].InstanceId' --output text`

#echo $instanceid

check_status(){
state=`aws ec2 describe-instances --region $region --filters "Name=tag:Name,Values=THE_TAG_OF_INSTANCE" --query 'Reservations[*].Instances[*].State.Name' --output text`
echo "Instance state is" . $state
}

start_instance(){
if [ "$state" = "stopped" ]; then 
aws ec2 start-instances --instance-ids $instanceid
fi
}

get_public_ip(){
publicdns=`aws ec2 describe-instances --region $region --filters "Name=tag:Name,Values=THE_TAG_OF_INSTANCE" --query 'Reservations[*].Instances[*].PublicDnsName' --output text`
echo $publicdns
}

get_dns_ip(){
get_dns=`aws route53 list-resource-record-sets --hosted-zone-id $hostzoneid --query "ResourceRecordSets[?Name == 'domain_to_change.com.'].ResourceRecords[*]" --output text`
echo $get_dns
}

create_file_update_dns(){
/bin/sed s/VALUE_RECORD/$publicdns/ files/openbravo.json > files/$rrsetout
aws route53 change-resource-record-sets --hosted-zone-id $hostzoneid --change-batch file://$rrsetout
}

check_status
start_instance
sleep 30
get_public_ip
create_file_update_dns
#get_dns_ip
echo "Instance started and DNS updated"
