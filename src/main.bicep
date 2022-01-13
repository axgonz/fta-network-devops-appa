targetScope = 'subscription'

@allowed([
  'dev'
  'prd'
])
param environment string = 'dev'

var configText = loadTextContent('./main.config.json')
var configInit = json(configText)

var location = deployment().location

// Get the short location and update place holders in config
var shortLocation = configInit.regionPrefixLookup[location]
var configText_ = replace(configText,'\${shortLocation}','${shortLocation}')

// Get the needed octets to handle different address spaces for each region
var regionAddressPrefix = configInit.addressPrefixLookup[location]
var octet1 = int(split(regionAddressPrefix, '.')[0])
var octet2 = int(split(regionAddressPrefix, '.')[1])
var configText__ = replace(replace(configText_,'\${octet1}','${octet1}'),'\${octet2}','${octet2}')

var config = json(configText__)

// Create app resource groups and update the deployment
resource rgAppHrWeb 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${shortLocation}-app-hrweb'
  location: location
}

module depAppHrWeb 'resourceGroups/app-hrweb/network.bicep' = {
  name: '${rgAppHrWeb.name}-network'
  scope: rgAppHrWeb
  params: {
    config: config
    environment: environment
  }
}

module depCoreNetPeerings 'resourceGroups/app-hrweb/peerings.bicep' = {
  name: '${rgAppHrWeb.name}-peerings'
  scope: rgAppHrWeb
  params: {
    config: config
    useRemoteGateways: false
  }  
  dependsOn: [
    depAppHrWeb
  ]
} 

output vnetId_spoke1 string = depAppHrWeb.outputs.vnetId_spoke1
