//
//  DigitalTextInput.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

internal struct DigitalFieldValidation {
    internal let regexPattern: String
    internal let errorMessage: String
    
    internal init(regex: String, errorMessage: String) {
        self.regexPattern = regex
        self.errorMessage = errorMessage
    }
    
    internal func passes(for text: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        let range = NSRange(location: 0, length: text.count)
        
        return regex?.numberOfMatches(in: text, options: [], range: range) != 0
    }
}

extension DigitalFieldValidation: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.regexPattern = try unboxer.unbox(key: "regex")
        self.errorMessage = try unboxer.unbox(key: "error")
    }
}

internal enum DigitalTextInputType: String {
    case phone = "tel"
    case number = "numeric"
    case text = "text"
}

internal struct DigitalTextInput {
    internal let id: String
    internal let title: String
    internal let placeholder: String
    internal let validations: [DigitalFieldValidation]
    internal let type: DigitalTextInputType
    
    internal func failedValidation(for text: String) -> DigitalFieldValidation? {
        return validations.first { !$0.passes(for: text) }
    }
    
    internal func errorMessage(for text: String, operators: [DigitalOperator] = []) -> String {
        if let failedValidation = self.failedValidation(for: text) {
            return failedValidation.errorMessage
        }
        
        guard let _ = operators.appropriateOperator(for: text) else {
            return "Nomor tidak valid"
        }
        
        return ""
    }
    
    internal func normalizedText(from text: String) -> String {
        if self.type != .phone {
            return text
        }
        
        return text
            .replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            .replacingPrefix(of: "+62", with: "0")
            .replacingPrefix(of: "62", with: "0")
    }
}

extension String {
    internal func replacingPrefix(of prefix: String, with replacement: String) -> String {
        guard self.count >= prefix.count else { return self }
        
        let range = self.startIndex ..< self.index(self.startIndex, offsetBy: prefix.count)
        
        return self.replacingOccurrences(of: prefix, with: replacement, range: range)
    }
}

extension DigitalTextInput: Unboxable {
    internal init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "name")
        self.title = try unboxer.unbox(key: "text")
        self.placeholder = try unboxer.unbox(key: "placeholder")
        self.validations = try unboxer.unbox(key: "validation")
        self.type = DigitalTextInputType(rawValue: try unboxer.unbox(key: "type")) ?? .text
    }
}
