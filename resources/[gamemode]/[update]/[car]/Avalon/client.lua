function replaceModel()
txd = engineLoadTXD('car.txd',445)
engineImportTXD(txd,445)
dff = engineLoadDFF('car.dff',445)
engineReplaceModel(dff,445)
end
addEventHandler ( 'onClientResourceStart', getResourceRootElement(getThisResource()), replaceModel)
addCommandHandler ( 'reloadcar', replaceModel )