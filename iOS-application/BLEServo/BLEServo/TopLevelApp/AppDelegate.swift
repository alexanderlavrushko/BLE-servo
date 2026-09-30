import SwiftUI

@main
struct BLEServoApp: App {
    @State private var controlCenter = ServoControlCenter()

    var body: some Scene {
        WindowGroup {
            MainView(controlCenter: controlCenter)
        }
    }
}
