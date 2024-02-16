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
                    } else {
                        Text(model.chronoFrozen)
                            .foregroundStyle(model.getForegroundTextColor())
                    }
                }
                .font(model.getTimerAndRoundFont())
                Gauge(value: model.percentage, label: { })
                    .tint(.roundColor)
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y: 0.25)
            }
            Spacer(minLength: 7)
            HStack {
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
            .onChange(of: model.roundsLeft) {
            print(".")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EMOMView()
    }
}
