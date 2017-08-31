//
//  DigitalState.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Render
import ReSwift

enum DigitalAddToCartProgress {
    case idle
    case onProgress
}

enum DigitalErrorState {
    case noError
    case notShowing(String)
}

enum DigitalAlertState {
    case idle
    case message(String)
}

struct DigitalTextInputState {
    let text: String
    let failedValidation: DigitalFieldValidation?
}

struct DigitalState: Render.StateType, ReSwift.StateType {
    var selectedOperator: DigitalOperator?
    var selectedProduct: DigitalProduct?
    var form: DigitalForm?
    var textInputStates: [String: DigitalTextInputState] = [:]
    var isInstantPaymentEnabled = false
    var isLoadingForm = false
    var isLoadingFailed = false
    var errorMessageState = DigitalErrorState.noError
    var addToCartProgress = DigitalAddToCartProgress.idle
    var showErrors = false
    var alertState = DigitalAlertState.idle
    var errorMessages = [String: String]()
    var selectedTab = 0
    
    var canAddToCart: Bool = true
    
    var activeTextInputs: [DigitalTextInput] {
        var allTextInputs = self.selectedOperator?.textInputs ?? []
        
        guard let operatorSelectionStyle = self.form?.operatorSelectonStyle else {
            return allTextInputs
        }
        
        if case let DigitalOperatorSelectionStyle.prefixChecking(input) = operatorSelectionStyle {
            allTextInputs.append(input)
        }
        
        return allTextInputs
    }
    
    var passesTextValidations: Bool {
        return self.activeTextInputs.first { textInput in
            textInput.failedValidation(for: textInputStates[textInput.id]?.text ?? "") != nil
        } == nil
    }
    
    func loadForm() -> DigitalState {
        var newState = self
        newState.isLoadingForm = true
        newState.isLoadingFailed = false
        
        return newState
    }
    
    func loadFailed() -> DigitalState {
        var newState = self
        newState.isLoadingForm = false
        newState.isLoadingFailed = true
        
        return newState
    }
    
    func changeOperator(operator: DigitalOperator?) -> DigitalState {
        var newState = self
        
        if self.selectedOperator !== `operator` {
            newState.selectedOperator = `operator`
            newState.selectedProduct = `operator`?.defaultProduct
            
            var textInputStates = [String: DigitalTextInputState]()
            if case let DigitalOperatorSelectionStyle.prefixChecking(textInput) = self.form!.operatorSelectonStyle {
                textInputStates[textInput.id] = self.textInputStates[textInput.id]
            }
            
            newState.textInputStates = textInputStates
        }
        
        newState.showErrors = false
        
        return newState
    }
    
    func inputText(for textInput: DigitalTextInput, with text: String) -> DigitalState {
        var newState = self
        newState.showErrors = false
        
        let normalizedText = textInput.normalizedText(from: text)
        
        if case let DigitalOperatorSelectionStyle.prefixChecking(input) = self.form!.operatorSelectonStyle, input.id == textInput.id {
            
            let selectedOperator = self.form!.operators.appropriateOperator(for: normalizedText)
            newState = self.changeOperator(operator: selectedOperator)
        }
        
        newState.textInputStates[textInput.id] = DigitalTextInputState(text: normalizedText, failedValidation: nil)
        return newState
    }
    
    func toggleInstantPayment() -> DigitalState {
        var newState = self
        newState.isInstantPaymentEnabled = !self.isInstantPaymentEnabled
        return newState
    }
    
    func receive(form: DigitalForm, lastOrder: DigitalLastOrder, isInstant: Bool) -> DigitalState {
        var newState = self
        newState.form = form
        newState.isLoadingForm = false
        
        var textInputStates = [String: DigitalTextInputState]()
        if case let DigitalOperatorSelectionStyle.prefixChecking(input) = form.operatorSelectonStyle {
            var normalizedText = ""
            if lastOrder.clientNumber != nil {
                normalizedText = input.normalizedText(from: lastOrder.clientNumber!)
            }
            
            let selectedOperator = form.operators.appropriateOperator(for: normalizedText)
            textInputStates[input.id] = DigitalTextInputState(text: normalizedText, failedValidation: input.failedValidation(for: normalizedText))
            newState.selectedOperator = selectedOperator
            
            if let op = selectedOperator {
                newState.selectedProduct = selectProduct(fromOperator: op, orProductId: lastOrder.productId)
            }
        } else {
            if lastOrder.clientNumber != nil {
                textInputStates["client_number"] = DigitalTextInputState(text: lastOrder.clientNumber!, failedValidation: nil)
            }
            
            let operators = selectedOperator(fromForm: form, orOperatorId: lastOrder.operatorId)
            newState.selectedOperator = operators
            if let op = operators {
                newState.selectedProduct = self.selectProduct(fromOperator: op, orProductId: lastOrder.productId)
            }
        }
        newState.textInputStates = textInputStates
        newState.isInstantPaymentEnabled = isInstant
        return newState
    }
    
    func selectProduct(fromOperator: DigitalOperator, orProductId: String?) -> DigitalProduct? {
        return fromOperator.products.filter { $0.id == orProductId }.first ?? fromOperator.products.filter { $0.id == fromOperator.defaultProductId }.first
    }
    
    func selectedOperator(fromForm: DigitalForm, orOperatorId: String?) -> DigitalOperator? {
        return fromForm.operators.filter { $0.id == orOperatorId }.first ?? fromForm.defaultOperator
    }
    
    func selectedTab(tab: Int) -> DigitalState {
        var newState = self
        newState.selectedTab = tab
        return newState
    }
}
