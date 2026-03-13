import Foundation
import OSLog

let logger = Logger(subsystem: "com.pdxrail.ios", category: "Network")

struct RailSystemService {
    private let baseURL: URL
    private let apiKey:  String

    init(baseURL: URL = URL(string: Config.railSystemUrl) ?? { fatalError("Invalid or missing RAIL_SYSTEM_URL in Config.xcconfig") }(),
         apiKey:  String = Config.railSystemKey) {
        self.baseURL = baseURL
        self.apiKey  = apiKey
    }

    func fetchStops(
        lat: Double,
        lon: Double,
        radiusInFeet: Int,
        isStreetcar: Bool,
    ) async throws -> StopsResponse {
        logger.debug("fetchStops(\(lat), \(lon))")
        let url = try buildURL(path: "ws/V1/stops", extra: [
            URLQueryItem(name: "feet",     value: "\(radiusInFeet)"),
            URLQueryItem(name: "ll",       value: "\(lat),\(lon)"),
            URLQueryItem(name: "streetcar", value: isStreetcar ? "true" : "false"),
        ])
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(StopsResponse.self, from: data)
    }

    func fetchArrivals(locIds: [Int], isStreetcar: Bool) async throws -> ArrivalsResponse {
        let url = try buildURL(path: "ws/V2/arrivals", extra: [
            URLQueryItem(name: "locIDs",      value: locIds.map(String.init).joined(separator: ",")),
            URLQueryItem(name: "streetcar",   value: isStreetcar ? "true" : "false"),
            URLQueryItem(name: "showPosition", value: "true"),
        ])
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ArrivalsResponse.self, from: data)
    }

    private func buildURL(path: String, extra: [URLQueryItem]) throws -> URL {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "appID", value: apiKey),
            URLQueryItem(name: "json",  value: "true"),
        ] + extra
        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }
}
