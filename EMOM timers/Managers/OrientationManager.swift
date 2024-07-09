//
//  OrientationManager.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 17/5/24.
//

//import SwiftUI
//import UIKit
//
//class OrientationManager: ObservableObject {
//    @Published var isLandscape = UIDevice.current.orientation.isLandscape
//    
//    private var orientationDidChangeNotification: NSObjectProtocol?
//    
//    init() {
//        orientationDidChangeNotification = NotificationCenter.default.addObserver(
//            forName: UIDevice.orientationDidChangeNotification,
//            object: nil,
//            queue: .main
//        ) { _ in
//            self.isLandscape = UIDevice.current.orientation.isLandscape
//        }
//    }
//    
//    deinit {
//        if let orientationDidChangeNotification = orientationDidChangeNotification {
//            NotificationCenter.default.removeObserver(orientationDidChangeNotification)
//        }
//    }
//}

