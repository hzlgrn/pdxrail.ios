import SwiftUI
import MapKit

@Observable
@MainActor
final class PdxRailViewModel {
    

    // Map content
    var stops: [RailStop] = []
    var lines: [PolylineStroke] = []
    var vehicleMarkers: [VehiclePosition] = []

    // Stop selection
    var selectedStop: RailStop?
    var selectedStationName = ""

    // Arrivals state
    enum ArrivalsState { case idle, loading, loaded([ArrivalItem]), failed(Error) }
    var arrivalsState: ArrivalsState = .idle

    // UI state
    var showArrivals         = false
    var arrivalsSheetHeight: CGFloat = 0
    var showHelp             = false
    var mapDisplayStyle   = MapDisplayStyle.standard
    var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude:  Domain.Camera.defaultLatitude,
                longitude: Domain.Camera.defaultLongitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta:  Domain.Camera.defaultSpanDelta,
                longitudeDelta: Domain.Camera.defaultSpanDelta
            )
        )
    )

    // Private
    private let service = RailSystemService()
    private var locIdCache: [String: (ids: [Int], expiry: Date)] = [:]
    private var arrivalsTask: Task<Void, Never>?

    // Initial data load

    func loadInitialData() async {
        let loadedStops = await Task.detached(priority: .userInitiated) {
            try? InitDataLoader.loadStops()
        }.value ?? []

        let loadedLines = await Task.detached(priority: .userInitiated) {
            try? InitDataLoader.loadLines()
        }.value ?? []
        
        // Expand loaded lines to support multiple line draws for dashed polylines
        let polyLines = loadedLines.flatMap { line in
            
            switch line.line {
                case Domain.RailSystem.maxBlue: return [PolylineStroke(red: 0.0, green: 0.412, blue: 0.667, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                case Domain.RailSystem.maxGreen: return [PolylineStroke(red: 0.0, green: 0.529, blue: 0.322, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                case Domain.RailSystem.maxOrange: return [PolylineStroke(red: 0.82, green: 0.373, blue: 0.153, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                case Domain.RailSystem.maxRed: return [PolylineStroke(red: 0.82, green: 0.071, blue: 0.259, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                case Domain.RailSystem.maxYellow: return [PolylineStroke(red: 1.0, green: 0.769, blue: 0.145, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                
                case Domain.RailSystem.maxBlueGreen: return [
                    PolylineStroke(red: 0.0, green: 0.412, blue: 0.667, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 0.0, green: 0.529, blue: 0.322, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.maxBlueRed: return [
                    PolylineStroke(red: 0.0, green: 0.412, blue: 0.667, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 0.82, green: 0.071, blue: 0.259, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.maxGreenOrange: return [
                    PolylineStroke(red: 0.0, green: 0.529, blue: 0.322, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 0.82, green: 0.373, blue: 0.153, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.maxGreenYellow: return [
                    PolylineStroke(red: 0.0, green: 0.529, blue: 0.322, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 1.0, green: 0.769, blue: 0.145, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.maxBlueGreenRed: return [
                    PolylineStroke(red: 0.0, green: 0.412, blue: 0.667, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,18]),
                    PolylineStroke(red: 0.0, green: 0.529, blue: 0.322, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,9]),
                    PolylineStroke(red: 0.82, green: 0.071, blue: 0.259, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,18,9,0]),
                ]
                
                case Domain.RailSystem.maxBlueGreenRedYellow: return [
                    PolylineStroke(red: 0.0, green: 0.412, blue: 0.667, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,27]),
                    PolylineStroke(red: 0.0, green: 0.529, blue: 0.322, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,18]),
                    PolylineStroke(red: 0.82, green: 0.071, blue: 0.259, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,18,9,9]),
                    PolylineStroke(red: 1.0, green: 0.769, blue: 0.145, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,27,9,0]),
                ]
                
                case Domain.RailSystem.wes: return [PolylineStroke(red: 0.137, green: 0.122, blue: 0.125, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                
                case Domain.RailSystem.streetcarALoop: return [PolylineStroke(red: 0.867, green: 0.157, blue: 0.557, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                case Domain.RailSystem.streetcarBLoop: return [PolylineStroke(red: 0.0, green: 0.569, blue: 0.698, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                case Domain.RailSystem.streetcarNS: return [PolylineStroke(red: 0.549, green: 0.776, blue: 0.243, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
                
                case Domain.RailSystem.streetcarAB: return [
                    PolylineStroke(red: 0.867, green: 0.157, blue: 0.557, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 0.0, green: 0.569, blue: 0.698, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.streetcarNSB: return [
                    PolylineStroke(red: 0.549, green: 0.776, blue: 0.243, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 0.0, green: 0.569, blue: 0.698, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.streetcarNSA: return [
                    PolylineStroke(red: 0.549, green: 0.776, blue: 0.243, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,9]),
                    PolylineStroke(red: 0.867, green: 0.157, blue: 0.557, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,0]),
                ]
                
                case Domain.RailSystem.streetcarMaxABOrange: return [
                    PolylineStroke(red: 0.867, green: 0.157, blue: 0.557, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,18]),
                    PolylineStroke(red: 0.0, green: 0.569, blue: 0.698, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,9]),
                    PolylineStroke(red: 0.82, green: 0.373, blue: 0.153, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,18,9,0]),
                ]
                
                case Domain.RailSystem.streetcarNSAB: return [
                    PolylineStroke(red: 0.549, green: 0.776, blue: 0.243, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [9,18]),
                    PolylineStroke(red: 0.867, green: 0.157, blue: 0.557, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,9,9,9]),
                    PolylineStroke(red: 0.0, green: 0.569, blue: 0.698, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline, pattern: [0,18,9,0]),
                ]
                
                
                default: return [PolylineStroke(red: 0.0, green: 0.0, blue: 0.0, line: line.line, passage: line.passage, type: line.type, polyline: line.polyline,)]
            }
        }

        stops = loadedStops
        lines = polyLines
    }

    // Stop interaction

    func onTapStop(_ stop: RailStop) {
        selectedStop        = stop
        selectedStationName = stop.station ?? ""
        startArrivalsPolling(for: stop)
    }

    func dismissSelectedStop() {
        showArrivals         = false
        arrivalsSheetHeight  = 0
        selectedStop         = nil
        selectedStationName  = ""
        cancelArrivals()
    }

    // Arrivals polling

    private func startArrivalsPolling(for stop: RailStop) {
        cancelArrivals()
        arrivalsState  = .loading
        vehicleMarkers = []

        arrivalsTask = Task { [weak self] in
            guard let self else { return }
            do {
                while !Task.isCancelled {
                    let locIds = try await resolveLocIds(for: stop)
                    guard !Task.isCancelled else { return }

                    let response = try await service.fetchArrivals(
                        locIds: locIds,
                        isStreetcar: stop.isStreetcar
                    )
                    guard !Task.isCancelled else { return }

                    let arrivals = Self.parseArrivalItems(from: response, stop: stop)
                    arrivalsState  = .loaded(arrivals)
                    vehicleMarkers = arrivals.compactMap(\.vehicle)

                    try await Task.sleep(for: .seconds(10))
                }
            } catch is CancellationError {
                // Normal dismissal — no-op
            } catch {
                arrivalsState = .failed(error)
            }
        }
    }

    private func cancelArrivals() {
        arrivalsTask?.cancel()
        arrivalsTask   = nil
        arrivalsState  = .idle
        vehicleMarkers = []
    }

    // LocId resolution

    private func resolveLocIds(for stop: RailStop) async throws -> [Int] {
        let key = "\(stop.lat),\(stop.lon),\(stop.isStreetcar)"
        if let cached = locIdCache[key], cached.expiry > .now {
            return cached.ids
        }
        let radius = Domain.RailSystem.locIdRadius(
            for: stop.coordinate,
            isStreetcar: stop.isStreetcar
        )
        let response = try await service.fetchStops(
            lat: stop.lat,
            lon: stop.lon,
            radiusInFeet: radius,
            isStreetcar: stop.isStreetcar
        )
        logger.debug("fetchStops response")
        let ids = (response.resultSet.location ?? []).map(\.locid)
        logger.debug("fetchStops response \(ids)")
        locIdCache[key] = (ids, Date.now.addingTimeInterval(24 * 3600))
        return ids
    }

    // Parsing

    private static func parseArrivalItems(
        from response: ArrivalsResponse,
        stop: RailStop
    ) -> [ArrivalItem] {
        (response.resultSet.arrival ?? [])
            .filter { arrival in
                let sign = arrival.fullSign.lowercased()
                return stop.isStreetcar
                    ? sign.contains(Domain.RailSystem.streetcarInFullSign)
                    : sign.contains("max") || sign.contains("wes")
            }
            .map { arrival in
                let rawSign   = arrival.shortSign ?? arrival.fullSign
                let shortSign = rawSign.replacingOccurrences(
                    of: Domain.RailSystem.streetcarPrefix, with: ""
                )
                let sched = Date(timeIntervalSince1970: Double(arrival.scheduled) / 1000)
                let est   = arrival.estimated.map { Date(timeIntervalSince1970: Double($0) / 1000) }
                let color = lineColor(for: rawSign)

                return ArrivalItem(
                    id:        arrival.id,
                    shortSign: shortSign,
                    scheduled: sched,
                    estimated: est,
                    isLate:    est.map { $0 > sched } ?? false,
                    isEarly:   est.map { $0 < sched } ?? false,
                    lineColor: color,
                    vehicle: arrival.blockPosition.map { bp in
                        VehiclePosition(
                            id:         arrival.id,
                            coordinate: CLLocationCoordinate2D(latitude: bp.lat, longitude: bp.lng),
                            heading:    bp.heading,
                            lineColor:  color,
                            shortSign:  shortSign
                        )
                    }
                )
            }
            .sorted { ($0.estimated ?? $0.scheduled) < ($1.estimated ?? $1.scheduled) }
    }
    
    static func lineColor(for shortSign: String) -> Color {
        let s = shortSign.lowercased()
        if s.contains("blue")                              { return Color(red: 0.0, green: 0.412, blue: 0.667) }
        if s.contains("green")                             { return Color(red: 0.0, green: 0.529, blue: 0.322) }
        if s.contains("orange")                            { return Color(red: 0.82, green: 0.373, blue: 0.153) }
        if s.contains("red")                               { return Color(red: 0.82, green: 0.071, blue: 0.259) }
        if s.contains("yellow")                            { return Color(red: 1.0, green: 0.769, blue: 0.145) }
        if s.contains("ns line")                           { return Color(red: 0.549, green: 0.776, blue: 0.243) }
        if s.contains("a loop") || s.contains("loop a")   { return Color(red: 0.867, green: 0.157, blue: 0.557) }
        if s.contains("b loop") || s.contains("loop b")   { return Color(red: 0.0, green: 0.569, blue: 0.698) }
        return .gray
    }
}
