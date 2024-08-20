//
//  PickerView.swift
//  RoundTimer Watch App
//
//  Created by Javier Calartrava on 17/1/24.
//

import SwiftUI

enum TimerPickerStepViewType {
    case work, rest

    var navigationTitle: String {
        switch self {
        case .work: return String(localized: "title_work")
        case .rest: return String(localized:"title_rest")
        }
    }
}

struct TimerPickerStepView: View {

    @Binding var navPath: [String]
    var pickerViewType: TimerPickerStepViewType
    @FocusState private var fousedfield: Bool
    @State private var selected: (mins:Int, secs: Int) = (0, 30)
    @EnvironmentObject var viewModel: CreateCustomTimerViewModel

    let pickerHeight = 100.0
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Picker(String(localized: "picker_minutes"), selection: $selected.mins) { ForEach(0..<60) { Text("\(String(format: "%0.1d", $0))") }
                    }
                    .focused($fousedfield)
                    .frame(height: pickerHeight)
                Picker(String(localized: "picker_seconds"), selection: $selected.secs) { ForEach(0..<60) { Text("\(String(format: "%0.2d", $0))") }
                }
                    .frame(height: pickerHeight)
            }
                .pickerStyle(.wheel)
                .foregroundColor(pickerViewType == .work ? .timerStartedColor : .timerRestStartedColor)
                .font(.pickerSelectionFont)
            Spacer()
            if pickerViewType == .work,
               !(selected.mins == 0 && selected.secs == 0) {
                NavigationLink(value: viewModel.getNavigationLink()) {
                    Group {
                        Text(viewModel.getContinueButtonText()) + Text(Image(systemName: "chevron.right"))
                    }
                    .font(.buttonSubtitleFont)
                }
                    .simultaneousGesture(TapGesture().onEnded {
                        if viewModel.timerType == .upTimer {
                            dismissFlowAndStartEMOM()
                        } else {
                            let secs = selected.mins * 60 + selected.secs
                            viewModel.workSecs = secs
                        }
                    })
            } else if pickerViewType == .rest {
                Button(action: {
                    dismissFlowAndStartEMOM()
                }, label: {
                    Text(String(localized: "button_start_work"))
                        .font(.buttonSubtitleFont)
                    })
            }
        }
       // este string localized es que el que hace que falle.
        .navigationTitle(pickerViewType.navigationTitle)
            .toolbar {
            if pickerViewType == .work {
                // TO DO: NO SE PUEDE PONER EL BOTÓN POR QUE NO SE PUEDE DISTINGUIR
                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        dismissFlowAndStartEMOM()
//                    }, label: {
//                            Image(systemName: "checkmark.circle")
//                        })
                }
            } else if pickerViewType == .rest {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        navPath.removeAll()
                    }, label: {
                            Image(systemName: "xmark.circle")
                        })
                }
            }
        }.onAppear {
            fousedfield = true
            selected = viewModel.getHHMMSSIndexs(pickerViewType: pickerViewType)
        }
    }

    private func dismissFlowAndStartEMOM() {
        navPath.removeAll()
        viewModel.dismissFlowAndStartEMOM(pickerViewType: pickerViewType,selected: selected)
    }
}

#Preview("Work") {
    TimerPickerStepView(navPath: .constant([CreateCustomTimerViewModel.Screens.roundsStepView.rawValue, CreateCustomTimerViewModel.Screens.timerPickerStepViewWork.rawValue]), pickerViewType: .work)
        .environmentObject(CreateCustomTimerViewModel())

}

//#Preview("Rest") {
//    TimerPickerStepView(navPath: .constant([]), pickerViewType: .rest)
//        .environmentObject(SelectEMOMViewModel())
//}
