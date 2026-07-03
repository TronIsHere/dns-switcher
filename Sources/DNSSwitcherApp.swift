import SwiftUI

@main
struct DNSSwitcherApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            RootView()
                .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 440, height: 620)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
