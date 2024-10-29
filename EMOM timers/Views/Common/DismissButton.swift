//
//  DismissButton.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 8/7/24.
//

import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button(action: {
            dismiss()
        }, label: {
            Image(systemName: "xmark")
        })
        .modifier(ButtonAW())
    }
}
