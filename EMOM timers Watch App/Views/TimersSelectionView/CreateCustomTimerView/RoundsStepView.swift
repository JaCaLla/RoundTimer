//
//  RoundsStepView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

enum RoundStepViewType {
    case round, work, rest

    var navigationTitle: LocalizedStringKey {
        switch self {
        case .work: "title_work"
        case .rest: "title_rest"
        case .round: "title_round"
        }
    }
    
    var initial: Double {
        switch self {
        case .work: 60.0
        case .rest: 0.0
        case .round: 2.0
        }
    }
    
    var through: Double {
        switch self {
        case .work: 60.0
        case .rest: 0.0
        case .round: 2.0
        }
    }
}

struct RoundsStepView: View {
    
   // @State private var pickerRoundIndex = 0
    @FocusState private var fousedfield: Bool
    @Binding var navPath: [String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var selectEMOMViewModel: CreateCustomTimerViewModel
    @State private var selectedRound: Double = 2.0
    var body: some View {
        VStack {
            Spacer()
            Text("\(Int(selectedRound))")
                .foregroundColor(.roundColor)
                .font(.roundInputFont)
              .focusable()
              .focused($fousedfield)
              .digitalCrownRotation($selectedRound, 
                                    from: 2.0,
                                    through: 50.0,
                                    by:1.0,
                                    sensitivity: .medium,
                                    isHapticFeedbackEnabled: true)
            Spacer()
            if selectEMOMViewModel.rounds > 0 {
                NavigationLink(value: CreateCustomTimerViewModel.Screens.timerPickerStepViewWork.rawValue) {
                    Group {
                        Text(String(localized: "button_next")) + Text(Image(systemName: "chevron.right"))
                    }
                    .font(.buttonSubtitleFont)
                    
                }
                Spacer()
            } 
        }
        .onChange(of: selectedRound) {
            selectEMOMViewModel.setRounds(rounds: Int(selectedRound))
        }
        .navigationTitle("Rounds")
        .onAppear {
            fousedfield = true
            selectedRound = Double(selectEMOMViewModel.rounds )
        }
    }
}

#Preview {
    RoundsStepView(navPath: .constant(["RoundsStepView"]))
        .environmentObject(CreateCustomTimerViewModel())
        //.previewDevice("Apple Watch Series 7 - 41mm")
}
