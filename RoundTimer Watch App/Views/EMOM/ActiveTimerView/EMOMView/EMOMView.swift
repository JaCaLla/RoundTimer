import SwiftUI

struct EMOMView: View {
    let bottonSideSize = 50.0
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var model: EMOMViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    model.close()
                }, label: {
                        Image(systemName: "xmark")
                    })
                    .modifier(ButtonAW())
                Spacer()
            }

            Spacer()
            VStack(spacing: 0) {
                Text("\(model.getCurrentMessage())")
                    .font(.messageFont)
                HStack {
                    Text("\(model.getCurrentRound())")
                        .foregroundColor(.roundColor)
                    Spacer()
                    if let endOfRound = model.chronoOnMove {
                        Text("\(endOfRound, style: .timer)")
                            .foregroundStyle(model.getForegroundTextColor())
                            .allowsTightening(true)
                    } else {
                        Text(model.chronoFrozen)
                            .foregroundStyle(model.getForegroundTextColor())
                    }
                }
                .font(model.getTimerAndRoundFont())
                Gauge(value: model.getRoundsProgress(), label: { })
                    .tint(.roundColor)
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y: 0.25)
            }
            Spacer(minLength: 7)
            HStack(spacing: 5) {
                Button(action: {
                    model.action()
                }, label: {
                        Image(systemName: model.actionIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: bottonSideSize, height: bottonSideSize)
                    })
                    .foregroundStyle(model.actionButtonColor())
                    .frame(width: bottonSideSize, height: bottonSideSize)
                    .clipShape(Circle())
            }
            Spacer(minLength: 15)
        }.background(model.getBackground())
            .onChange(of: scenePhase) { print($0) }
        .overlay {
            if model.showCountDownView {
                CountdownView {
                    //model.showCountDownView = false
                    model.startWorkTime()
                }
            }
        }
    }
}

struct ButtonAW: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 25, height: 25)
            .foregroundColor(Color.white)
            .clipShape(Circle())
    }
}



#Preview("Small Font") {
    let model =  EMOMViewModel()
    model.set(emom: Emom(rounds: 22, workSecs: 1800, restSecs: 0))
    return EMOMView()
        .environmentObject(model)
}

#Preview("Regular Font") {
    let model =  EMOMViewModel()
    model.set(emom: Emom(rounds: 2, workSecs: 1800, restSecs: 0))
    return EMOMView()
        .environmentObject(model)
}

#Preview("Large Font") {
    let model =  EMOMViewModel()
    model.set(emom: Emom(rounds: 2, workSecs: 200, restSecs: 0))
    return EMOMView()
        .environmentObject(model)
}
