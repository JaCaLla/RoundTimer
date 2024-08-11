//
//  CreateCustomTimerView2.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 16/5/24.
//

import SwiftUI

struct CreateCustomTimerView: View {
 //   @Environment(\.dismiss) var dismiss
    @Binding var customTimer: CustomTimer?
    @Binding var isConnectedAW: Bool
    let pickerSize = 200.0
    @State private var isRestOn = false
    @State private var isFetchingAW = false
    @StateObject var viewModel = CreateCustomTimerViewModel()
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                CreateCustomTimerWorkRestToggleView(isRestOn: $isRestOn)
                Spacer(minLength: 140)
                DismissButton()
            }
            HStack {
                CreateCustomTimerPickerView(title: String(localized: "picker_rounds"),
                    color: .roundColor,
                    min: viewModel.minRounds,
                    max: viewModel.maxRounds,
                    format: "%d",
                    value: $viewModel.selectedIndexRounds)
                    .frame(width: pickerSize, height: pickerSize)
                Spacer(minLength: 150)
                if isRestOn {
                    CreateCustomTimerMMSSPickerView(selectedMins: $viewModel.selectedRestMins, selectedSecs: $viewModel.selectedRestSecs, isRestOn: isRestOn)
                } else {
                    CreateCustomTimerMMSSPickerView(selectedMins: $viewModel.selectedWorkMins, selectedSecs: $viewModel.selectedWorkSecs, isRestOn: isRestOn)
                }
            }
            Spacer()
//            ZStack {
//                if isFetchingAW {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        .scaleEffect(2.0, anchor: .center)
//                }
                HStack() {
                    if isConnectedAW {
                        Button {
                            viewModel.createChronoMirroredInAW.toggle()
                        } label: {
                            Image(systemName: viewModel.imageConnectionAW())
                                .modifier(ButtonStyle())
                        }
                    }
                        Spacer()
                        CreateCustomTimerContinueButton(isFetchingAW: $isFetchingAW,
                                                        customTimer: $customTimer, createChronoMirroredInAW: viewModel.createChronoMirroredInAW)
                            .environmentObject(viewModel)

                }
      //      }
        }
          //  .pickerStyle(.wheel)
            .task {
            await viewModel.onAppearActions()
        }
            .background(Color.defaultBackgroundColor)
    }
}

struct CreateCustomTimerWorkRestToggleView: View {
    @Binding var isRestOn: Bool
    var body: some View {
        HStack {
            Spacer()
            Text(isRestOn ? String(localized: "title_rest") : String(localized: "title_work"))
            Toggle("", isOn: $isRestOn)
                .toggleStyle(SwitchToggleStyle(tint: isRestOn ? .timerRestStartedColor : .timerStartedColor))
                .frame(width: 100)
        }.foregroundColor(isRestOn ? .timerRestStartedColor : .timerStartedColor)
            .font(.pickerSelectionFont)
    }
}

//#Preview {
//    CreateCustomTimerView(customTimer: .constant(CustomTimer.customTimerDefault))
//}
