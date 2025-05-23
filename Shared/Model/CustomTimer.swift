//
//  Emom.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 20/1/24.
//

import Foundation
enum TimerType: String, Codable, CaseIterable, Identifiable  {
  //  case none
    case emom
    case upTimer
    
    var id: String { self.rawValue }
}

struct CustomTimer: Equatable, Codable {
    var timerType: TimerType
    var rounds: Int
    var workSecs: Int = 0
    var restSecs: Int = 0
    var isMirroredOnAW: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case timerType
        case rounds
        case workSecs
        case restSecs
        case isMirroredOnAW
    }

    
    init(timerType: TimerType, rounds: Int, workSecs: Int = 0, restSecs: Int = 0, pendingSecs: Int = 0, isMirroredOnAW: Bool = false) {
        self.timerType = timerType
        self.rounds = rounds
        self.workSecs = workSecs
        self.restSecs = restSecs
        self.isMirroredOnAW = isMirroredOnAW
    }
    
    init?(dictionary: [String:Any]) {
        guard let timerTypeStr = dictionary[CustomTimer.CodingKeys.timerType.rawValue] as? String,
              let timerType = TimerType(rawValue: timerTypeStr),
              let rounds = dictionary[CustomTimer.CodingKeys.rounds.rawValue] as? Int else {
            return nil
        }
        self.timerType = timerType
        self.rounds = rounds
        self.workSecs = dictionary[CustomTimer.CodingKeys.workSecs.rawValue] as? Int ?? 0
        self.restSecs = dictionary[CustomTimer.CodingKeys.restSecs.rawValue] as? Int ?? 0
        self.isMirroredOnAW = dictionary[CustomTimer.CodingKeys.isMirroredOnAW.rawValue] as? Bool ?? false
    }

    func timeHHMMSS(isWork: Bool = true) -> String {
        return CustomTimer.getHHMMSS(seconds: isWork ? workSecs : restSecs)
    }
    
    static func getHHMMSS(seconds: Int) -> String {
        let hours = CustomTimer.getHH(seconds: seconds)
        if hours > 0 {
           return String(format: "%0.2d:%0.2d:%0.2d", CustomTimer.getHH(seconds: seconds), CustomTimer.getMM(seconds: seconds), CustomTimer.getSS(seconds: seconds))
        } else {
            return String(format: "%0.1d:%0.2d", CustomTimer.getMM(seconds: seconds), CustomTimer.getSS(seconds: seconds))
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
    
    static func getTotal(emom: CustomTimer) -> Int {
        // Remove restSecs from last round. Last round when ends work, timer is finished.
        (emom.rounds * ( emom.workSecs + emom.restSecs)) - emom.restSecs
    }
    
    static func getRound(emom: CustomTimer, secsEllapsed: Int) -> Int {
        var roundsEllapsed: Double = Double(secsEllapsed) / Double(emom.workSecs + emom.restSecs)
        if secsEllapsed % (emom.workSecs + emom.restSecs) == 0 {
            roundsEllapsed += 1
        }
        return  min(Int(roundsEllapsed.rounded(.up)), emom.rounds)
    }

    static func secsToNextRoud(emom: CustomTimer, secsEllapsed: Int) -> Int {
        guard secsEllapsed <= (emom.workSecs + emom.restSecs) * emom.rounds else { return 0 }
        let secsRound = (emom.workSecs + emom.restSecs)
        let remaining = secsEllapsed % secsRound
        return remaining == 0 ? 0 : secsRound - remaining
    }
    
    func endOfRound() -> Date? {
        Date.now.addingTimeInterval(Double(workSecs + restSecs))
    }

     func endOfWork() -> Date? {
        Date.now.addingTimeInterval(Double(workSecs))
    }
    
    func secondsPerRound() -> Double {
        Double(workSecs + restSecs)
    }
}

// MARK :- CustomStringConvertible
extension CustomTimer: CustomStringConvertible {
    var description: String {
        return "CustomTimer(\(self.timerType.rawValue),\(self.rounds),\(self.workSecs),\(self.restSecs))"
    }
}

// MARK :- Examples
extension CustomTimer {
    static let customTimerDefault = CustomTimer(timerType: .upTimer, rounds: 2, workSecs: 60, restSecs: 0)
    static let emom2r60w10r = CustomTimer(timerType: .emom, rounds: 2, workSecs: 60, restSecs: 10)
    static let emom2r60w0r = CustomTimer(timerType: .emom, rounds: 2, workSecs: 60, restSecs: 0)
}
