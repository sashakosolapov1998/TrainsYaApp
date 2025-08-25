//
//  ContentView.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 21/8/25.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
            testFetchStations()
            testFetchCopyright()
            testFetchSchedualBetweenStations()
            testFetchStationSchedule()
            testFetchRouteStations()
            testFetchNearestCity()
            testFetchCarrierInfo()
            testFetchAllStations()
        }
    }
}
#Preview {
    ContentView()
}
// Функция для тестового вызова API
func testFetchStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = NearestStationsService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching stations...")
            let stations = try await service.getNearestStations(
                lat: 55.7558,
                lng: 37.6176,
                distance: 25
            )
            
            print("Successfully fetched stations: \(stations)")
        } catch {
            print("Error fetching stations: \(error)")
        }
    }
}

func testFetchCopyright() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = CopyrightService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching copyright info...")
            let copyright = try await
            service.getCopyright()
            
            print("Successfully fetched copyright info: \(copyright)")
        } catch {
            print("Error fetching copyright info: \(error)")
        }
    }
}

func testFetchSchedualBetweenStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = SchedualBetweenStationsService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching SchedualBetweenStations info...")
            let schedualBetweenStations = try await
            service.getSchedualBetweenStations(
                from: "s9600213",
                to: "s9600243"
            )
            
            print("Successfully fetched SchedualBetweenStations info: \(schedualBetweenStations)")
        } catch {
            print("Error fetching schedule info: \(error)")
        }
    }
}


func testFetchStationSchedule() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = StationScheduleService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching StationSchedule info...")
            let stationSchedule = try await
            service.getStationSchedule(
                station: "s9602494")
            
            print("Successfully fetched StationSchedule info: \(stationSchedule)")
        } catch {
            print("Error fetching copyright info: \(error)")
        }
    }
}

func testFetchRouteStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = RouteStationsService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching RouteStations info...")
            let routeStations = try await
            service.getRouteStations(
                uid: "6316_0_9601368_g25_4")
            
            print("Successfully fetched routeStations info: \(routeStations)")
        } catch {
            print("Error fetching copyright info: \(error)")
        }
    }
}

func testFetchNearestCity() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = NearestCityService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching NearestCity info...")
            let nearestCity = try await
            service.getNearestCity(lat: 59.864177, lng: 30.319163)
            
            print("Successfully fetched NearestCity info: \(nearestCity)")
        } catch {
            print("Error fetching copyright info: \(error)")
        }
    }
}

func testFetchCarrierInfo() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = CarrierInfoService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching CarrierInfo info...")
            let carrierInfo = try await
            service.getCarrierInfo(code: "S7", system: "iata")
            
            print("Successfully fetched CarrierInfo info: \(carrierInfo)")
        } catch {
            print("Error fetching CarrierInfo info: \(error)")
        }
    }
}

func testFetchAllStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = AllStationsService(
                client: client,
                apikey: "e048947d-72b4-4468-982e-f0d886d06bed"
            )
            
            print("Fetching NearestCity info...")
            let allStations = try await
            service.getAllStations()
            
            print("Successfully fetched AllStations info: \(allStations)")
        } catch {
            print("Error fetching copyright info: \(error)")
        }
    }
}






