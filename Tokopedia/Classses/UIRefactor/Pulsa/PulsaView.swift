//
//  PulsaView.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

class PulsaView: UIView {
    
    var pulsaCategoryControl: UISegmentedControl!
    var numberField: UITextField!
    var numberErrorLabel: UILabel!
    var buttonErrorLabel: UILabel!
    var productButton: UIButton!
    var buyButton: UIButton!
    var buttonsPlaceholder: UIView!
    var fieldPlaceholder: UIView!
    var didPrefixEntered: (((String) -> Void)?)
    var didTapAddressbook: ([APContact] -> Void)?
    var selectedOperator = PulsaOperator()
    var phoneBook: UIImageView!
    let addressBook = APAddressBook()
    
    struct ButtonConstant {
        static let defaultProductButtonTitle = "Pilih Nominal"
    }
    
    var prefixes: Dictionary<String, Dictionary<String, String>>?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(categories: [PulsaCategory]) {
        super.init(frame: CGRectZero)
        
        pulsaCategoryControl = UISegmentedControl(frame: CGRectZero)
        categories.enumerate().forEach { index, category in
            pulsaCategoryControl.insertSegmentWithTitle(category.attributes.name, atIndex: index, animated: true)
        }
        
        self.addSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(0)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        pulsaCategoryControl .bk_addEventHandler({[unowned self] control in
            self.buildAllView(categories[control.selectedSegmentIndex])
            self.addActionNumberField()
        }, forControlEvents: .ValueChanged)
        
        self.buildAllView(categories[0])
        self.pulsaCategoryControl.selectedSegmentIndex = 0
    }
    
    func buildAllView(category: PulsaCategory) {
        self.subviews.enumerate().forEach { index, subview in
            if(index > 0) {
                subview.removeFromSuperview()
            }
        }
        
        self.buildFields(category)
        self.buildButtons()
        
        self.recalibrateView()
    }
    
    func buildFields(category: PulsaCategory) {
        fieldPlaceholder = UIView(frame: CGRectZero)
        self.addSubview(fieldPlaceholder)
        
        fieldPlaceholder.mas_makeConstraints { make in
            make.top.equalTo()(self.pulsaCategoryControl.mas_bottom).offset()(10)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        numberField = UITextField(frame: CGRectZero)
        
        numberField.placeholder = category.attributes.client_number.placeholder
        numberField.borderStyle = .RoundedRect
        numberField.rightViewMode = .Always
        numberField.keyboardType = .NumberPad
        
        
        fieldPlaceholder.addSubview(numberField)
        numberField.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(self.fieldPlaceholder.mas_top)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right).offset()(category.attributes.use_phonebook ? -44 : 0)
            make.bottom.equalTo()(self.fieldPlaceholder.mas_bottom)
        }
        
        if(category.attributes.use_phonebook) {
            phoneBook = UIImageView(image: UIImage(named: "icon_login.png"))
            phoneBook.userInteractionEnabled = true
            fieldPlaceholder.addSubview(phoneBook)
            
            phoneBook.mas_makeConstraints { make in
                make.height.equalTo()(44)
                make.width.equalTo()(44)
                make.left.equalTo()(self.numberField.mas_right)
                make.top.equalTo()(self.fieldPlaceholder.mas_top)
            }
            
            phoneBook.bk_whenTapped { [unowned self] in
                self.addressBook.loadContacts({ (contacts: [APContact]?, error: NSError?) in
                    self.didTapAddressbook!(contacts!)
                })
            }
        }
        
        
        numberErrorLabel = UILabel(frame: CGRectZero)
        numberErrorLabel.text = "Error"
        numberErrorLabel.textColor = UIColor.redColor()
        numberErrorLabel.font = UIFont.init(name: "GothamBook", size: 12.0)
        self.addSubview(numberErrorLabel)
        
        numberErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.fieldPlaceholder.mas_bottom).offset()(3)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
    }
    
    func addActionNumberField() {
        numberField.bk_addEventHandler ({[unowned self] number in
            //operator must exists first
            //fix this to prevent crash using serial dispatch
            self.setRightViewNumberField()
            self.numberErrorLabel.mas_updateConstraints { make in
                make.height.equalTo()(0)
            }
            
            self.buttonErrorLabel.mas_updateConstraints { make in
                make.height.equalTo()(0)
            }
            
            }, forControlEvents: .EditingChanged)
    }
    
    func setRightViewNumberField() {
        var inputtedPrefix = (self.numberField.text)!
        let characterCount = inputtedPrefix.characters.count
        
        if(characterCount >= 4) {
            if(self.prefixes?.count == 0) { return }
            inputtedPrefix = inputtedPrefix.substringWithRange(Range<String.Index>(start: inputtedPrefix.startIndex.advancedBy(0), end: inputtedPrefix.startIndex.advancedBy(4)))
            
            let prefix = self.prefixes![inputtedPrefix]
            if(prefix != nil) {
                let prefixImage = UIImageView.init(frame: CGRectMake(0, 0, 70, 35))
                prefixImage.setImageWithURL((NSURL.init(string: prefix!["image"]!)))
                self.numberField.rightView = prefixImage
                self.numberField.rightViewMode = .Always
                
                self.didPrefixEntered!(prefix!["id"]!)
            } else {
                self.numberField.rightView = nil
                self.hideBuyButtons()
            }
        } else {
            self.numberField.rightView = nil
            self.hideBuyButtons()
        }
    }
    
    func buildButtons() {
        buttonsPlaceholder = UIView(frame: CGRectZero)
        self.addSubview(buttonsPlaceholder)
        
        buttonsPlaceholder.mas_makeConstraints { make in
            make.top.equalTo()(self.numberErrorLabel.mas_bottom)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        productButton = UIButton(frame: CGRectZero)
        productButton.setTitle(ButtonConstant.defaultProductButtonTitle, forState: .Normal)
        productButton.layer.cornerRadius = 3
        productButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        productButton.backgroundColor = UIColor.lightGrayColor()
        productButton.hidden = true
        
        buttonsPlaceholder.addSubview(productButton)
        
        productButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.buttonsPlaceholder.mas_top).offset()(10)
            make.left.equalTo()(self.mas_left)
            make.width.equalTo()(150)
            make.bottom.equalTo()(self.buttonsPlaceholder.mas_bottom)
        }
        
        buyButton = UIButton(frame: CGRectZero)
        buyButton.setTitle("Beli", forState: .Normal)
        buyButton.layer.cornerRadius = 3
        buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buyButton.backgroundColor = UIColor.orangeColor()
        buyButton.hidden = true
        
        buttonsPlaceholder.addSubview(buyButton)
        
        buyButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.productButton.mas_top)
            make.left.equalTo()(self.productButton.mas_right).offset()(10)
            make.right.equalTo()(self.buttonsPlaceholder.mas_right)
        }
        
        buttonErrorLabel = UILabel(frame: CGRectZero)
        buttonErrorLabel.text = "Error"
        buttonErrorLabel.textColor = UIColor.redColor()
        buttonErrorLabel.font = UIFont.init(name: "GothamBook", size: 12.0)
        self.addSubview(buttonErrorLabel)
        
        buttonErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.buttonsPlaceholder.mas_bottom).offset()(3)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
    }
    
    func isValidNumber(number: String) -> Bool{
        if(number.characters.count < self.selectedOperator.attributes.minimum_length) {
            self.numberErrorLabel.text = "Nomor terlalu pendek, minimal "+String(self.selectedOperator.attributes.minimum_length)+" karakter"
            return false
        } else if(number.characters.count > self.selectedOperator.attributes.maximum_length) {
            self.numberErrorLabel.text = "Nomor terlalu panjang, maksimal "+String(self.selectedOperator.attributes.maximum_length)+" karakter"
            return false
        }
        
        return true
    }
    
    func isValidNominal() -> Bool {
        if(self.productButton.currentTitle == ButtonConstant.defaultProductButtonTitle) {
            buttonErrorLabel.text = "Pilih nominal terlebih dahulu"
            return false
        } else {
            return true
        }
    }
    
    func showBuyButton(products: [PulsaProduct]) {
        productButton.mas_updateConstraints { make in
            make.height.equalTo()(44)
        }
        
        buyButton.mas_updateConstraints { make in
            make.height.equalTo()(44)
        }
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            self.setNeedsLayout()
            self .layoutIfNeeded()
            
            self.productButton.hidden = false
            self.buyButton.hidden = false
        }, completion: { finished in
        
        })
        
        buyButton.bk_addEventHandler({ [unowned self] button -> Void in
            if(!self.isValidNumber(self.numberField.text!)) {
                self.numberErrorLabel.mas_updateConstraints { make in
                    make.height.equalTo()(22)
                }
            } else if(!self.isValidNominal()) {
                self.buttonErrorLabel.mas_updateConstraints { make in
                    make.height.equalTo()(22)
                }
            } else {
                
            }
        }, forControlEvents: .TouchUpInside)
    }
    
    func hideBuyButtons() {
        productButton.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        buyButton.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        
        productButton.hidden = true
        buyButton.hidden = true
    }
    
    func recalibrateView() {
        self.subviews.enumerate().forEach { index, subview in
            subview.mas_makeConstraints { make in
                if(index == 0) {
                    make.top.equalTo()(subview.superview!).with().offset()(0)
                } else {
                    make.top.equalTo()(self.subviews[index-1].mas_bottom).offset()(10)
                }
            }
        }
        
        self.subviews.last?.mas_makeConstraints { make in
            make.bottom.equalTo()(self.mas_bottom)
        }
    }
    
    
    func attachToView(container: UIView) {
        container.addSubview(self)
        
        self.mas_makeConstraints {make in
            make.left.equalTo()(container.mas_left)
            make.top.equalTo()(container.mas_top)
            make.right.equalTo()(container.mas_right)
            make.bottom.equalTo()(container.mas_bottom)
        }
        
    }
    
}
