//
//  VibrationManager.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 14/2/24.
//

import Foundation
import SwiftUI

@MainActor
protocol HapticManagerProtocol {
    func start()
    func pause()
    func rest()
    func work()
    func finish()
}

@MainActor
final class HapticManager {
    static let shared = HapticManager()
}

extension HapticManager: HapticManagerProtocol {
    func start() {
        WKInterfaceDevice.current().play(.notification)//start)
    }
    
    func pause() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func rest() {
        WKInterfaceDevice.current().play(.stop)
    }
    
    func work() {
        WKInterfaceDevice.current().play(.retry)
    }
    
    func finish() {
        WKInterfaceDevice.current().play(.success)
    }
    
    
}
