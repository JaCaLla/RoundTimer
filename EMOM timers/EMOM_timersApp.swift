//
//  EMOM_timersApp.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 10/4/24.
//

import SwiftUI
//import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
   // FirebaseApp.configure()

    return true
  }
}

@main
struct AppRoundTimerApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      NavigationView {
          //ContentView()
          MainView()
      }.onAppear {
#if !RELEASE
    var args = ProcessInfo.processInfo.arguments
    args.append("-FIRAnalyticsDebugEnabled")
    args.append("-FIRDebugEnabled")
    ProcessInfo.processInfo.setValue(args, forKey: "arguments")
#endif
     //     TrackingsManager.shared.log(eventName: "StartedUp", metadata: nil)
      }
      .onChange(of: scenePhase) { oldPhase, newPhase in
          switch newPhase {
          case .background:
              print("SchenePhase: Background from \(oldPhase)")
          case .inactive:
              print("SchenePhase: Inactive from \(oldPhase)")
          case .active:
              print("SchenePhase: Active/Foreground from \(oldPhase)")
          @unknown default:
              print("SchenePhase: Unknown scene phase \(newPhase) from \(oldPhase)")
          }
      }
    }
  }
}

extension View {
    @ViewBuilder
    func forceRotation(orientation: UIInterfaceOrientationMask) -> some View {
        self.onAppear() {
            AppDelegate.orientationLock = orientation
        }
        // Reset orientation to previous setting
        let currentOrientation = AppDelegate.orientationLock
        self.onDisappear() {
            AppDelegate.orientationLock = currentOrientation
        }
    }
}

//@main
//struct AppRoundTimerApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
