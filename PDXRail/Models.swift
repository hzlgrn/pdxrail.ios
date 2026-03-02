import CoreLocation
import SwiftUI

struct RailStop: Codable, Identifiable, Hashable {
    let uniqueid: String
    let station:  String?
    let line:     String?
    let type:     String    // "MAX", "CR", "SC"
    let lat:      Double
    let lon:      Double

    var id: String { uniqueid }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var isMAX:       Bool { type == Domain.RailSystem.stopMAX }
    var isStreetcar: Bool { type == Domain.RailSystem.stopStreetcar }
    var isCommuter:  Bool { type == Domain.RailSystem.stopCommuter }

    var markerSystemImage: String { isStreetcar ? "StreetcarMarkerStop.png" : "RailSystemMarkerStop.png" }
}

struct PolylinePoint: Codable {
    let a: Double   // latitude
    let o: Double   // longitude
}

struct RailLine: Codable, Identifiable {
    let line:     String
    let passage:  String
    let type:     String
    let polyline: [PolylinePoint]

    var id: String { UUID().uuidString }
}

struct PolylineStroke: Codable, Identifiable {
    let red: Double
    let green: Double
    let blue: Double
    let line:     String
    let passage:  String
    let type:     String
    let polyline: [PolylinePoint]
    var pattern: [Float] = [9,0]
    var id: String { UUID().uuidString }
    
    var lineWidth: CGFloat { type == Domain.RailSystem.stopStreetcar ? 2 : 3 }
    var coordinates: [CLLocationCoordinate2D] {
        polyline.map { CLLocationCoordinate2D(latitude: $0.a, longitude: $0.o) }
    }
}

struct RailStopsData: Codable {
    let version:    Int
    let rail_stops: [RailStop]
}

struct RailLinesData: Codable {
    let version:    Int
    let rail_lines: [RailLine]
}

struct ArrivalItem: Identifiable {
    let id:        String
    let shortSign: String
    let scheduled: Date
    let estimated: Date?
    let isLate:    Bool
    let isEarly:   Bool
    let lineColor: Color
    let vehicle:   VehiclePosition?
}


struct VehiclePosition: Identifiable {
    let id:         String
    let coordinate: CLLocationCoordinate2D
    let heading:    Int
    let lineColor:  Color
    let shortSign:  String
}

enum MapDisplayStyle: String, CaseIterable, Identifiable {
    case standard  = "Standard"
    case satellite = "Satellite"
    case hybrid    = "Hybrid"

    var id: String { rawValue }
    var systemImage: String {
        switch self {
        case .standard:  return "map"
        case .satellite: return "globe"
        case .hybrid:    return "map.circle.fill"
        }
    }
}
