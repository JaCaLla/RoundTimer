//
//  Emom.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 20/1/24.
//

import Foundation

struct Emom: Equatable {
    var rounds: Int
    var workSecs: Int = 0
    var restSecs: Int = 0

//    func workRatio() -> Double? {
//        Double(String(format: "%.2f", Double(workSecs) / Double(workSecs + restSecs))) ?? -1.0
//    }

    func timeHHMMSS(isWork: Bool = true) -> String {
        return Emom.getHHMMSS(seconds: isWork ? workSecs : restSecs)
    }
    
    static func getHHMMSS(seconds: Int) -> String {
        let hours = Emom.getHH(seconds: seconds)
        if hours > 0 {
           return String(format: "%0.2d:%0.2d:%0.2d", Emom.getHH(seconds: seconds), Emom.getMM(seconds: seconds), Emom.getSS(seconds: seconds))
        } else {
            return String(format: "%0.2d:%0.2d", Emom.getMM(seconds: seconds), Emom.getSS(seconds: seconds))
        }
        
    }
    
    static func getSummary(seconds: Int) -> String {
        if seconds >= 3600 {
            return "\(getHH(seconds: seconds)) H"
        } else if seconds >= 60 {
            return "\(getMM(seconds: seconds)) MIN"
        } else {
            return "\(getSS(seconds: seconds)) s"
        }
    }
    
    static func getHH(seconds: Int) -> Int {
        seconds / 3600
    }
    
    static func getMM(seconds: Int) -> Int {
        (seconds % 3600) / 60
    }
    
    static func getSS(seconds: Int) -> Int {
        (seconds % 3600) % 60
    }
    
    static func getTotal(emom: Emom) -> Int {
        emom.rounds * ( emom.workSecs + emom.restSecs)
    }
}
