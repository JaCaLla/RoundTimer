//
//  RoundsStepView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

struct RoundsStepView: View {
    private let rounds = 5
    @Binding var navPath: [String]
    @Environment(\.dismiss) var dismiss
     var body: some View {
        VStack {
            Spacer()
            Text("\(rounds)")
            Spacer()
            NavigationLink(value: "TimerPickerStepViewWork") {
                Text("Next >")
            }
            Spacer()
        }
        .navigationTitle("Rounds")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    dismiss()
                }, label: {
                        Image(systemName: "xmark.circle")
                    })
            }
        }
    }
}

#Preview {
    RoundsStepView(navPath: .constant(["RoundsStepView"]))
}

