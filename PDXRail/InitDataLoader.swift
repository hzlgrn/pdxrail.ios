import Foundation

enum InitDataLoader {
    static func loadStops() throws -> [RailStop] {
        let data = try bundleData(named: "init_data_rail_stops")
        return try JSONDecoder()
            .decode(RailStopsData.self, from: data)
            .rail_stops
    }

    static func loadLines() throws -> [RailLine] {
        let data = try bundleData(named: "init_data_rail_lines")
        return try JSONDecoder()
            .decode(RailLinesData.self, from: data)
            .rail_lines
    }

    private static func bundleData(named name: String) throws -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw CocoaError(
                .fileNoSuchFile,
                userInfo: [
                    NSLocalizedDescriptionKey: "Missing bundle resource: \(name).json"
                ],
            )
        }
        return try Data(contentsOf: url)
    }
}
