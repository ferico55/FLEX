//
//  DigitalTextInput.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

struct DigitalFieldValidation {
    let regexPattern: String
    let errorMessage: String
    
    init(regex: String, errorMessage: String) {
        self.regexPattern = regex
        self.errorMessage = errorMessage
    }
    
    func passes(for text: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])
        let range = NSMakeRange(0, text.characters.count)
        
        return regex?.numberOfMatches(in: text, options: [], range: range) != 0
    }
}

extension DigitalFieldValidation: Unboxable {
    init(unboxer: Unboxer) throws {
        self.regexPattern = try unboxer.unbox(key: "regex")
        self.errorMessage = try unboxer.unbox(key: "error")
    }
}

enum DigitalTextInputType: String {
    case phone = "tel"
    case number = "numeric"
    case text = "text"
}

struct DigitalTextInput {
    let id: String
    let title: String
    let placeholder: String
    let validations: [DigitalFieldValidation]
    let type: DigitalTextInputType
    
    func failedValidation(for text: String) -> DigitalFieldValidation? {
        return validations.first { !$0.passes(for: text) }
    }
    
    func errorMessage(for text: String, operators: [DigitalOperator] = []) -> String {
        if let failedValidation = self.failedValidation(for: text) {
            return failedValidation.errorMessage
        }
        
        guard let _ = operators.appropriateOperator(for: text) else {
            return "Nomor tidak valid"
        }
        
        return ""
    }
    
    func normalizedText(from text: String) -> String {
        if self.type != .phone {
            return text
        }
        
        return text
            .replacingPrefix(of: "62", with: "0")
            .replacingPrefix(of: "+62", with: "0")
            .replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
}

extension String {
    func replacingPrefix(of prefix: String, with replacement: String) -> String {
        guard self.characters.count >= prefix.characters.count else { return self }
        
        let range = self.startIndex ..< self.index(self.startIndex, offsetBy: prefix.characters.count)
        
        return self.replacingOccurrences(of: prefix, with: replacement, range: range)
    }
}

extension DigitalTextInput: Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "name")
        self.title = try unboxer.unbox(key: "text")
        self.placeholder = try unboxer.unbox(key: "placeholder")
        self.validations = try unboxer.unbox(key: "validation")
        self.type = DigitalTextInputType(rawValue: try unboxer.unbox(key: "type")) ?? .text
    }
}
