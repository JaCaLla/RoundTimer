import SwiftUI

struct EMOMView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Binding var customTimer: CustomTimer?
    @StateObject var viewModel = EMOMViewModel()
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                closeButton()
                Spacer()
            }
            Spacer()
            VStack(spacing: 0) {
                message()
                HStack {
                    rounds
                    Spacer()
                    mmss()
                }
                progress()
            }
            Spacer(minLength: 7)
            HStack {
                HeartZoneView()
                Spacer()
            }
            Spacer(minLength: 5)
        }
        .onAppear {
            guard viewModel.hasNotStarted() else { return }
            viewModel.set(emom: customTimer)
        }
        .onDisappear {
            viewModel.close()
        }
    }
    
    private func closeButton() -> some View {
        Button(action: {
            customTimer = nil
        }, label: {
            Image(systemName: "xmark")
        })
        .buttonAWStyle()
    }
    
    private func message() -> some View {
        Text("\(viewModel.getCurrentMessage())")
            .font(.messageFont)
            .foregroundColor(.paragrahColor)
    }
    
//    private func rounds() -> some View {
//        guard let timerType = customTimer?.timerType else { return EmptyView() }
//        switch timerType {
//        case .emom:
//           return HStack(alignment: .firstTextBaseline, spacing: 0) {
//                Text("\(viewModel.getCurrentRound())")
//                    .font(viewModel.getTimerAndRoundFont())
//                Text("\(viewModel.getRounds())")
//                    .font(.emomRounds)
//            }
//            .foregroundColor(.roundColor)
//        case .upTimer:
//           return  HStack(alignment: .firstTextBaseline, spacing: 0) {
//                Text(String(localized: "up_indicator"))
//                    .font(viewModel.getTimerAndRoundFont())
//            }
//            .foregroundColor(.roundColor)
//        }
//
//    }
    
    private func mmss() -> some View {
        Text(viewModel.chronoFrozen)
            .foregroundStyle(viewModel.getForegroundTextColor())
            .font(viewModel.getTimerAndRoundFont())
    }
    
    private func progress() -> some View {
        Gauge(value: viewModel.getRoundsProgress(), label: { })
            .tint(.roundColor)
            .gaugeStyle(.accessoryLinearCapacity)
            .scaleEffect(x: 1.0, y: 0.25)
    }
}

private extension EMOMView {
    @ViewBuilder var rounds: some View {
        if let timerType = customTimer?.timerType {
            switch timerType {
            case .emom:
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(viewModel.getCurrentRound())")
                        .font(viewModel.getTimerAndRoundFont())
                    Text("\(viewModel.getRounds())")
                        .font(.emomRounds)
                }
                .foregroundColor(.roundColor)
            case .upTimer:
                 HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(String(localized: "up_indicator"))
                        .font(viewModel.getTimerAndRoundFont())
                }
                .foregroundColor(.roundColor)
            }
        }
    }
}


#Preview("Small Font") {
    return EMOMView(customTimer: .constant(nil))
}

#Preview("Regular Font") {
    return EMOMView(customTimer: .constant(nil))
}

#Preview("Large Font") {
    return EMOMView(customTimer: .constant(nil))
}
