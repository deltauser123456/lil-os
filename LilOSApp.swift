import SwiftUI

@main
struct LilOSApp: App {
    var body: some Scene {
        WindowGroup {
            DesktopView()
                .preferredColorScheme(.dark)
        }
    }
}
