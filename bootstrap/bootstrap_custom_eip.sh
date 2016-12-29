source /usr/lib/hustler/bin/qubole-bash-lib.sh
is_master=`nodeinfo is_master`

#Update EIP only for master node  
if [[ "$is_master" == "1" ]]; then
	#Input Parameters
	export EIP_ALLOCATION_ID='${Allocation IP of the Elastic IP}'
	export AWS_ACCESS_KEY='${Your AWS Access Key}'
	export AWS_SECRET_KEY='${Your AWS Secret Key}'
	
	#Install ec2-net-utils
	yum  -y install ec2-net-utils

	#Install ec2-api-tools
	wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
	unzip ec2-api-tools.zip -d /usr/lib
	export EC2_HOME=/usr/lib/ec2-api-tools-1.7.5.1
	export PATH=$PATH:$EC2_HOME/bin

	#Get Instance ID
	Ec2InstanceId=$(/opt/aws/bin/ec2-metadata --instance-id | head -1 | cut -d " " -f 2);
	echo $Ec2InstanceId

	if [[ $Ec2InstanceId != "" ]]; then
		#Get network interface ID
		NetworkInterfaceId=$(ec2-describe-network-interfaces --filter "attachment.instance-id=$Ec2InstanceId" | grep NETWORKINTERFACE | head -1 | cut -f 2);
		echo $NetworkInterfaceId

		if [[ $NetworkInterfaceId != "" ]]; then
			#Assign private IP
			ec2-assign-private-ip-addresses --network-interface $NetworkInterfaceId --secondary-private-ip-address-count 1
		
			#Wait for 5 seconds, or ec2-net-utils might not be able to detect the secondary IP.
			sleep 5
			service network restart

			#Associate Elastic Ip
			SecondaryIp=$(ip addr li | grep secondary  | grep -o '10.*/' | sed 's/\///g')
			if [[ $SecondaryIp != "" ]]; then
				#Update file /etc/sysconfig/network-scripts/ifcfg-eth0:0
				cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0:0
				sed -i 's/eth0/eth0\:0/g' /etc/sysconfig/network-scripts/ifcfg-eth0\:0
				sed -i 's/dhcp/none/g' /etc/sysconfig/network-scripts/ifcfg-eth0\:0
				echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-eth0\:0
				echo "IPADDR="$SecondaryIp >> /etc/sysconfig/network-scripts/ifcfg-eth0\:0
				ec2-associate-address --allocation-id $EIP_ALLOCATION_ID  --instance $Ec2InstanceId --private-ip-address $SecondaryIp
			fi
		fi
	fi
fi
