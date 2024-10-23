//
//  VibrationView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 1/2/24.
//

import SwiftUI

struct VibrationView: View {
    let dic: [String: WKHapticType] = [
        "notification":.notification,
        "directionUp":.directionUp,
        "directionDown":.directionDown,
        "success":.success,
        "failure":.failure,
        "retry":.retry,
        "start":.start,
        "stop":.stop,
        "click":.click,
        "navigationLeftTurn":.navigationLeftTurn,
        "navigationRightTurn":.navigationRightTurn,
        "navigationGenericManeuver":.navigationGenericManeuver,
        "underwaterDepthPrompt":.underwaterDepthPrompt,
        "underwaterDepthCriticalPrompt":.underwaterDepthCriticalPrompt,
    ]
    @State private var pickerRoundIndex = 0
    var body: some View {
        ScrollView {
            Picker("Vibration", selection: $pickerRoundIndex ) {
                //ForEach(0..<dic.values.count) {
                ForEach(Array(dic), id:\.key) { key, value in
                    //Text("\(Array(dic.keys)[$0])")
                    Text(key)
                }
            }
            .frame(height: 100)
            .pickerStyle(.wheel)
            Button(action: {
            let key = Array(dic.keys)[pickerRoundIndex]
                if let vibration = dic[key] {
                    WKInterfaceDevice.current().play(vibration)
                }
            }, label: {
                Text("Action")
            })
            Button(action: {
                HapticManager.shared.start()
            }, label: {
                Text("Start")
            })
            Button(action: {
                HapticManager.shared.work()
            }, label: {
                Text("Work")
            })
            Button(action: {
                HapticManager.shared.rest()
            }, label: {
                Text("Rest")
            })
            Button(action: {
                HapticManager.shared.finish()
            }, label: {
                Text("Finish")
            })
        }
    }
}


#Preview {
    VibrationView()
}
