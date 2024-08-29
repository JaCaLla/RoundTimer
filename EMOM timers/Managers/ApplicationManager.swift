//
//  ApplicationManager.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 3/7/24.
//

import UIKit

final class ApplicationManager {
    
    private init() {
        
    }
    
    public static func setInForeground(_ value: Bool) {
        UIApplication.shared.isIdleTimerDisabled = value
    }
    
}
