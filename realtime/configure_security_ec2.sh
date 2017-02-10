#!/bin/bash

THISHOSTIP=$(nslookup $HOSTNAME | grep Address | tail -n 1 | cut -d' ' -f2)
echo Host: ${HOSTNAME} / ${THISHOSTIP}

#!/bin/bash

USR=ubuntu


echo
echo Note: configure your AWS_ACCESS_KEY and AWS_SECRET_KEY environment variables first!
echo

echo
echo Reading list of EC2 regions for ec2_regions
echo

echo Creating security policies:
rm -f servers_public_tmp
for REGION in `cat ec2_regions`
do
    echo Region: $REGION
    export EC2_URL=https://ec2.${REGION}.amazonaws.com
    ec2-describe-instances | grep 'running' | cut -d$'\t' -f 17 >> servers_public_tmp
done
echo Found `cat servers_public_tmp`

for REGION in `cat ec2_regions`
do
    aws ec2 --region $REGION authorize-security-group-ingress --group-name default --protocol all --cidr ${THISHOSTIP}/32
    for PUBIP in `cat servers_public_tmp`
    do
	aws ec2 --region $REGION authorize-security-group-ingress --group-name default --protocol all --cidr ${PUBIP}/32
    done
done

rm servers_public_tmp
