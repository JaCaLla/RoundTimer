//
//  HeartZoneCalculator.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 16/7/24.
//

import Foundation

struct HeartZoneCalculator {
    let age: Int
    
    
    func zone(heartRate: Double?) -> Int {
        guard let heartRate else { return 0 }
        let mhr = Double(220 - self.age)
        
        if heartRate < mhr * 0.6 {
            return 0
        } else if mhr * 0.6 <= heartRate && heartRate < mhr * 0.7 {
            return 1
        } else if mhr * 0.7 <= heartRate && heartRate < mhr * 0.8 {
            return 2
        } else if mhr * 0.8 <= heartRate && heartRate < mhr * 0.9 {
            return 3
        } else {
            return 4
        }
    }
    
    static func calculateAge(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Extract the year component from the birth date and current date
        let birthDateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        
        // Calculate the age
        let ageComponents = calendar.dateComponents([.year], from: birthDateComponents, to: currentDateComponents)
        let age = ageComponents.year ?? 0
        
        return age
    }
}
