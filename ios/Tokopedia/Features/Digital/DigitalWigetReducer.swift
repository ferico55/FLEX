//
//  DigitalWigetReducer.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import ReSwift

internal enum DigitalWidgetAction: Action {
    case changePhoneNumber(textInput: DigitalTextInput, text: String)
    case selectProduct(DigitalProduct)
    case selectOperator(DigitalOperator?)
    case toggleInstantPayment
    case receiveForm(DigitalForm, DigitalLastOrder, Bool)
    case loadForm
    case loadFailed
    case showError(String)
    case resetErrorState
    case addToCart
    case navigateToCart
    case buyButtonTap
    case alert(String)
    case resetAlert
}

internal struct DigitalWidgetReducer: Reducer {
    internal func handleAction(action: Action, state: DigitalState?) -> DigitalState {
        guard let state = state else {
            fatalError("state must be set by default")
        }
        
        let action = action as! DigitalWidgetAction
        
        switch action {
        case let .changePhoneNumber(textInput, phoneNumber):
            var newState = state.inputText(for: textInput, with: phoneNumber)
            let normalizedPhoneNumber = textInput.normalizedText(from: phoneNumber)
            var textInputStates = [String: DigitalTextInputState]()
            
            state.activeTextInputs.forEach { textInput in
                textInputStates[textInput.id] = DigitalTextInputState(
                    text: normalizedPhoneNumber,
                    failedValidation: textInput.failedValidation(for: normalizedPhoneNumber)
                )
            }
            newState.textInputStates = textInputStates
            let shouldShowError = newState.textInputStates.contains(where: { (key, value) -> Bool in
                if key == "client_number" {
                    return value.text.isEmpty || value.failedValidation == nil
                } else {
                    return false
                }
            })
            if shouldShowError {
                newState.showErrorClientNumber = false
                newState.showErrors = false
            } else {
                newState.showErrorClientNumber = true
                newState.showErrors = true
            }
            return newState
            
        case let .selectProduct(product):
            var newState = state
            newState.selectedProduct = product
            return newState
            
        case let .selectOperator(digitalOperator):
            return state.changeOperator(operator: digitalOperator)
            
        case .toggleInstantPayment:
            return state.toggleInstantPayment()
            
        case let .receiveForm(form, lastOrder, isInstant):
            return state.receive(form: form, lastOrder: lastOrder, isInstant: isInstant)
            
        case .loadForm:
            return state.loadForm()
            
        case .loadFailed:
            return state.loadFailed()
            
        case let .showError(errorMessage):
            var newState = state
            newState.errorMessageState = .notShowing(errorMessage)
            newState.addToCartProgress = .idle
            
            return newState
            
        case .resetErrorState:
            var newState = state
            newState.errorMessageState = .noError
            
            return newState
            
        case .addToCart:
            var newState = state
            newState.addToCartProgress = .onProgress
            
            return newState
            
        case .navigateToCart:
            var newState = state
            newState.addToCartProgress = .idle
            
            return newState
            
        case .buyButtonTap:
            var newState = state
            
            var textInputStates = [String: DigitalTextInputState]()
            
            state.activeTextInputs.forEach { textInput in
                let text = state.textInputStates[textInput.id]?.text ?? ""
                
                textInputStates[textInput.id] = DigitalTextInputState(
                    text: text,
                    failedValidation: textInput.failedValidation(for: text)
                )
            }
            
            newState.textInputStates = textInputStates
            newState.showErrors = true
            return newState
            
        case let .alert(message):
            var newState = state
            newState.alertState = .message(message)
            return newState
            
        case .resetAlert:
            var newState = state
            newState.alertState = .idle
            
            return newState
        }
    }
}
