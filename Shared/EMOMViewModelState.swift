//
//  EMOMViewModelState.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 15/8/24.
//

// MARK: - Emom timer states
public struct EMOMViewModelState {
    
    enum State: String {
        case countdown, notStarted,  startedWork, startedRest, finished, cancelled
    }
    
    private(set) var value: State = .notStarted
    private(set) var didChanged: Bool = false
    
    mutating func set(state to: State) -> Self {
        self.didChanged = self.value != to
        self.value = to
        return self
    }
}
