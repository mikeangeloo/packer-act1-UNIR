#!/bin/sh

set -e

#Función para hacer deploy a AWS
deploy_aws() {
  #Obteniendo el ultimo uuid ejectuado de aws_output.json
  INSTANCE=$(cat aws_output.json | jq '.last_run_uuid')
  echo $INSTANCE

  #Obteniendo el ami_id del archivo aws_output.json
  AMI_ID=$(cat aws_output.json | jq -r '.builds | .[] | select(.packer_run_uuid == '${INSTANCE}').artifact_id | split(":") | .[1]')
  echo $AMI_ID

  #Creando instancia con el ami_id obtenido previamente
  CREATE_EC2_INSTANCE=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro --key-name keypair-packer-demo --security-group-ids sg-031af4c31a26892f2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=PackerDemoTest}]")
  echo "INSTANCIA AWS EC2 INICIADA: $CREATE_EC2_INSTANCE"
}

#Función para hacer deploy a AZURE
deploy_azure() {
  #Obteniendo el ultimo uuid ejectuado de az_output.json
  INSTANCE=$(cat az_output.json | jq '.last_run_uuid')
  echo $INSTANCE

  #Obteniendo el ami_id del archivo az_output.json
  AZ_DATA=$(cat az_output.json | jq -r '.builds | .[] | select(.packer_run_uuid == '${INSTANCE}').artifact_id | split("/")' | jq '.[1:]' | jq '. as $array | reduce range(0; length / 2) as $i ({}; . + { ($array[2*$i]): $array[2*$i + 1] })')
  echo $AZ_DATA

  RESOURCE_GROUP=$(echo "$AZ_DATA" | jq -r '.resourceGroups')
  IMAGE_NAME=$(echo "$AZ_DATA" | jq -r '.images')
  VM_SIZE="Standard_B1s"
  VM_NAME="packerAct1-UNIR"

  #Creando instancia con la inforamción previa
  CREATE_AZ_INSTANCE=$(
    az vm create \
      --resource-group $RESOURCE_GROUP \
      --name $VM_NAME \
      --image $IMAGE_NAME \
      --size $VM_SIZE \
      --admin-username azureuser \
      --generate-ssh-keys
  )

  OPEN_INTANCE_PORTS=$(
    az vm open-port \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --port 80,443,3000
  )
  echo "INSTANCIA AZ INICIADA: $CREATE_AZ_INSTANCE"
  echo "PUERTOS ABIERTOS: $OPEN_INTANCE_PORTS"
}

# script
if [ "$1" == "aws" ]; then
  deploy_aws
elif [ "$1" == "azure" ]; then
  deploy_azure
else
  echo "Usage: $0 {aws|azure}"
  exit 1
fi
