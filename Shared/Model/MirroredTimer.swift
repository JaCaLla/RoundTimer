//
//  MirroredTimer.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 12/7/24.
//

import Foundation
// TO DO: TRY TO USE STATE ENUM INSTEAD
enum MirroredTimerType: String, Codable {
    case countdown, working, finished, removedFromCompanion
}

struct MirroredTimer: Equatable, Codable {
    let mirroredTimerType: MirroredTimerType
    var mirroredTimerCountdown: MirroredTimerCountdown?
    var mirroredTimerWorking: MirroredTimerWorking?
    var mirroredTimerFinished: MirroredTimerFinished?
    
    
    enum CodingKeys: String, CodingKey {
        case mirroredTimerType
        case mirroredTimerCountdown
        case mirroredTimerWorking
        case mirroredTimerFinished
    }
    
    
    init(mirroredTimerType: MirroredTimerType,
         mirroredTimerCountdown: MirroredTimerCountdown? = nil,
         mirroredTimerWorking: MirroredTimerWorking? = nil,
         mirroredTimerFinished: MirroredTimerFinished? = nil) {
        self.mirroredTimerType = mirroredTimerType
        self.mirroredTimerCountdown = mirroredTimerCountdown
        self.mirroredTimerWorking = mirroredTimerWorking
        self.mirroredTimerFinished = mirroredTimerFinished
    }
    
    init?(dictionary: [String:Any]) {
        guard let mirroredTimerTypeStr = dictionary[MirroredTimer.CodingKeys.mirroredTimerType.rawValue] as? String,
              let mirroredTimerType = MirroredTimerType(rawValue: mirroredTimerTypeStr) else {
            return nil
        }
        self.mirroredTimerType = mirroredTimerType
        if  let dictionary =  dictionary[MirroredTimer.CodingKeys.mirroredTimerCountdown.rawValue] as? [String : Any],
            let mirroredTimerCountdown = MirroredTimerCountdown(dictionary: dictionary) {
                         // self.mirroredTimer = countdown
            self.mirroredTimerCountdown = mirroredTimerCountdown
        }
        if  let dictionary =  dictionary[MirroredTimer.CodingKeys.mirroredTimerWorking.rawValue] as? [String : Any],
            let mirroredTimerWorking = MirroredTimerWorking(dictionary: dictionary) {
                         // self.mirroredTimer = countdown
            self.mirroredTimerWorking = mirroredTimerWorking
        }
        if  let dictionary =  dictionary[MirroredTimer.CodingKeys.mirroredTimerFinished.rawValue] as? [String : Any],
            let mirroredTimerStopped = MirroredTimerFinished(dictionary: dictionary) {
                         // self.mirroredTimer = countdown
            self.mirroredTimerFinished = mirroredTimerStopped
        }
        
    }
}

// MARK :- CustomStringConvertible
extension MirroredTimer: CustomStringConvertible {
    var description: String {
        return "MirroredTimer(\(mirroredTimerType),\(String(describing: mirroredTimerCountdown)),\(String(describing: mirroredTimerWorking)))"
    }
}

// MARK :- Samples
extension MirroredTimer {
    static let removedFromCompanion = MirroredTimer(mirroredTimerType: .removedFromCompanion)
}
