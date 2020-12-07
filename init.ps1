param (
    [parameter(Mandatory=$false)] 
    $force = $false,

    [parameter(Mandatory=$false)] 
    $name = "test2"
)

$subscriptionName = "XXX"

# login and set subscription
az login --username "a@b.com"
az account set --subscription $subscriptionName

$location= "AustraliaSouthEast"
$namePrefix = "team-interviewtest"
$owner = "team"

$resourceGroupName = "$namePrefix-$name-rg"

$sqlServerName = "$namePrefix-$name-sql"
$sqlUsername = "$name-admin"
$sqlPassword = ""

$sqlDbName = "$namePrefix-$name-db"

$sqlAcrName = "$namePrefix-$name-acr" -replace "-", ""


function CreateContainerRegistry()
{
    Write-Output "Container Registry $sqlAcrName"

    $resource = (az acr show --name $sqlAcrName)
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az acr delete --name $sqlAcrName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az acr create --name $sqlAcrName  --resource-group $resourceGroupName --sku Basic --admin-enabled)
    }

    $acrloginserver=(az acr show --name $resource --query loginServer)
    write-Output "Login server $acrloginserver"

    Write-Output $resource
}


function AddSqlFirewallRule()
{
    $myClientIp = ((Invoke-WebRequest -uri "http://ifconfig.me/ip").Content)
    Write-Output "Adding Client Ip Address $myClientIp to Sql Server Firewall"
    az sql server firewall-rule create --name "$env:ComputerName." --server $sqlServerName --resource-group $resourceGroupName --start-ip-address=$myClientIp --end-ip-address=$myClientIp
}

function CreateSqlDb()
{
    Write-Output "Sql Db $sqlDbName"

    $resource = (az sql db show --name $sqlDbName --server $sqlServerName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az sql db delete --name $sqlDbName  --server $sqlServerName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az sql db create --name $sqlDbName  --server $sqlServerName  --resource-group $resourceGroupName --family Gen5 --edition "GeneralPurpose" --compute-model "Serverless" --capacity 1 --max-size "1GB")
    }

    Write-Output $resource
}

function CreateSqlServer()
{
    Write-Output "Sql Db $sqlServerName"

    $resource = (az sql server show --name $sqlServerName --resource-group $resourceGroupName )
    if ($force -and $resource) {
        Write-Output "exists. deleting"
        az sql server delete --name $sqlServerName  --resource-group $resourceGroupName
        $resource = $null
    } 

    if (!$resource) {
        Write-Output "doesn't exist. creating"
        $resource = (az sql server create --name $sqlServerName --resource-group $resourceGroupName --admin-password $sqlPassword --admin-user $sqlUsername --assign-identity --location $location)
    }

    Write-Output $resource
}

function CreateResourceGroup()
{
    Write-Output "Resource Group $resourceGroupName"

    $resourceGroup = (az group show --name $resourceGroupName)
    if ($force -and $resourceGroup) {
        Write-Output "exists. deleting"
        az group delete --name $resourceGroupName
        $resourceGroup = $null
    } 

    if (!$resourceGroup) {
        Write-Output " doesn't exist. creating"
        $resourceGroup = (az group create --name $resourceGroupName --tags Owner=$owner --location $location)
    }

    Write-Output $resourceGroup
}

CreateResourceGroup
CreateSqlServer
CreateSqlDb
AddSqlFirewallRule
CreateContainerRegistry
