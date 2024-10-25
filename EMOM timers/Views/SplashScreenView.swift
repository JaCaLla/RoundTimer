//
//  SplashScreenView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 17/8/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Image("splash") // Replace with your logo
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            Text(String(localized: "splash_title"))
                .foregroundColor(.splashText)
                .font(.splashAppFont)
        }
    }
}

#Preview {
        SplashScreenView()
}
