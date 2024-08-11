//
//  MirroredTimerWorking.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 13/7/24.
//

import Foundation

struct MirroredTimerWorking: Equatable, Codable {
    let rounds: Int
    let currentRound: Int
    let date: Double
    let isWork: Bool
    let message: String
    
    init(rounds: Int, currentRounds: Int, date: Double, isWork: Bool, message: String) {
        self.rounds = rounds
        self.currentRound = currentRounds
        self.date = date
        self.isWork = isWork
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case rounds, currentRound, date, isWork, message
    }
    
    init?(dictionary: [String:Any]) {
        guard let rounds = dictionary[MirroredTimerWorking.CodingKeys.rounds.rawValue] as? Int,
        let currentRounds = dictionary[MirroredTimerWorking.CodingKeys.currentRound.rawValue] as? Int,
        let date = dictionary[MirroredTimerWorking.CodingKeys.date.rawValue] as? Double,
        let isWork = dictionary[MirroredTimerWorking.CodingKeys.isWork.rawValue] as? Bool,
        let message = dictionary[MirroredTimerWorking.CodingKeys.message.rawValue] as? String else {
            return nil
        }
        self.rounds = rounds
        self.currentRound = currentRounds
        self.date = date
        self.isWork = isWork
        self.message = message
    }
}

// MARK :- CustomStringConvertible
extension MirroredTimerWorking: CustomStringConvertible {
    var description: String {
        return "MirroredTimerWorking(\(currentRound)/\(rounds),\(date),\(isWork),\(message)"
    }
}
