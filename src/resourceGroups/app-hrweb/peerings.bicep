param config object

param useRemoteGateways bool = false

resource spokes 'Microsoft.Network/virtualNetworks@2021-05-01' existing = [for (target, i) in config.spokes._peerToHub: {
  name: config.spokes[target].name
}]

resource peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = [for (target, i) in config.spokes._peerToHub: {
  name: '${toUpper(last(split(spokes[i].id,'/')))}-to-${toUpper(last(split(config.hub.id,'/')))}'
  parent: spokes[i]
  properties: {
    remoteVirtualNetwork: {
      id: config.hub.id
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    useRemoteGateways: useRemoteGateways
  }
}]
