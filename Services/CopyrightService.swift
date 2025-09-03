import OpenAPIRuntime
import OpenAPIURLSession

typealias Copyright = Components.Schemas.Copyright

protocol CopyrightProtocol {
  func getCopyright() async throws -> Copyright
}


final class CopyrightService: CopyrightProtocol {
    
  private let client: Client
  private let apikey: String
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
    
    func getCopyright() async throws -> Copyright {
        let response = try await client.getCopyright(query:
        .init(apikey: apikey
             ))
        return try response.ok.body.json
    }
}


