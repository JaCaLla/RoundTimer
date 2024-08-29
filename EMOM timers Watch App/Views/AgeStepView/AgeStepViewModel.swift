//
//  AgeStepViewModel.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 21/7/24.
//
import Foundation
import Combine

protocol AgeStepViewModelProtocol {
    func getBirthDate() -> Date
    func setBirthDate(date: Date)
    func calculateAge(from: Date) -> Int
}

final class AgeStepViewModel: NSObject, ObservableObject {
    // Define minimum and maximum dates
     var minimumDate: Date {
        var dateComponents = DateComponents()
        dateComponents.year = 1920
        dateComponents.month = 1
        dateComponents.day = 1
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
//    func calculateAge(from birthDate: Date) -> Int {
//        let calendar = Calendar.current
//        let currentDate = Date()
//        
//        // Extract the year component from the birth date and current date
//        let birthDateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
//        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
//        
//        // Calculate the age
//        let ageComponents = calendar.dateComponents([.year], from: birthDateComponents, to: currentDateComponents)
//        let age = ageComponents.year ?? 0
//        
//        return age
//    }
}
// MARK: - AgeStepViewModelProtocol
extension AgeStepViewModel: AgeStepViewModelProtocol {
    func getBirthDate() -> Date {
        guard let date = AppGroupStore.shared.getDate(forKey: .birthDate) else {
            return Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date.now
        }
        return date
    }
    
    func setBirthDate(date: Date) {
        AppGroupStore.shared.setDate(date: date, forKey: .birthDate)
    }
    
    func calculateAge(from: Date) -> Int {
        HeartZoneCalculator.calculateAge(from: from)
    }
}
