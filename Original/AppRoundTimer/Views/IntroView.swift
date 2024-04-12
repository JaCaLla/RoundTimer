//
//  IntroView.swift
//  AppRoundTimer
//
//  Created by Javier Calartrava on 30/3/24.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        ScrollView {
            Text("intro_paragraph_1")
            Image("intro_image_1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text("intro_paragraph_2")
            Image("intro_image_2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
    }
}

#Preview {
    IntroView()
}

#Preview("Dark mode") {
    IntroView()
        .preferredColorScheme(.dark)
}
