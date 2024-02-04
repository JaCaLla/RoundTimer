//
//  RoundsStepView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

struct RoundsStepView: View {
    
    @State private var pickerRoundIndex = 0
    @FocusState private var fousedfield: Bool
    @Binding var navPath: [String]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var selectEMOMViewModel: SelectEMOMViewModel
   // let roundsRange = Array(1..<60)
    @State private var number: Double = 2.0
    var body: some View {
        VStack {
            Spacer()
            Text("\(Int(number))")
                .font(.system(size: 70,weight: .black))
              .focusable()
              .focused($fousedfield)
              .digitalCrownRotation($number, from: 2.0, through: 50.0, by:1.0, sensitivity: .medium,
                                    isHapticFeedbackEnabled: true)
//            Picker("Rounds", selection: $pickerRoundIndex ) {
//                ForEach(0..<roundsRange.count) {
//                    Text("\(roundsRange[$0])")
//                     //   .font(.system(size: 40,weight: .black))
//                        //.fontWeight(.black)
//                }
//            }
//            .pickerStyle(.wheel)
//            .frame(width: 80, height: 100)
//            .focused($fousedfield)
            
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
        .onChange(of: number, initial: true) { _, newValue in
            selectEMOMViewModel.rounds = Int(number)//roundsRange[pickerRoundIndex]
        }
        .navigationTitle("Rounds")
        .onAppear {
            fousedfield = true
//            pickerRoundIndex = roundsRange.firstIndex(where: { selectEMOMViewModel.rounds == $0} ) ?? 0
        }
    }
}

#Preview {
    RoundsStepView(navPath: .constant(["RoundsStepView"]))
        .environmentObject(SelectEMOMViewModel())
        .previewDevice("Apple Watch Series 7 - 41mm")
}
