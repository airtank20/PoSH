
#get the credentials from the user
$creds = Get-Credential

$resourceGroup = "CLIDemo"
$srvName = "myCLIDemo"

az group create --name $resourceGoup --location eastus

# use az vm image list -f --publisher MicrosoftSQLServer --all to find the list of images.  Use the URN value as the image name
az vm create `
    --resource-group $resourceGroup `
    --name $srvName `
    --image MicrosoftSQLServer:SQL2017-WS2016:SQLDEV:14.0.1000204 `
    --admin-username $($creds.GetNetworkCredential().UserName) `
    --admin-password $($creds.GetNetworkCredential().Password) `
    --size Standard_A5 `
    --storage-sku Standard_LRS


#stop the VM
#az vm stop --resource-group $ResourceGroup --name $srvName

#destroy the VM
#az group delete --name $ResourceGroup --yes

