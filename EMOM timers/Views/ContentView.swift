//
//  ContentView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 10/4/24.
//

import SwiftUI

struct ContentView: View {
    let connectivity = Connectivity.shared
    var body: some View {
        VStack(spacing: -50 /*+ 50*/){
            VStack{
                TabView {
                    IntroView()
                    EMOMTimerView()
                    TimerUpView()
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
    ContentView()
}
