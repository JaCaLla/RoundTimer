//
//  ContentView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

struct ActiveTimerView: View {
    @State private var isPresentingNewRoundTimerView = false
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "timer")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("No active timer")
                .fullScreenCover(isPresented: $isPresentingNewRoundTimerView) {
                    NewRoundTimerView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isPresentingNewRoundTimerView.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
    }
}

#Preview {
    ActiveTimerView()
}
