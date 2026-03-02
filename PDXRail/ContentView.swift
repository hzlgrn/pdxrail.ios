import SwiftUI
import MapKit

struct ContentView: View {
    @Environment(PdxRailViewModel.self) private var viewModel
    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            // Title bar
            HStack {
                Button {
                    viewModel.showArrivals = true
                } label: {
                    AppIconCircle()
                }
                .disabled(viewModel.selectedStop == nil)

                Spacer()
                Text("PDX Rail")
                    .font(.headline)
                Spacer()


                Button {
                    viewModel.showArrivals = false
                    viewModel.showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.primary)
                }

                MapTypeMenu()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(.white)
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)

            MapView()
        }
        // Arrivals sheet — medium detent lets you see the map behind it
        .sheet(
            isPresented: $vm.showArrivals,
            onDismiss: { viewModel.dismissSelectedStop() },
        ) {
            ArrivalsView()
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.height },
                ) { height in
                    if (viewModel.arrivalsSheetHeight == 0) {
                        viewModel.arrivalsSheetHeight = height
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
        .sheet(isPresented: $vm.showHelp) {
            HelpView()
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - App icon circle

private struct AppIconCircle: View {
    private static let appIcon: UIImage? = {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let name = files.last {
            return UIImage(named: name)
        }
        return UIImage(named: "AppIcon")
    }()

    var body: some View {
        Group {
            if let icon = Self.appIcon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback: branded gradient circle
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.10, green: 0.45, blue: 0.87), Color(red: 0.05, green: 0.30, blue: 0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "lightrail.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }
}

// MARK: - Map type picker

private struct MapTypeMenu: View {
    @Environment(PdxRailViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        Menu {
            Picker("Map Type", selection: $vm.mapDisplayStyle) {
                ForEach(MapDisplayStyle.allCases) { style in
                    Label(style.rawValue, systemImage: style.systemImage).tag(style)
                }
            }
        } label: {
            Image(systemName: "map.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
        }
    }
}
