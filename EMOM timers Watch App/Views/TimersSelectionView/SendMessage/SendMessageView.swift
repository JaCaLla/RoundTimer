//
//  SendMessageView.swift
//  EMOM timers Watch App
//
//  Created by Javier Calartrava on 1/5/24.
//

import SwiftUI

struct SendMessageView: View {
    var body: some View {
        Button {
            Connectivity.shared.send(message: "patata", delivery: .guaranteed)
        } label: {
            Text("SendMessage")
        }
    }
}

#Preview {
    SendMessageView()
}
