import SwiftUI

@main
struct PDXRailApp: App {
    @State private var viewModel = PdxRailViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
