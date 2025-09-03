
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias AllStations = Components.Schemas.AllStationsResponse

protocol AllStationsProtocol {
    func getAllStations() async throws -> AllStations
}

final class AllStationsService: AllStationsProtocol {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(query: .init(apikey: apikey))
        
        let responseBody = try response.ok.body.html
        
        let limit = 50 * 1024 * 1024
        let fullData = try await Data(collecting: responseBody, upTo: limit)

        do {
            let allStations = try JSONDecoder().decode(AllStations.self, from: fullData)
            return allStations
        } catch {
            print("Ошибка декодирования JSON: \(error)")
            if let jsonString = String(data: fullData, encoding: .utf8) {
                print("Содержимое ответа:\n\(jsonString.prefix(500))...")
            }
            throw error
        }
        
        let allStations = try JSONDecoder().decode(AllStations.self, from: fullData)
        
        return allStations
    }
}
