import CoreLocation

struct StopsResponse: Codable {
    let resultSet: ResultSet

    struct ResultSet: Codable {
        let location: [Location]?
    }

    struct Location: Codable {
        let locid: Int
        let desc:  String?
        let lat:   Double
        let lng:   Double
        let dir:   String?
    }
}

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

struct ArrivalsResponse: Codable {
    let resultSet: ResultSet

    struct ResultSet: Codable {
        let arrival:  [Arrival]?
        let location: [Location]
    }

    struct Arrival: Codable {
        let id:            String
        let scheduled:     Int64
        let estimated:     Int64?
        let shortSign:     String?
        let fullSign:      String
        let dir:           Int
        let locid:         Int
        let status:        String
        let blockPosition: BlockPosition?
        let detoured:      Bool
        let departed:      Bool?
    }

    struct BlockPosition: Codable {
        let lat:         Double
        let lng:         Double
        let heading:     Int
        let routeNumber: Int
        let signMessage: String?
    }

    struct Location: Codable {
        let locid: Int?
        let desc:  String?
        let lat:   Double
        let lng:   Double
    }
}
