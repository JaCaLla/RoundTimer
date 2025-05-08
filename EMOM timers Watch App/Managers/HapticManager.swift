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
    func countdown1()
    func countdown23()
    func timerFinished()
}

@MainActor
final class HapticManager {
    static let shared = HapticManager()
}

extension HapticManager: HapticManagerProtocol {
    
    func countdown1() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    func countdown23() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func timerFinished() {
        WKInterfaceDevice.current().play(.success)
    }
    
    
}
