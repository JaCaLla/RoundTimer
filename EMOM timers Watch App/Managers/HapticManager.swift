//
//  VibrationManager.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 14/2/24.
//

import Foundation
import SwiftUI

protocol HapticManagerProtocol {
    func start()
    func pause()
    func rest()
    func work()
    func finish()
}

final class HapticManager {
    static let shared = HapticManager()
}

extension HapticManager: HapticManagerProtocol {
    func start() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
//            WKInterfaceDevice.current().play(.failure)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            WKInterfaceDevice.current().play(.failure)
//        }
        WKInterfaceDevice.current().play(.notification)//start)
    }
    
    func pause() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func rest() {
       // WKInterfaceDevice.current().play(.notification)
        WKInterfaceDevice.current().play(.stop)
    }
    
    func work() {
        //start()
        WKInterfaceDevice.current().play(.retry)
    }
    
    func finish() {
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            WKInterfaceDevice.current().play(.failure)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WKInterfaceDevice.current().play(.failure)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            WKInterfaceDevice.current().play(.notification)
        }*/
        WKInterfaceDevice.current().play(.success)
    }
    
    
}
