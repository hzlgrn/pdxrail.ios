import CoreLocation

enum Domain {
    enum Camera {
        static let defaultLatitude  = 45.5231
        static let defaultLongitude = -122.6765
        static let defaultSpanDelta = 0.015
    }

    enum RailSystem {
        // Stop type discriminators
        static let stopMAX       = "MAX"
        static let stopCommuter  = "CR"
        static let stopStreetcar = "SC"

        // MAX line codes
        static let maxBlue   = "B"
        static let maxGreen  = "G"
        static let maxOrange = "O"
        static let maxRed    = "R"
        static let maxYellow = "Y"
        
        // Mixed line codes
        static let maxBlueGreen = "BG"
        static let maxBlueRed   = "BR"
        static let maxGreenOrange = "GO"
        static let maxGreenYellow = "GY"
        static let maxBlueGreenRed = "BGR"
        static let maxBlueGreenRedYellow = "BGRY"
        
        
        
        static let streetcarAB = "AL/BL"
        static let streetcarNSB = "NS/BL"
        static let streetcarNSA = "NS/AL"
        static let streetcarMaxABOrange = "O/AL/BL"
        static let streetcarNSAB = "NS/AL/BL"

        // Streetcar line codes
        static let streetcarALoop = "AL"
        static let streetcarBLoop = "BL"
        static let streetcarNS    = "NS"
        
        // Wes line code
        static let wes = "WES"
         

        static let streetcarPrefix      = "Portland Streetcar "
        static let streetcarInFullSign  = "streetcar"

        // Radius in feet used when resolving LocIds from the stops API.
        static func locIdRadius(for coordinate: CLLocationCoordinate2D, isStreetcar: Bool) -> Int {
            if isStreetcar               { return 50  }
            if coordinate.isPioneerPlace { return 100 }
            if coordinate.isDowntownCore { return 125 }
            return 200
        }
    }
}

extension CLLocationCoordinate2D {
    var isPioneerPlace: Bool {
        abs(latitude  - 45.51849907171159)   < 0.0001 &&
        abs(longitude - (-122.6777873516982)) < 0.0001
    }

    var isDowntownCore: Bool {
        latitude  < 45.536915  && latitude  > 45.504861 &&
        longitude > -122.698876 && longitude < -122.667121
    }
}
