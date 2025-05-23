//
//  EMOM_timersApp.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 10/4/24.
//

import SwiftUI
//import FirebaseCore


struct LandscapeViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .landscape
    }
}

@main
struct AppRoundTimerApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var isActive = false
    
  var body: some Scene {
    WindowGroup {
      NavigationView {
          //ContentView()
          if isActive {
              MainView()
          } else {
              SplashScreenView()
          }
      }
      .navigationViewStyle(StackNavigationViewStyle()) 
      .preferredColorScheme(.dark)
      .edgesIgnoringSafeArea(.all)
      .onAppear {
                  // Delay for 2 seconds before switching to the main view
                  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                      withAnimation {
                          self.isActive = true
                      }
                  }
              }
      .onAppear {
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

//extension View {
//    @ViewBuilder
//    func forceRotation(orientation: UIInterfaceOrientationMask) -> some View {
//        self.onAppear() {
//            AppDelegate.orientationLock = orientation
//        }
//        // Reset orientation to previous setting
//        let currentOrientation = AppDelegate.orientationLock
//        self.onDisappear() {
//            AppDelegate.orientationLock = currentOrientation
//        }
//    }
//}

//@main
//struct AppRoundTimerApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
