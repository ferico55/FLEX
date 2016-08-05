//
//  PulsaLayout.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaLayout: InsetLayout {
    
    public init(category: PulsaCategory, prefixes: Dictionary<String, Dictionary<String, String>>, callback: ((String) -> Void)!) {
        super.init(
            insets: UIEdgeInsetsMake(10, 10, 10, 10),
            sublayout: StackLayout(
                axis: .vertical,
                spacing: 10,
                sublayouts: [
                    LabelLayout(text: category.attributes.client_number.text, alignment: .fill, font: UIFont(name: "GothamBook", size: 13.0)!),
                    SizeLayout<TextFieldViewWrapper>(width: 300, height: 44, alignment: .fill, config: { textFieldWrapper in
                        textFieldWrapper.prefixes = prefixes
                        textFieldWrapper.placeholder = category.attributes.client_number.placeholder
                        textFieldWrapper.onPrefixCallBack = callback
                        textFieldWrapper.build()
                    }),
                ]
            )
        )
    }
    
}

class TextFieldViewWrapper: UIView, UITextFieldDelegate {
    var prefixes = Dictionary<String, Dictionary<String, String>>()
    var placeholder: String = ""
    var onPrefixCallBack: ((String) -> Void)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func build() {
        let numberField = UITextField.init(frame: CGRectMake(0, 0, 300, 44))
        numberField.placeholder = self.placeholder
        numberField.borderStyle = .RoundedRect
        numberField.rightViewMode = .Always
        numberField.delegate = self
        numberField.keyboardType = .NumberPad
        
        self.addSubview(numberField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let inputtedPrefix = textField.text! + string as String
        let characterCount = inputtedPrefix.characters.count - range.length
        
        if(characterCount == 4) {
            let prefix = self.prefixes[inputtedPrefix]
            if(prefix != nil) {
                let prefixImage = UIImageView.init(frame: CGRectMake(0, 0, 70, 35))
                prefixImage.setImageWithURL((NSURL.init(string: prefix!["image"]!)))
                textField.rightView = prefixImage
                textField.rightViewMode = .Always
                
                self.onPrefixCallBack(textField.text!)
            } else {
                textField.rightView = nil
            }
        }
        
        if(characterCount < 4) {
            textField.rightView = nil
        }
        
        return true
    }
}
