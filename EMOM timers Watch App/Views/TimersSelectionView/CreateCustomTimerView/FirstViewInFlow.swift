//
//  FirstViewInFlow.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 20/7/24.
//

import SwiftUI

public struct FirstViewInFlow: View {
    @Binding var navPath: [String]
    @EnvironmentObject var selectEMOMViewModel: CreateCustomTimerViewModel
    public var body: some View {
        if selectEMOMViewModel.timerType == .emom {
//            if AppGroupStore.shared.getDate(forKey: .birthDate) == nil {
//                AgeStepView(navPath: $navPath, context: .timerCreation)
//            } else {
                RoundsStepView(navPath: $navPath)
 //           }
        } else if selectEMOMViewModel.timerType == .upTimer {
            TimerPickerStepView(navPath: $navPath, pickerViewType: .work)
        } else {
            EmptyView()
        }
    }
}
