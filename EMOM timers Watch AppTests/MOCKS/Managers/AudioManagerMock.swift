//
//  AudioManagerMock.swift
//  EMOM timers Watch AppTests
//
//  Created by Javier Calartrava on 16/8/24.
//
@testable import EMOM_timers_Watch_App

class AudioManagerMock: AudioManagerProtocol {
    var speakCounter = 0
    var speakStateCount = 0
    var countdownCount = 0
    var workCount = 0
    var finishedCount = 0
    
    func speak(text: String) {
        speakCounter += 1
    }
    
    func speech(state: EMOM_timers_Watch_App.EMOMViewModelState) {
        speakStateCount += 1
    }
    
    func countdown() {
        countdownCount += 1
    }
    
    func work() {
        workCount += 1
    }
    
    func finished() {
        finishedCount += 1
    }
}
