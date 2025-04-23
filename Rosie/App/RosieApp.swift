
import SwiftUI

@main
struct RosieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        print(OrientationManager.shared.isHorizontalLock)
        if OrientationManager.shared.isHorizontalLock {
            return .portrait
        } else {
            return .allButUpsideDown
        }
    }
}
