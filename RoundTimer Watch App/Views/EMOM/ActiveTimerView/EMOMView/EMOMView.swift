//
//  EMOMView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 21/1/24.
//

import SwiftUI

struct EMOMView: View {
    let bottonSideSize = 40.0
    @EnvironmentObject var emomViewModel: EMOMViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    emomViewModel.close()
                }, label: {
                    Image(systemName: "xmark")
                })
                .modifier(ButtonAW())
                Spacer()
            }
            Spacer()
            VStack(spacing: -10) {
                HStack {
                    if emomViewModel.hasToShow() {
                        Text("WORK")
                    }
                    Spacer()
                    if emomViewModel.hasToShow(work: false) {
                        Text("REST")
                    }
                }
                .frame(height: 10)
                .font(.system(size: 10, weight: .black))
                HStack {
                    if !emomViewModel.isTrailingChronoAlignment() {
                        Spacer()
                    }
                    Text("\(emomViewModel.chrono)")
                        .foregroundStyle(emomViewModel.getForegroundTextColor())
                        .font(.system(size: 50, weight: .black))
                        .scaleEffect(emomViewModel.isPaused ? 2.0 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.5).reverse(on: $emomViewModel.isPaused, delay: 0.5))
                    if emomViewModel.isTrailingChronoAlignment() {
                        Spacer()
                    }
                }
                Gauge(value: emomViewModel.percentage, label: { })
                    .gaugeStyle(.accessoryLinearCapacity)
                    .scaleEffect(x: 1.0, y: 0.25)
            }
            HStack(alignment: .top) {
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("TIME CAP")
                                .font(.system(size: 10, weight: .black))
                            Text("\(emomViewModel.getPending())")
                                .foregroundStyle(emomViewModel.getForegroundTextColor())
                                .font(.system(size: 15, weight: .black))
                        }
                        Spacer()
                    }
                    Spacer()
                }
                Divider().frame(width: 1)
                VStack {
                    Text("ROUNDS")
                        .font(.system(size: 10, weight: .black))
                    Gauge(value: emomViewModel.getProgressGauge(), label: {
                        Text(emomViewModel.getProgressRounds())
                            .foregroundStyle(emomViewModel.getForegroundTextColor())
                    }
                    ).gaugeStyle(.accessoryCircularCapacity)
                    Spacer()
                }
            }
            .frame(height: 70)
            Divider()
            Spacer(minLength: 7)
            HStack {
                Button(action: {
                    emomViewModel.action()
                }, label: {
                    Image(systemName: emomViewModel.actionIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: bottonSideSize, height: bottonSideSize)
                })
                .frame(width: bottonSideSize, height: bottonSideSize)
                .clipShape(Circle())
            }
            Spacer(minLength: 15)
        }
        .padding(3)
        .background(emomViewModel.getBackground())
        
    }
    
    struct ButtonAW: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(width: 25, height: 25)
                .foregroundColor(Color.white)
                .clipShape(Circle())
        }
    }
}

extension Animation {
    func reverse(on: Binding<Bool>, delay: Double) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            on.wrappedValue = false /// Switch off after `delay` time
        }
        return self
    }
}

#Preview("Not started") {
    let model = EMOMViewModel()
    let emom: Emom = .sample16rounds50Work10Rest
    model.set(emom: emom)
    
    return EMOMView()
        .environmentObject(model)
}
