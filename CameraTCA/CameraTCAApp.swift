import ComposableArchitecture
import SwiftUI

@main
struct CameraTCAApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState: RootFeature.State(count: 1))
                {
                    RootFeature()
                })
        }
    }
}
