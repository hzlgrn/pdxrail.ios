import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("An interactive map for Portland, Oregon's rail-based transit systems.")
                        .font(.body)
                        .padding(.vertical, 4)
                }

                Section("Stops") {
                    HelpRow(
                        icon: "RailSystemMarkerStop.png",
                        tint: Color(red: 0.10, green: 0.45, blue: 0.87),
                        title: "MAX Light Rail",
                        bodyText: "Tap a MAX stop to view real-time vehicle locations and arrival times."
                    )
                    HelpRow(
                        icon: "StreetcarMarkerStop.png",
                        tint: .teal,
                        title: "Portland Streetcar",
                        bodyText: "Tap a Streetcar stop to view real-time arrival times. Vehicle locations are unavailable."
                    )
                }

                Section("Map") {
                    HelpRow(
                        icon: "RailSystemMarkerVehicle.png",
                        tint: .orange,
                        title: "Vehicle Positions",
                        bodyText: "While viewing MAX arrivals, active vehicles appear on the map with a directional arrow."
                    )
                    HelpRow(
                        icon: "map.fill",
                        tint: .secondary,
                        title: "Map Types",
                        bodyText: "Switch between Standard, Satellite, and Hybrid views using the map button."
                    )
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct HelpRow: View {
    let icon:  String
    let tint:  Color
    let title: String
    let bodyText: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(bodyText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        } icon: {
            if let uiImage = UIImage(named: icon) {
                Image(uiImage: uiImage)
                    .foregroundStyle(tint)
            } else {
                Image(systemName: icon).foregroundStyle(tint)
            }
        }
    }
}
