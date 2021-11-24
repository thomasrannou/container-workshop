# general
$location = "francecentral"
$aksrg = "rg-workshop"

# Nom du cluster AKS
$aks = "aksdemoworkshop"

# Nom de l'Azure Container Registry
$registry = "acrworkshopdevcongalaxy"

# Id de la registry
$registryId=$(az acr show --name $registry --resource-group $aksrg --query "id" --output tsv)

# Création du cluster AKS avec zone de disponibilité
az aks create --name $aks --resource-group $aksrg --attach-acr $registryId --generate-ssh-keys --load-balancer-sku standard --node-count 3 --zones 1 2 3 
    
# Récupération de l'id du cluster AKS
$aks_resourceId = $(az aks show -n $aks -g $aksrg --query id -o tsv)

# En attente du déploiement
az resource wait --exists --ids $aks_resourceId