//
//  ContentView.swift
//  AppRoundTimer
//
//  Created by Javier Calartrava on 30/3/24.
//

import SwiftUI

struct ContentView: View {
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
