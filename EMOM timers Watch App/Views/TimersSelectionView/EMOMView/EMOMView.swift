import SwiftUI

//struct foregroundColorModifier: ViewModifier {
//    let color: Color
//    let isLowEnergy: Bool
//    func body(content: Content) -> some View {
//        if isLowEnergy {
//            content
//                .foregroundColor(color.opacity(0.16))
//                //.shadow(color: color, radius: 1)
//        } else {
//            content
//                .foregroundColor(color)
//             //   .shadow(color: color, radius: 1)
//        }
//
//    }
//}
//
//extension View {
//    func foregroundColor(color: Color, isLowEnergy: Bool) -> some View {
//        modifier(foregroundColorModifier(color: color, isLowEnergy: isLowEnergy))
//    }
//}

struct EMOMView: View {
    let bottonSideSize = 50.0
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Binding var customTimer: CustomTimer?
    @Binding var closedFromCompation: Bool
    @StateObject var viewModel = EMOMViewModel()
  //  @State private var isLowEnergy = false
    var boolClosedByUser = false
    var body: some View {
        VStack(spacing: 0) {
          //  if !isLowerEnergyMode() {
                HStack {
                    Button(action: {
                        //emomViewModel.close()
                        customTimer = nil
                    }, label: {
                        Image(systemName: "xmark")
                    })
                    .modifier(ButtonAW())
                    Spacer()
                }
         //   }
            Spacer()
           // Toggle("LEM", isOn: $isLowEnergy)
            VStack(spacing: 0) {
                Text("\(viewModel.getCurrentMessage())")
                    .font(.messageFont)
                    .foregroundColor(.paragrahColor)
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("\(viewModel.getCurrentRound())")
                            .foregroundColor(.roundColor)
                        Text("\(viewModel.getRounds())")
                            .foregroundColor(.roundColor)
                            .font(.emomRounds)
                    }
                    .font(viewModel.getTimerAndRoundFont())
                    Spacer()
                    VStack {
                        if let chronoOnMove = viewModel.chronoOnMove,
                           !isLuminanceReduced {
                                Text("\(chronoOnMove, style: .timer)")
                                .foregroundStyle(viewModel.getForegroundTextColor())
                                    .allowsTightening(true)
                        } else {
                            Text(viewModel.chronoFrozen)
                                .foregroundStyle(viewModel.getForegroundTextColor())
                        }
                    }
                    .font(viewModel.getTimerAndRoundFont())
                //    .privacySensitive()
                }
                
                Gauge(value: viewModel.getRoundsProgress(), label: { })
                    .tint(.roundColor)
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y: 0.25)
            }
            Spacer(minLength: 7)
//            if isLowerEnergyMode() {
//                HStack {
//                    Image(systemName: "battery.25percent")
//                    Text("Screen dimmed. Tap to unblock.")
//                }.frame(height: 50)
//            } else {
                HStack {
                    HeartZoneView()
                    Spacer()
                }
//                Button(action: {
//                    emomViewModel.action()
//                }, label: {
//                        Image(systemName: emomViewModel.getActionIcon())
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: bottonSideSize, height: bottonSideSize)
//                    })
//                    .foregroundStyle(emomViewModel.actionButtonColor())
//                    .frame(width: bottonSideSize, height: bottonSideSize)
//                    .clipShape(Circle())
 //           }
            Spacer(minLength: 15 - 10)
        }.background(viewModel.getBackground())
//            .opacity(isLuminanceReduced ? AppUIConstants.opacityWhenLuminanceReduced : 1.0)
            .onAppear {
              //  print(" >>>> EMOMView. emomViewModel.set(emom:) state:\(emomViewModel.state)")
                guard viewModel.state == .notStarted else {
                    print(" >>>> EMOMView. NOT VALID STATE FOR START TIMER!!!")
                    return
                }
                viewModel.set(emom: customTimer)
                viewModel.action()
            }.onDisappear {
                viewModel.close()
            }
            .onChange(of: closedFromCompation) {
                guard closedFromCompation else { return }
                viewModel.close()
            }
//            .onChange(of: isLowEnergy) {
//                viewModel.lowEnergyMode(value: isLowEnergy)
//            }
    }
    
//    private func isLowerEnergyMode() -> Bool {
//        //isLowEnergy
//        isLuminanceReduced ? true : isLowEnergy
//    }
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
    let model =  EMOMViewModel()
 //   model.set(emom: CustomTimer(timerType: .emom,rounds: 12, workSecs: 200, restSecs: 0))
    return EMOMView(customTimer: .constant(nil), closedFromCompation: .constant(false))
   //     .environmentObject(model)
}
