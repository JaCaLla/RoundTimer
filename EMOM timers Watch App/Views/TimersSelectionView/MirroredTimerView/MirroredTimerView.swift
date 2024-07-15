//
//  MirroredView.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 13/7/24.
//

import SwiftUI

struct MirroredTimerView: View {
    @Binding var mirroredTimer: MirroredTimer?
    @Binding var closedFromCompation: Bool
    @StateObject var viewModel: MirroredTimerViewModel = MirroredTimerViewModel()
    var body: some View {
        VStack(spacing: 0) {
//            Text("\(viewModel.getCurrentMessage())")
//                .font(.messageFont)
            HStack {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(viewModel.getCurrentRound())")
                        .foregroundColor(.roundColor)
                    Text("\(viewModel.getRounds())")
                        .font(.emomRounds)
                        .foregroundColor(.roundColor)
                }
                .font(viewModel.getTimerAndRoundFont())
                Spacer()
                VStack {
                    if let chronoOnMove = viewModel.chronoOnMove {
                        Text("\(chronoOnMove, style: .timer)")
                            .foregroundStyle(viewModel.getForegroundTextColor())
                            .allowsTightening(true)
                    } else {
                        Text(viewModel.chronoFrozen)
                            .foregroundStyle(viewModel.getForegroundTextColor())
                    }
                }
                .font(viewModel.getTimerAndRoundFont(isLuminanceReduced: false))
            }
            
            Gauge(value: viewModel.getRoundsProgress(), label: { })
                .tint(.roundColor)
                .gaugeStyle(.accessoryLinearCapacity)
                .scaleEffect(x: 1.0, y: 0.25)
        }
        .onAppear {
            guard let mirroredTimer else { return }
            viewModel.set(mirroredTimer: mirroredTimer)
        }
        .onChange(of: mirroredTimer) {
            guard let mirroredTimer else { return }
            LocalLogger.log("MirroredTimerView.mirroredTimer \(mirroredTimer)")
            viewModel.set(mirroredTimer: mirroredTimer)
        }
        .onChange(of: closedFromCompation) {
            guard closedFromCompation else { return }
            mirroredTimer = nil
            viewModel.close()
        }
    }
}

#Preview {
    //let viewModel = MirroredTimerViewModel(mirroredTimer: .countdown5)
    return MirroredTimerView(mirroredTimer: .constant(.countdown5), closedFromCompation: .constant(false))
}

extension MirroredTimerCountdown {
    static let countdown5 = MirroredTimerCountdown(value: 5)
}

extension MirroredTimer {
    static let countdown5 = MirroredTimer(mirroredTimerType: .countdown, mirroredTimerCountdown: .countdown5)
}
