//
//  SplashScreenView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 17/8/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Image(systemName: "sparkles") // Replace with your logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
            
            Text("Welcome to MyApp")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .forceRotation(orientation: .landscape)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
       // .background(Color.white) // Customize background color
        .edgesIgnoringSafeArea(.all)
    }
}
