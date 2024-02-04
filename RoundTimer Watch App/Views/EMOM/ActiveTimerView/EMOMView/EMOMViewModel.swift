//
//  EMOMViewModel.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 25/1/24.
//

import SwiftUI

final class EMOMViewModel: ObservableObject {

    enum State: Int {
        case notStarted, startedWork, startedRest, paused, finished, cancelled
    }

    @Published var emom: Emom? //= .sample1rounds1Work0Rest
    internal var state: State = .notStarted
    private var wasPausedOnWorking = false
    private var secsEllapsed = 0
    private var totalSecsEllapsed = 0
    internal var timer: Timer?
    private let ticsPerSec = 20.0

    @Published var tics = 0
    /*@Published*/ private var currentRound = 0
    @Published var chrono = "12:34"
    @Published var percentage = 0.0
    @Published var playPause = "play"
    @Published var gradient = Gradient(colors: [Color(red: 0.0, green: 0.0, blue: 0.4), .blue])
    @Published var background = Color.clear
   // @Published var foreground = Color.white
    @Published var isPaused = false
    
    func set(emom: Emom?) {
        guard let emom else { return }
        self.emom = emom
        reset()
        refreshView()
    }

    deinit {
        removeTimer()
    }

    func close() {
        emom = nil
        state = .cancelled
        removeTimer()
    }

    func start() {
        if state == .notStarted {
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(timeInterval: 1.0 / ticsPerSec, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            state = .startedWork
            refreshView()
        } else if state == .startedRest || state == .startedWork {
            wasPausedOnWorking = state == .startedWork
            state = .paused
            isPaused = true
            refreshView()
        } else if state == .paused {
            state = wasPausedOnWorking ? .startedWork : .startedRest
            isPaused = false
            refreshView()
        } else if state == .finished {
            reset()
            refreshView()
        }
    }
    
    func getForegroundTextColor() -> Color {
        state == .paused || state == .notStarted ? .gray : .white
    }
    
    func hasToShow(work: Bool = true) -> Bool {
        return work ? state == .startedWork : state == .startedRest
    }
    
    func isTrailingChronoAlignment() -> Bool {
        return state != .startedRest
    }
    
    func getCurrentRound() -> Int {
        if state == .notStarted || state == .finished || state == .cancelled {
            return currentRound
        } else {
            return currentRound + 1
        }
    }
    
    func getPending() -> String {
        guard let emom else { return "00:00:00" }
        let remaningSecs = Emom.getTotal(emom: emom) - totalSecsEllapsed
        return Emom.getHHMMSS(seconds: remaningSecs)
    }

    func progress(tics: Int, ticsPerSec: Double, totalSecs: Int) -> Double {
        let module = tics % Int(ticsPerSec)
        let ndor = (Double(secsEllapsed) * ticsPerSec + Double(module))
        return ndor / (Double(totalSecs) * Double(ticsPerSec))
    }

    @objc func timerFired() {
        guard let emom else { return }
        tics += 1
        if state == .startedWork {
           // totalSegment = Emom.getSummary(seconds: emom.workSecs)
            if tics % Int(ticsPerSec) == 0 {
                secsEllapsed += 1
                totalSecsEllapsed += 1
            }
            percentage = 1 - min(progress(tics: tics, ticsPerSec: ticsPerSec, totalSecs: emom.workSecs), 1.0)
            // 0.9975
        //    percentage = min(percentage, 0.95)
            if secsEllapsed >= emom.workSecs {
                if emom.restSecs == 0 {
                    currentRound += 1
                    if currentRound >= emom.rounds {
                        state = .finished
                        WKInterfaceDevice.current().play(.notification)
                        removeTimer()
                    } else {
                        WKInterfaceDevice.current().play(.retry)
                        secsEllapsed = 0
                    }
                } else {
                    WKInterfaceDevice.current().play(.retry)
                    state = .startedRest
                    secsEllapsed = 0
                }
            }
        } else if state == .startedRest {
          //  totalSegment = Emom.getSummary(seconds: emom.restSecs)
            if tics % Int(ticsPerSec) == 0 {
                secsEllapsed += 1
                totalSecsEllapsed += 1
            }
            percentage = 1 - min(progress(tics: tics, ticsPerSec: ticsPerSec, totalSecs: emom.restSecs), 1.0)
            // 0.9975
       //     percentage = min(percentage, 0.95)
            if secsEllapsed >= emom.restSecs {
                currentRound += 1
                if currentRound >= emom.rounds {
                    state = .finished
                    removeTimer()
                    WKInterfaceDevice.current().play(.notification)
                } else {
                    state = .startedWork
                    secsEllapsed = 0
                    WKInterfaceDevice.current().play(.retry)
                }
            }
        } /*else {
            totalSegment = Emom.getSummary(seconds: emom.workSecs)
        }*/
        refreshView()
    }

    private func removeTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }

    func refreshView() {
        guard let emom else { return }
        chrono = getChrono(state: state, emom: emom, secsEllapsed: secsEllapsed)
        playPause = getPlayPauseButton(state: state)
  //      totalSegment = getTotalSegment(state: state, emom: emom)
        background = state == .finished ? .gray : .clear
        //foreground = state == .paused ? .gray : .white
    }

//    internal func getTotalSegment(state: State, emom: Emom) -> String {
//        if state == .finished {
//            return ""
//        } else if state == .paused {
//            return Emom.getSummary(seconds: wasPausedOnWorking ? emom.workSecs : emom.restSecs)
//        } else {
//            return Emom.getSummary(seconds: state == .startedRest ? emom.restSecs : emom.workSecs)
//        }
//    }

    internal func getChrono(state: State, emom: Emom, secsEllapsed: Int = 0) -> String {
        if state == .notStarted {
            return Emom.getHHMMSS(seconds: emom.workSecs)
        } else if state == .startedWork ||
                    state == .paused && wasPausedOnWorking {
            return Emom.getHHMMSS(seconds: emom.workSecs - secsEllapsed)
        } else if state == .startedRest ||
                    state == .paused && !wasPausedOnWorking  {
            return Emom.getHHMMSS(seconds: emom.restSecs - secsEllapsed)
        } else if state == .finished {
            return Emom.getHHMMSS(seconds: Emom.getTotal(emom: emom))
        }
        return "--:--:--"
    }

    internal func getPlayPauseButton(state: State) -> String {
        if state == .finished {
            return "arrow.uturn.left.circle"
        } else if state == .startedWork || state == .startedRest {
            return "pause.circle"
        } else {
            return "play.circle"
        }
    }

    private func reset() {
        state = .notStarted
        currentRound = 0
        tics = 0
        secsEllapsed = 0
        percentage = 0.0
        wasPausedOnWorking = false
        totalSecsEllapsed = 0
    }
}
