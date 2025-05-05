//
//  CreateCustomTimerViewModelUT.swift
//  EMOM timers Watch AppTests
//
//  Created by Javier Calatrava on 31/10/24.
//
@testable import EMOM_timers_Watch_App
import Testing

struct CreateCustomTimerViewModelUT {
    
    private func getSUT() -> CreateCustomTimerViewModel {
        CreateCustomTimerViewModel()
    }

    @Test func backFromRoundsStepView() {
        
        let viewModel = getSUT()
        #expect(viewModel.rounds == 5)
        // Given
        viewModel.setRounds(rounds: 8)
        #expect(viewModel.rounds == 8)
        // When
        viewModel.backFromRoundsStepView()
        // Then
        #expect(viewModel.rounds == 5)
    }

    @Test func setTimertype() {
        let viewModel = getSUT()
        // Given
        #expect(viewModel.timerType == .emom)
        // When
        viewModel.setTimertype(type: .upTimer)
        // Then
        #expect(viewModel.timerType == .upTimer)
    }
    
    @Test func backFromTimerPickerStepViewWork() {
        
        let viewModel = getSUT()
        #expect(viewModel.workSecs == 60)
        // Given
        viewModel.dismissFlowAndStartEMOM(pickerViewType: .work, selected: (2, 0))
        #expect(viewModel.workSecs == 120)
        // When
        viewModel.backFromTimerPickerStepViewWork()
        // Then
        #expect(viewModel.workSecs == 60)
    }
    
    @Test func backFromTimerPickerStepViewRest() {
        
        let viewModel = getSUT()
        #expect(viewModel.restSecs == 0)
        // Given
        viewModel.dismissFlowAndStartEMOM(pickerViewType: .rest, selected: (2, 0))
        #expect(viewModel.restSecs == 120)
        // When
        viewModel.backFromTimerPickerStepViewRest()
        // Then
        #expect(viewModel.restSecs == 0)
    }
    
    @Test func getEmom() {
        let viewModel = getSUT()
        #expect(viewModel.getEmom() == nil)
        viewModel.setRounds(rounds: 6)
        var expectedCustomTimer = CustomTimer(timerType: .emom, rounds: 6, workSecs: 60, restSecs: 120)
        viewModel.dismissFlowAndStartEMOM(pickerViewType: .rest, selected: (2, 0))
        var receivedCustomTimer = viewModel.getEmom()
        #expect(receivedCustomTimer == expectedCustomTimer)
        
         expectedCustomTimer = CustomTimer(timerType: .emom, rounds: 6, workSecs: 120, restSecs: 120)
        viewModel.dismissFlowAndStartEMOM(pickerViewType: .work, selected: (2, 0))
        receivedCustomTimer = viewModel.getEmom()
        #expect(receivedCustomTimer == expectedCustomTimer)
    }
    
    @Test func getHHMMSSIndexs() {
        let viewModel = getSUT()
        viewModel.dismissFlowAndStartEMOM(pickerViewType: .work, selected: (2, 0))
        var (mm, ss) = viewModel.getHHMMSSIndexs(pickerViewType: .work)
        #expect(mm == 2)
        #expect(ss == 0)
        
        viewModel.dismissFlowAndStartEMOM(pickerViewType: .rest, selected: (2, 10))
        (mm, ss) = viewModel.getHHMMSSIndexs(pickerViewType: .rest)
        #expect(mm == 2)
        #expect(ss == 10)
    }
    
    @Test func getContinueButtonText()  {
        let viewModel = getSUT()
        #expect(viewModel.getContinueButtonText() == "button_rest_next")
        
        viewModel.setTimertype(type: .upTimer)
        #expect(viewModel.getContinueButtonText() == "button_start_work")
    }
    
    @Test func getNavigationLink()  {
        let viewModel = getSUT()
        #expect(viewModel.getNavigationLink() == "TimerPickerStepViewRest")
        
        viewModel.setTimertype(type: .upTimer)
        #expect(viewModel.getNavigationLink() == "TimerPickerStepViewWork")
    }
}


/*
 func getContinueButtonText() -> LocalizedStringKey {
     timerType == .upTimer ? "button_start_work" : "button_rest_next"
 }
 
 func getNavigationLink() -> String {
     timerType == .upTimer ? Screens.timerPickerStepViewWork.rawValue  : Screens.timerPickerStepViewRest.rawValue
 }
 */
