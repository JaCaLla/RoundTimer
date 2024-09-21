import SwiftUI

struct EMOMView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Binding var customTimer: CustomTimer?
    @Binding var closedFromCompation: Bool
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
                    rounds()
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
        .onChange(of: closedFromCompation) {
            guard closedFromCompation else { return }
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
    
    private func rounds() -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(viewModel.getCurrentRound())")
                .font(viewModel.getTimerAndRoundFont())
            Text("\(viewModel.getRounds())")
                .font(.emomRounds)
        }
        .foregroundColor(.roundColor)
    }
    
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


#Preview("Small Font") {
    // let model =  EMOMViewModel()
    //  model.set(emom: CustomTimer(timerType: .emom,rounds: 22, workSecs: 1800, restSecs: 0))
    return EMOMView(customTimer: .constant(nil), closedFromCompation: .constant(false))
    //    .environmentObject(model)
}

#Preview("Regular Font") {
    //let model =  EMOMViewModel()
    // model.set(emom: CustomTimer(timerType: .emom,rounds: 2, workSecs: 1800, restSecs: 0))
    return EMOMView(customTimer: .constant(nil), closedFromCompation: .constant(false))
    //   .environmentObject(model)
}

#Preview("Large Font") {
    //let model = EMOMViewModel()
    //   model.set(emom: CustomTimer(timerType: .emom,rounds: 12, workSecs: 200, restSecs: 0))
    return EMOMView(customTimer: .constant(nil), closedFromCompation: .constant(false))
    //     .environmentObject(model)
}
