import SwiftUI
import MapKit
import OSLog

struct MapView: View {
    @Environment(PdxRailViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        Map(position: $vm.cameraPosition) {
            // Rail lines — drawn first so stop markers appear on top
            ForEach(viewModel.lines) { line in
                MapPolyline(coordinates: line.coordinates)
                    .stroke(
                        Color(red: line.red, green: line.green, blue: line.blue),
                        style: StrokeStyle(lineWidth: line.lineWidth, dash: line.pattern.map(CGFloat.init)),
                    )
            }

            // Stop markers
            ForEach(viewModel.stops) { stop in
                Annotation("", coordinate: stop.coordinate, anchor: .center) {
                    StopMarkerView(stop: stop)
                        .onTapGesture { viewModel.onTapStop(stop) }
                }
            }

            // Active vehicle positions (shown while viewing arrivals)
            ForEach(viewModel.vehicleMarkers) { vehicle in
                Annotation("", coordinate: vehicle.coordinate, anchor: .center) {
                    VehicleMarkerView(vehicle: vehicle)
                }
            }
            
            // Callout for the selected stop
            if let selected = viewModel.selectedStop {
                Annotation("", coordinate: selected.coordinate, anchor: .bottom) {
                    StopCalloutView(stop: selected)
                        .onTapGesture {
                            if !viewModel.showArrivals {
                                viewModel.showArrivals = true
                            }
                        }
                        .opacity(viewModel.showArrivals ? 0.7 : 1.0)
                }
            }

            UserAnnotation()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: viewModel.arrivalsSheetHeight)
        }
        .mapStyle(viewModel.mapDisplayStyle.mapKitStyle)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }
}

private struct StopCalloutView: View {
    let stop: RailStop

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: stop.markerSystemImage)
                    .font(.caption)
                Text(stop.station ?? stop.type)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            // Spacer to lift the bubble above the stop marker circle (radius 13pt + 4pt gap)
            Color.clear
                .frame(height: 17)
                .allowsHitTesting(false)
        }
    }
}

private struct StopMarkerView: View {
    let stop: RailStop

    var body: some View {
        ZStack {
            Image(uiImage: UIImage(named: stop.markerSystemImage)!)
        }
    }
}

private struct VehicleMarkerView: View {
    let vehicle: VehiclePosition

    var body: some View {
        ZStack {
            if let vehicleUIImage = UIImage(named: "RailSystemMarkerVehicle.png") {
                Image(uiImage: vehicleUIImage)
                    .rotationEffect(.degrees(Double(vehicle.heading)))
                    .colorMultiply(vehicle.lineColor)
            }
        }
    }
}

extension MapDisplayStyle {
    var mapKitStyle: MapStyle {
        switch self {
        case .standard:  return .standard
        case .satellite: return .imagery
        case .hybrid:    return .hybrid
        }
    }
}
