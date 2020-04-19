import GCDWebServer

extension GCDWebServer {

    func addDefaultHandler(
        forMethod method: String,
        processBlock block: @escaping GCDWebServerProcessBlock
    ) {
        addDefaultHandler(forMethod: method,
                          request: GCDWebServerRequest.self,
                          processBlock: block)
    }

    func addDefaultHandler(
        forMethod method: String,
        asyncProcessBlock block: @escaping GCDWebServerAsyncProcessBlock
    ) {
        addDefaultHandler(forMethod: method,
                          request: GCDWebServerRequest.self,
                          asyncProcessBlock: block)
    }

}
