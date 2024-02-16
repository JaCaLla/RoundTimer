//
//  VibrationManager.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 14/2/24.
//

import Foundation
import SwiftUI

protocol VibrationManagerProtocol {
    func start()
    func pause()
    func rest()
    func work()
    func finish()
}

final class VibrationManager {
    static let shared = VibrationManager()
}

extension VibrationManager: VibrationManagerProtocol {
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            WKInterfaceDevice.current().play(.failure)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            WKInterfaceDevice.current().play(.failure)
        }
    }
    
    func pause() {
        WKInterfaceDevice.current().play(.start)
    }
    
    func rest() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    func work() {
        start()
    }
    
    func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            WKInterfaceDevice.current().play(.failure)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WKInterfaceDevice.current().play(.failure)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            WKInterfaceDevice.current().play(.notification)
        }
    }
    
    
}
