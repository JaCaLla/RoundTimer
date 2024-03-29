//
//  RoundsStepView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

enum RoundStepViewType {
    case round, work, rest

    var navigationTitle: String {
        switch self {
        case .work: "Work"
        case .rest: "Rest"
        case .round: "Round"
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
    
    @State private var pickerRoundIndex = 0
    @FocusState private var fousedfield: Bool
    @Binding var navPath: [String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var selectEMOMViewModel: SelectEMOMViewModel
   // let roundsRange = Array(1..<60)
    @State private var selectedRound: Double = 2.0
    var body: some View {
        VStack {
            Spacer()
            Text("\(Int(selectedRound))")
                .foregroundColor(.roundColor)
                .font(.roundInputFont)
              .focusable()
              .focused($fousedfield)
              .digitalCrownRotation($selectedRound, from: 2.0, through: 50.0, by:1.0, sensitivity: .medium,
                                    isHapticFeedbackEnabled: true)            
            Spacer()
            if selectEMOMViewModel.rounds > 0 {
                NavigationLink(value: SelectEMOMViewModel.Screens.timerPickerStepViewWork.rawValue) {
                    Text("Next ... >")
                        
                }
                
                Spacer()
            } 
        }
       /// .font(.system(size: 30,weight: .black))
       // .defaultFocus($fousedfield, .rounds)
        .onChange(of: selectedRound, initial: true) { _, newValue in
            selectEMOMViewModel.rounds = Int(selectedRound)//roundsRange[pickerRoundIndex]
        }
        .navigationTitle("Rounds")
        .onAppear {
            fousedfield = true
            selectedRound = Double(selectEMOMViewModel.rounds )
//            pickerRoundIndex = roundsRange.firstIndex(where: { selectEMOMViewModel.rounds == $0} ) ?? 0
        }
    }
}

#Preview {
    RoundsStepView(navPath: .constant(["RoundsStepView"]))
        .environmentObject(SelectEMOMViewModel())
        .previewDevice("Apple Watch Series 7 - 41mm")
}
