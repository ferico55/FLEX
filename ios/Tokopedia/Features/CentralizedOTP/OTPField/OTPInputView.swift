//
//  OTPStackView.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

public protocol OTPInputViewDelegate: class {
    /// Called whenever the textfield has to become first responder. Called for the first field when loading
    ///
    /// - Parameter index: the index of the field. Index starts from 0.
    /// - Returns: return true to show keyboard and vice versa
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool

    /// Called whenever an OTP is entered.
    ///
    /// - parameter hasEntered: `hasEntered` will be `true` if all the OTP fields have been filled.
    func hasEnteredAllOTP(hasEntered: Bool, otpEntered: String)
}

public class OTPInputView: UIStackView {
    /// Different input type for OTP fields.
    public enum KeyboardType: Int {
        case numeric
        case alphabet
        case alphaNumeric
    }

    /// Defines the number of OTP field needed. Defaults to 4.
    public var otpFieldsCount: Int = 4

    /// Defines the type of the data that can be entered into OTP fields. Defaults to `numeric`.
    public var otpFieldInputType: KeyboardType = .numeric

    /// Define the font to be used to OTP field. Defaults tp `systemFont` with size `32`.
    public var otpFieldFont: UIFont = UIFont.semiboldSystemFont(ofSize: 32)

    /// If set to `true`, then the content inside OTP field will be displayed in asterisk (*) format. Defaults to `false`.
    public var otpFieldEntrySecureType: Bool = false

    /// If set to `true`, then the content inside OTP field will not be displayed. Instead whatever was set in `otpFieldEnteredBorderColor` will be used to mask the passcode. If `otpFieldEntrySecureType` is set to `true`, then it'll be ignored. This acts similar to Apple's lock code. Defaults to `false`.
    public var otpFilledEntryDisplay: Bool = false

    /// If set to `false`, the blinking cursor for OTP field will not be visible. Defaults to `true`.
    public var shouldRequireCursor: Bool = true

    /// If `shouldRequireCursor` is set to `false`, then this property will not have any effect. If `true`, then the color of cursor can be changed using this property. Defaults to `blue` color.
    public var cursorColor: UIColor = .tpGreen()

    /// Defines the size of OTP field. Defaults to `32`.
    public var otpFieldSize: CGFloat = 32

    /// If set, then editing can be done to intermediate fields even though previous fields are empty. Else editing will take place from last filled text field only. Defaults to `true`.
    public var shouldAllowIntermediateEditing: Bool = true

    /// Set this value if a background color is needed when a text is not enetered in the OTP field. Defaults to `clear` color.
    public var otpFieldDefaultBackgroundColor: UIColor = UIColor.clear

    /// Set this value if a background color is needed when a text is enetered in the OTP field. Defaults to `clear` color.
    public var otpFieldEnteredBackgroundColor: UIColor = UIColor.clear

    // MARK: Bottom Border Color

    /// Set this value if a border color is needed when a text is not enetered in the OTP field. Defaults to `black` color.
    public var otpFieldDefaultBorderColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)

    /// Set Error
    public var otpFieldErrorBorderColor: UIColor = .fromHexString("#d50000")

    /// Set this value if a border color is needed when a text is enetered in the OTP field. Defaults to `black` color.
    public var otpFieldEnteredBorderColor: UIColor = .tpGreen()

    weak public var delegate: OTPInputViewDelegate?

    fileprivate var secureEntryData = [String]()

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: Public functions
    /// Call this method to create the OTP field view. This method should be called at the last after necessary customization needed. If any property is modified at a later stage is simply ignored.
    public func initalizeUI() {
        self.layer.masksToBounds = true
        self.layoutIfNeeded()

        if let placeholderView = self.subviews.first {
            self.removeArrangedSubview(placeholderView)
        }

        initalizeOTPFields()

        // Forcefully try to make first otp field as first responder
        (viewWithTag(1) as? OTPTextField)?.becomeFirstResponder()
    }

    public func showErrorBorder() {
        for field in self.subviews {
            if let otpBox = field as? OTPTextField {
                otpBox.shapeLayer.strokeColor = self.otpFieldErrorBorderColor.cgColor
                otpBox.tintColor = self.otpFieldErrorBorderColor
            }
        }
    }

    public func showSuccessBorder() {
        for field in self.subviews {
            if let otpBox = field as? OTPTextField {
                otpBox.shapeLayer.strokeColor = self.otpFieldEnteredBorderColor.cgColor
                otpBox.tintColor = self.otpFieldEnteredBorderColor
            }
        }
    }

    public func clearField() {
        self.secureEntryData.removeAll()
        for field in self.subviews {
            if let otpBox = field as? OTPTextField {
                self.secureEntryData.append("")
                otpBox.text = ""
                otpBox.shapeLayer.strokeColor = self.otpFieldDefaultBorderColor.cgColor
                otpBox.tintColor = self.otpFieldEnteredBorderColor
            }
        }
    }

    // Set up the fields
    fileprivate func initalizeOTPFields() {
        secureEntryData.removeAll()
        var prevField: OTPTextField? = nil

        for index in stride(from: 0, to: otpFieldsCount, by: 1) {
            var otpField = viewWithTag(index + 1) as? OTPTextField

            if otpField == nil {
                otpField = getOTPField(forIndex: index)
            }

            if let prevTextField = prevField {
                otpField?.prevTextfield = prevTextField
            }

            prevField = otpField

            if let otpField = otpField {
                secureEntryData.append("")
                self.addArrangedSubview(otpField)
            }
        }
    }

    // Initalize the required OTP fields
    fileprivate func getOTPField(forIndex index: Int) -> OTPTextField {
        let fieldFrame = CGRect(x: 0, y: 0, width: otpFieldSize, height: 48)

        let otpField = OTPTextField(frame: fieldFrame)
        otpField.delegate = self
        otpField.tag = index + 1
        otpField.translatesAutoresizingMaskIntoConstraints = false
        otpField.widthAnchor.constraint(equalToConstant: otpFieldSize).isActive = true
        otpField.font = otpFieldFont
        otpField.textColor = UIColor.tpPrimaryBlackText()

        // Set input type for OTP fields
        switch otpFieldInputType {
        case .numeric:
            otpField.keyboardType = .numberPad
        case .alphabet:
            otpField.keyboardType = .alphabet
        case .alphaNumeric:
            otpField.keyboardType = .namePhonePad
        }

        if shouldRequireCursor {
            otpField.tintColor = cursorColor
        } else {
            otpField.tintColor = UIColor.clear
        }

        // Set the default background color when text not set
        otpField.backgroundColor = otpFieldDefaultBackgroundColor
        otpField.fieldBorderColor = otpFieldDefaultBorderColor

        // Finally create the fields
        otpField.initalizeUI()

        return otpField
    }

    // Check if previous text fields have been entered or not before textfield can edit the selected field. This will have effect only if
    fileprivate func isPreviousFieldsEntered(forTextField textField: UITextField) -> Bool {
        var isTextFilled = true
        var nextOTPField: UITextField?

        // If intermediate editing is not allowed, then check for last filled from the current field in forward direction.
        if !shouldAllowIntermediateEditing {
            for index in stride(from: textField.tag + 1, to: otpFieldsCount + 1, by: 1) {
                let tempNextOTPField = viewWithTag(index) as? UITextField

                if let tempNextOTPFieldText = tempNextOTPField?.text, !tempNextOTPFieldText.isEmpty {
                    nextOTPField = tempNextOTPField
                }
            }

            if let nextOTPField = nextOTPField {
                if nextOTPField != textField {
                    nextOTPField.becomeFirstResponder()
                }

                isTextFilled = false
            }
        }

        return isTextFilled
    }

    // Helper function to get the OTP String entered
    fileprivate func calculateEnteredOTPSTring(isDeleted: Bool) {
        if isDeleted {
            delegate?.hasEnteredAllOTP(hasEntered: false, otpEntered: "")
        } else {
            var enteredOTPString = ""
            // Check for entered OTP
            for index in stride(from: 0, to: secureEntryData.count, by: 1) where !secureEntryData[index].isEmpty {
                enteredOTPString.append(secureEntryData[index])
            }

            // Check if all OTP fields have been filled or not. Based on that call the 2 delegate methods.
            delegate?.hasEnteredAllOTP(hasEntered: (enteredOTPString.count == otpFieldsCount), otpEntered: enteredOTPString.count == otpFieldsCount ? enteredOTPString : "")
        }
    }

}

extension OTPInputView: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = delegate?.shouldBecomeFirstResponderForOTP(otpFieldIndex: (textField.tag - 1)) ?? true
        if shouldBeginEditing {
            return isPreviousFieldsEntered(forTextField: textField)
        }

        return shouldBeginEditing
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""

        // Check since only alphabet keyboard is not available in iOS
        if !replacedText.isEmpty && otpFieldInputType == .alphabet && replacedText.rangeOfCharacter(from: .letters) == nil {
            return false
        }

        if replacedText.count >= 1 {
            // If field has a text already, then replace the text and move to next field if present
            secureEntryData[textField.tag - 1] = string

            if otpFilledEntryDisplay {
                textField.text = " "
            } else {
                if otpFieldEntrySecureType {
                    textField.text = "*"
                } else {
                    textField.text = string
                }
            }

            if let otpBox = textField as? OTPTextField {
                otpBox.shapeLayer.strokeColor = self.otpFieldEnteredBorderColor.cgColor
                otpBox.shapeLayer.fillColor = self.otpFieldEnteredBorderColor.cgColor
            }

            let nextOTPField = viewWithTag(textField.tag + 1)

            if let nextOTPField = nextOTPField {
                nextOTPField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }

            // Get the entered string
            calculateEnteredOTPSTring(isDeleted: false)
        } else {
            // If deleting the text, then move to previous text field if present
            secureEntryData[textField.tag - 1] = ""
            textField.text = ""

            if let otpBox = textField as? OTPTextField {
                otpBox.shapeLayer.strokeColor = self.otpFieldDefaultBorderColor.cgColor
                otpBox.shapeLayer.fillColor = self.otpFieldDefaultBorderColor.cgColor
            }

            let prevOTPField = viewWithTag(textField.tag - 1)

            if let prevOTPField = prevOTPField, let prevOTPBox = prevOTPField as? OTPTextField {
                if prevOTPBox.text == "" {
                    prevOTPField.becomeFirstResponder()
                }
            }

            // Get the entered string
            calculateEnteredOTPSTring(isDeleted: true)
        }

        return false
    }
}
