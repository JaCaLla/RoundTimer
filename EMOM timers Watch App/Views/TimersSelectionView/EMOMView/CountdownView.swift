//
//  CountdownView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 19/2/24.
//

import SwiftUI

struct CountdownView: View {
    @State private var countdown = 3
    private var onComplete: () -> Void = { }

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Color.black
            Text("\(countdown)")
                .transition(.scale)
                .animation(.easeInOut(duration: 1))
                .onAppear {
                withAnimation {
                    self.startCountdown()
                }
            }
        }
            .font(.countDownFont)
            .foregroundColor(.roundColor)

    }

    func startCountdown() {
        AudioManager.shared.start()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.onComplete()
            }
        }
    }
}

#Preview {
    CountdownView(onComplete: { })
}
