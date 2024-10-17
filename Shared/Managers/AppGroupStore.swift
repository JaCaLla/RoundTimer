//
//  AppGroupStore.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 21/7/24.
//

import Foundation
@MainActor
protocol AppGroupStoreProtocol {
    func getDate(forKey: AppGroupStoreKey) -> Date?
    func setDate(date: Date, forKey: AppGroupStoreKey)
}

enum AppGroupStoreKey: String {
    case birthDate
    case grantedPermissionForHeartRate
}

@MainActor
final class AppGroupStore {
    let defaults = UserDefaults(suiteName: "group.jca.EMOM-timers")
    
    static let shared = AppGroupStore()
    
    private init() {
        
    }
}

// MARK: - AppGroupStoreProtocol
extension AppGroupStore: AppGroupStoreProtocol {
    func getDate(forKey: AppGroupStoreKey) -> Date? {
        return defaults?.object(forKey: forKey.rawValue) as? Date
    }
    
    func setDate(date: Date, forKey: AppGroupStoreKey) {
        defaults?.set(date, forKey: forKey.rawValue)
    }
    
    func getBool(forKey: AppGroupStoreKey) -> Bool? {
        return defaults?.object(forKey: forKey.rawValue) as? Bool
    }
    
    func setBool(value: Bool, forKey: AppGroupStoreKey) {
        defaults?.set(value, forKey: forKey.rawValue)
    }
}
