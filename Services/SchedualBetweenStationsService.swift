import OpenAPIRuntime
import OpenAPIURLSession

typealias SchedualBetweenStations = Components.Schemas.Segments

protocol SchedualBetweenStationsProtocol {
    func getSchedualBetweenStations(from: String, to: String) async throws -> SchedualBetweenStations
}


final class SchedualBetweenStationsService: SchedualBetweenStationsProtocol {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getSchedualBetweenStations(from: String, to: String) async throws -> SchedualBetweenStations {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to))
        return try response.ok.body.json
    }
}
