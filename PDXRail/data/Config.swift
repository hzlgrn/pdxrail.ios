import Foundation

enum Config {
    static let apiBaseURL = Bundle.main.infoDictionary?["RAIL_SYSTEM_URL"] as? String ?? ""
    static let apiKey     = Bundle.main.infoDictionary?["RAIL_SYSTEM_KEY"] as? String ?? ""
}
