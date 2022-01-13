// Resource declaration in Bicep
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/resource-declaration

param config object

@allowed([
  'dev'
  'prd'
])
param environment string = 'dev'

// Determine the location based on the resource group
var location = resourceGroup().location
var shortLocation = config.regionPrefixLookup[location]

// Azure policy is making sure this exact NSG is being used at deployment time  
resource nsg_spokeTemplate 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: '${shortLocation}-spoke-vnet-nsg'
  scope: resourceGroup('${shortLocation}-core-net')
}

// Azure policy is making sure this exact RT is being used at deployment time
resource rt_spokeTemplate 'Microsoft.Network/routeTables@2021-05-01' existing = {
  name: '${shortLocation}-spoke-vnet-rt'
  scope: resourceGroup('${shortLocation}-core-net')
}

// Create hub virtual network
resource vnet_spoke1 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  location: location
  name: '${config.spokes.spoke1.name}'
  properties: {
    addressSpace: {
      addressPrefixes: [
        config.spokes.spoke1.prefix[environment]
      ]
    }
    subnets: [
      {
        name: config.spokes.spoke1.subnet1.name
        properties: {
          addressPrefix: config.spokes.spoke1.subnet1.prefix[environment]
          networkSecurityGroup: {
            id: nsg_spokeTemplate.id
          }
          routeTable: {
            id: rt_spokeTemplate.id
          }
        }
      }
      {
        name: config.spokes.spoke1.subnet2.name
        properties: {
          addressPrefix: config.spokes.spoke1.subnet2.prefix[environment]
          networkSecurityGroup: {
            id: nsg_spokeTemplate.id
          }
          routeTable: {
            id: rt_spokeTemplate.id
          }
        }
      }
      {
        name: config.spokes.spoke1.subnet3.name
        properties: {
          addressPrefix: config.spokes.spoke1.subnet3.prefix[environment]
          networkSecurityGroup: {
            id: nsg_spokeTemplate.id
          }
          routeTable: {
            id: rt_spokeTemplate.id
          }
        }
      }
    ]
  }
}

output vnetId_spoke1 string = vnet_spoke1.id
