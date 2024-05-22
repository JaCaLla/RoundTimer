//
//  ContentView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 10/4/24.
//

import SwiftUI

struct HelpView: View {
    let connectivity = Connectivity.shared
    var body: some View {
        VStack(spacing: -50 /*+ 50*/){
            VStack{
                Button("AddMessage (fromContentView)") {
                  //  TrackingsManager.shared.log(eventName: "ButtonTapped", metadata: nil)
                    LocalPersitenceManager.shared.add(message: "fromContentView")
                }
                TabView {
                    IntroView()
                    EMOMTimerView()
                    TimerUpView()
                    ReceivedWatchOSMessagesView()
                }
                .ignoresSafeArea()
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
            }
        }.background {
            Image("background").resizable().aspectRatio(contentMode: .fill)
                .frame(height: 1500)
               
        }            .foregroundColor(.paragrahColor)
            .font(.paragraph)
    }
}

#Preview {
    HelpView()
}
