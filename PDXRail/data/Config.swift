import Foundation

enum Config {
    static let railSystemUrl = Bundle.main.infoDictionary?["RAIL_SYSTEM_URL"] as? String ?? ""
    static let railSystemKey     = Bundle.main.infoDictionary?["RAIL_SYSTEM_KEY"] as? String ?? ""
}
