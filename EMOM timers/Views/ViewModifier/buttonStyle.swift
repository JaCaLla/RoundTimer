//
//  buttonStyle.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 8/7/24.
//

import SwiftUI

//extension View {
//    func buttonStyle() -> some View {
//        font(.buttoniOSAppFont)
//        .padding()
//        .foregroundStyle(Color.buttonTextColor)
//        .background(Color.roundColor)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//    }
//}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.buttoniOSAppFont)
                .padding()
                .foregroundStyle(Color.buttonTextColor)
                .background(Color.roundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
