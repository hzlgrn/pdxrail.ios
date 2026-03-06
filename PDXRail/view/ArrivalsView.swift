import SwiftUI

struct ArrivalsView: View {
    @Environment(PdxRailViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.arrivalsState {
                case .idle:
                    Color.clear

                case .loading:
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading arrivals…")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded(let arrivals):
                    arrivalsList(arrivals)

                case .failed(let error):
                    ContentUnavailableView(
                        "Couldn't Load Arrivals",
                        systemImage: "wifi.exclamationmark",
                        description: Text(error.localizedDescription)
                    )
                }
            }
            .navigationTitle(
                viewModel.selectedStationName.isEmpty ? "Arrivals" : viewModel.selectedStationName
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { viewModel.dismissSelectedStop() }
                }
            }
        }
    }

    @ViewBuilder
    private func arrivalsList(_ arrivals: [ArrivalItem]) -> some View {
        if arrivals.isEmpty {
            ContentUnavailableView(
                "No Scheduled Arrivals",
                systemImage: "tram",
                description: Text("There are no upcoming arrivals for this stop.")
            )
        } else {
            List(arrivals) { arrival in
                ArrivalRow(arrival: arrival)
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct ArrivalRow: View {
    let arrival: ArrivalItem

    var body: some View {
        HStack(spacing: 12) {
            // Colored line indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(arrival.lineColor)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(arrival.shortSign)
                    .font(.subheadline.weight(.semibold))

                HStack(spacing: 8) {
                    // Scheduled time
                    Label(
                        arrival.scheduled.formatted(date: .omitted, time: .shortened),
                        systemImage: "clock"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    // Estimated time (only shown when different)
                    if let est = arrival.estimated {
                        if arrival.isLate {
                            Label(
                                est.formatted(date: .omitted, time: .shortened),
                                systemImage: "exclamationmark.circle.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(.red)
                        } else if arrival.isEarly {
                            Label(
                                est.formatted(date: .omitted, time: .shortened),
                                systemImage: "checkmark.circle.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
