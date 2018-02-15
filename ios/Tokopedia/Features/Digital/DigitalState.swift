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

internal enum DigitalAddToCartProgress {
    case idle
    case onProgress
}

internal enum DigitalErrorState {
    case noError
    case notShowing(String)
}

internal enum DigitalAlertState {
    case idle
    case message(String)
}

internal struct DigitalTextInputState {
    internal let text: String
    internal let failedValidation: DigitalFieldValidation?
}

internal struct DigitalState: Render.StateType, ReSwift.StateType {
    internal var selectedOperator: DigitalOperator?
    internal var selectedProduct: DigitalProduct?
    internal var form: DigitalForm?
    internal var textInputStates: [String: DigitalTextInputState] = [:]
    internal var isInstantPaymentEnabled = false
    internal var isLoadingForm = false
    internal var isLoadingFailed = false
    internal var errorMessageState = DigitalErrorState.noError
    internal var addToCartProgress = DigitalAddToCartProgress.idle
    internal var showErrors = false
    internal var showErrorClientNumber = false
    internal var alertState = DigitalAlertState.idle
    internal var errorMessages = [String: String]()
    internal var favourites: [DigitalFavourite] = []
    
    internal var canAddToCart: Bool = true
    
    internal var activeTextInputs: [DigitalTextInput] {
        var allTextInputs = self.selectedOperator?.textInputs ?? []
        
        guard let operatorSelectionStyle = self.form?.operatorSelectonStyle else {
            return allTextInputs
        }
        
        if case let DigitalOperatorSelectionStyle.prefixChecking(input) = operatorSelectionStyle {
            allTextInputs.append(input)
        }
        
        return allTextInputs
    }
    
    internal var passesTextValidations: Bool {
        return self.activeTextInputs.first { textInput in
            textInput.failedValidation(for: textInputStates[textInput.id]?.text ?? "") != nil
        } == nil
    }
    
    internal func loadForm() -> DigitalState {
        var newState = self
        newState.isLoadingForm = true
        newState.isLoadingFailed = false
        
        return newState
    }
    
    internal func loadFailed() -> DigitalState {
        var newState = self
        newState.isLoadingForm = false
        newState.isLoadingFailed = true
        
        return newState
    }
    
    internal func changeOperator(operator: DigitalOperator?) -> DigitalState {
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
        
        return newState
    }
    
    internal func inputText(for textInput: DigitalTextInput, with text: String) -> DigitalState {
        var newState = self
        
        let normalizedText = textInput.normalizedText(from: text)
        
        if case let DigitalOperatorSelectionStyle.prefixChecking(input) = self.form!.operatorSelectonStyle, input.id == textInput.id {
            
            let selectedOperator = self.form!.operators.appropriateOperator(for: normalizedText)
            newState = self.changeOperator(operator: selectedOperator)
        }
        
        newState.textInputStates[textInput.id] = DigitalTextInputState(text: normalizedText, failedValidation: nil)
        return newState
    }
    
    internal func toggleInstantPayment() -> DigitalState {
        var newState = self
        newState.isInstantPaymentEnabled = !self.isInstantPaymentEnabled
        return newState
    }
    
    internal func receive(form: DigitalForm, lastOrder: DigitalLastOrder, isInstant: Bool) -> DigitalState {
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
            } else {
                newState.selectedProduct = nil
            }
        } else {
            if lastOrder.clientNumber != nil {
                textInputStates["client_number"] = DigitalTextInputState(text: lastOrder.clientNumber!, failedValidation: nil)
            }
            
            let operators = selectedOperator(fromForm: form, orOperatorId: lastOrder.operatorId)
            newState.selectedOperator = operators
            if let op = operators {
                newState.selectedProduct = self.selectProduct(fromOperator: op, orProductId: lastOrder.productId)
            } else {
                newState.selectedProduct = nil
            }
        }
        newState.textInputStates = textInputStates
        let shouldShowError = newState.textInputStates.contains(where: { (key, value) -> Bool in
            if key == "client_number" {
                return value.text.isEmpty || value.failedValidation == nil
            } else {
                return false
            }
        })
        if newState.textInputStates.count == 0 || shouldShowError {
            newState.showErrorClientNumber = false
            newState.showErrors = false
        } else {
            newState.showErrorClientNumber = true
            newState.showErrors = true
        }
        newState.isInstantPaymentEnabled = isInstant
        return newState
    }
    
    internal func selectProduct(fromOperator: DigitalOperator, orProductId: String?) -> DigitalProduct? {
        return fromOperator.products.filter { $0.id == orProductId }.first ?? fromOperator.products.filter { $0.id == fromOperator.defaultProductId }.first
    }
    
    internal func selectedOperator(fromForm: DigitalForm, orOperatorId: String?) -> DigitalOperator? {
        return fromForm.operators.filter { $0.operatorID == orOperatorId }.first ?? fromForm.defaultOperator
    }
}
