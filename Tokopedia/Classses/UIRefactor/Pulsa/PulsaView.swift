//
//  PulsaView.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

@objc
class PulsaView: UIView {
    
    var pulsaCategoryControl: UISegmentedControl!
    var numberField: UITextField!
    var numberErrorLabel: UILabel!
    var buttonErrorLabel: UILabel!
    var productButton: UIButton!
    var buyButton: UIButton!
    var buttonsPlaceholder: UIView!
    var fieldPlaceholder: UIView!
    var saldoButtonPlaceholder: UIView!
    var phoneBook: UIImageView!
    
    let addressBook = APAddressBook()
    var saldoSwitch = UISwitch()
    var selectedOperator = PulsaOperator()
    var selectedCategory = PulsaCategory()
    var selectedProduct = PulsaProduct()
    var userManager = UserAuthentificationManager()
    
    var didPrefixEntered: ((operatorId: String, categoryId: String) -> Void)?
    var didTapAddressbook: ([APContact] -> Void)?
    var didTapProduct:([PulsaProduct] -> Void)?
    var didAskedForLogin: (Void -> Void)?
    var invalidateViewHeight: (Void -> Void)?
    var didSuccessPressBuy: (NSURL -> Void)?
    
    var prefixes: Dictionary<String, Dictionary<String, String>>?
    
    struct ButtonConstant {
        static let defaultProductButtonTitle = "Pilih Nominal"
    }
    
    struct CategoryConstant {
        static let Pulsa = "1"
        static let PaketData = "2"
        static let Listrik = "3"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(categories: [PulsaCategory]) {
        super.init(frame: CGRectZero)
        
        pulsaCategoryControl = UISegmentedControl(frame: CGRectZero)
        categories.enumerate().forEach { index, category in
            pulsaCategoryControl.insertSegmentWithTitle(category.attributes.name, atIndex: index, animated: true)
        }
        
        //set new icon for new category
        pulsaCategoryControl.subviews.reverse().enumerate().forEach { controlIndex, segment in
            if(categories[controlIndex].attributes.is_new == true) {
                let new = UIImageView(image: UIImage(named: "red_dot.png"))
                new.frame = CGRectMake(5, 5, 10, 10)
                segment .addSubview(new)
            }
            
            segment.subviews.enumerate().forEach { index, view in
                if(view is UILabel) {
                    let label = view as! UILabel
                    label.frame = CGRectMake(0, 0, 97, 50)
                    label.numberOfLines = 0
                }
            }

        }
        
        self.addSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(0)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        pulsaCategoryControl .bk_addEventHandler({[unowned self] control in
            self.selectedCategory = categories[control.selectedSegmentIndex]
            self.buildAllView(self.selectedCategory)
            self.addActionNumberField()
            self.invalidateViewHeight!()
        }, forControlEvents: .ValueChanged)
        
        self.buildAllView(categories[0])
        self.pulsaCategoryControl.selectedSegmentIndex = 0
        self.pulsaCategoryControl.backgroundColor = UIColor.whiteColor()
        self.selectedCategory = categories[0]
    }
    
    func buildAllView(category: PulsaCategory) {
        self.subviews.enumerate().forEach { index, subview in
            if(index > 0) {
                subview.removeFromSuperview()
            }
        }
        
        
        self.buildFields(category)
        self.buildButtons()
        self.buildUseSaldoView()

        self.recalibrateView()
    }
    
    func buildUseSaldoView() {
        saldoButtonPlaceholder = UIView(frame: CGRectZero)
        self.addSubview(saldoButtonPlaceholder)
        saldoButtonPlaceholder.mas_makeConstraints { make in
            make.top.equalTo()(self.buttonErrorLabel.mas_bottom)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
            make.height.equalTo()(0)
        }
        
        
        
        self.saldoSwitch = UISwitch(frame: CGRectZero)
        self.saldoSwitch.on = false
        self.saldoSwitch.hidden = true
        
        saldoButtonPlaceholder.addSubview(self.saldoSwitch)
        
        self.saldoSwitch.mas_makeConstraints { make in
            make.height.equalTo()(self.saldoButtonPlaceholder.mas_height)
            make.top.equalTo()(self.saldoButtonPlaceholder.mas_top).offset()(10)
            make.width.equalTo()(51)
            make.left.equalTo()(self.saldoButtonPlaceholder.mas_left)
        }
        
        
        //saldo label
        let saldoLabel = UILabel(frame: CGRectZero)
        saldoLabel.text = "Bayar instan"
        saldoLabel.numberOfLines = 2
        saldoLabel.textColor = UIColor.grayColor()
        saldoLabel.font = UIFont.systemFontOfSize(12)
        saldoButtonPlaceholder.addSubview(saldoLabel)
        
        saldoLabel.mas_makeConstraints { make in
            make.height.top().equalTo()(self.saldoButtonPlaceholder)
            make.width.equalTo()(120)
            make.left.equalTo()(self.saldoSwitch.mas_right).offset()(5)
        }
        
        buyButton = UIButton(frame: CGRectZero)
        buyButton.setTitle("BELI", forState: .Normal)
        buyButton.layer.cornerRadius = 3
        buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buyButton.backgroundColor = UIColor.orangeColor()
        buyButton.hidden = true
        buyButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        saldoButtonPlaceholder.addSubview(buyButton)
        
        buyButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.saldoButtonPlaceholder.mas_top).offset()(10)
            make.left.equalTo()(saldoLabel.mas_right).offset()(10)
            make.right.equalTo()(self.saldoButtonPlaceholder.mas_right)
        }

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
            phoneBook = UIImageView(image: UIImage(named: "icon_phonebook@3x.png"))
            phoneBook.userInteractionEnabled = true
            fieldPlaceholder.addSubview(phoneBook)
            
            phoneBook.mas_makeConstraints { make in
                make.height.equalTo()(32)
                make.width.equalTo()(32)
                make.left.equalTo()(self.numberField.mas_right).offset()(5)
                make.top.equalTo()(self.fieldPlaceholder.mas_top).offset()(5)
            }
            
            phoneBook.bk_whenTapped { [unowned self] in
                self.addressBook.filterBlock = { contacts in
                    return contacts.phones?.count > 0
                }
                self.addressBook.loadContacts({ (contacts: [APContact]?, error: NSError?) in
                    if((error == nil)) {
                        self.didTapAddressbook!(contacts!)
                    }
                })
            }
        }
        
        numberErrorLabel = UILabel(frame: CGRectZero)
        numberErrorLabel.text = "Error"
        numberErrorLabel.textColor = UIColor.redColor()
        numberErrorLabel.font = UIFont.systemFontOfSize(12)
        
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
            self.hideErrors()
            //operator must exists first
            //fix this to prevent crash using serial dispatch
            let inputtedText = self.numberField.text!
            if(inputtedText.characters.count == 4) {
                let prefix = inputtedText.substringWithRange(Range<String.Index>(start: inputtedText.startIndex.advancedBy(0), end: inputtedText.startIndex.advancedBy(4)))
                
                self.setRightViewNumberField(prefix)
                self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, forState: .Normal)
            }
            
            if(inputtedText.characters.count < 4) {
                self.numberField.rightView = nil
                self.hideBuyButtons()
            }
            
            }, forControlEvents: .EditingChanged)
    }
    
    func hideErrors() {
        self.numberErrorLabel.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.buttonErrorLabel.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
    }
    
    func setRightViewNumberField(inputtedPrefix: String) {
        if(self.selectedCategory.id == CategoryConstant.Pulsa || self.selectedCategory.id == CategoryConstant.PaketData) {
            let prefix = self.prefixes![inputtedPrefix]
            if(prefix != nil) {
                self.didPrefixEntered!(operatorId: prefix!["id"]!, categoryId: self.selectedCategory.id!)
                
                let prefixImage = UIImageView.init(frame: CGRectMake(0, 0, 60, 30))
                let prefixView = UIView(frame: CGRectMake(0, 0, prefixImage.frame.size.width + 10.0, prefixImage.frame.size.height ))
                prefixView .addSubview(prefixImage)
               
                prefixImage.setImageWithURL((NSURL.init(string: prefix!["image"]!)))
                self.numberField.rightView = prefixView
                self.numberField.rightViewMode = .Always
            } else {
                self.numberField.rightView = nil
                self.hideBuyButtons()
            }
        } else if(self.selectedCategory.id == CategoryConstant.Listrik) {
            self.didPrefixEntered!(operatorId: "6", categoryId: self.selectedCategory.id!)
            
            
            let prefixImage = UIImageView.init(frame: CGRectMake(0, 0, 60, 30))
            let prefixView = UIView(frame: CGRectMake(0, 0, prefixImage.frame.size.width + 10.0, prefixImage.frame.size.height ))
            prefixView .addSubview(prefixImage)
            
            prefixImage.contentMode = .ScaleAspectFill
            prefixImage.setImageWithURL((NSURL.init(string: self.selectedOperator.attributes.image)))
            self.numberField.rightView = prefixView
            self.numberField.rightViewMode = .Always
        }
    }
    
    
    func buildButtons() {
        buttonsPlaceholder = UIView(frame: CGRectZero)
        self.addSubview(buttonsPlaceholder)
        
        buttonsPlaceholder.mas_makeConstraints { make in
            make.top.equalTo()(self.numberErrorLabel.mas_bottom).offset()(5)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
        }
        
        productButton = UIButton(frame: CGRectZero)
        productButton.setTitle(ButtonConstant.defaultProductButtonTitle, forState: .Normal)
        productButton.layer.cornerRadius = 3

        productButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        productButton.backgroundColor = UIColor.whiteColor()
        productButton.hidden = true
        productButton.layer.borderColor = UIColor(red: (231.0/255.0), green: (231.0/255.0), blue: (231/255.0), alpha: 1).CGColor
        productButton.layer.borderWidth = 1.0
        productButton.contentHorizontalAlignment = .Left
        productButton.contentEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        
        buttonsPlaceholder.addSubview(productButton)
        
        productButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.buttonsPlaceholder.mas_top)
            make.left.equalTo()(self.mas_left)
            make.right.equalTo()(self.mas_right)
            make.bottom.equalTo()(self.buttonsPlaceholder.mas_bottom)
        }
        
        
        buttonErrorLabel = UILabel(frame: CGRectZero)
        buttonErrorLabel.textColor = UIColor.redColor()
        buttonErrorLabel.font = UIFont.systemFontOfSize(12)
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
        
        saldoButtonPlaceholder.mas_updateConstraints { make in
            make.height.equalTo()(self.selectedCategory.attributes.instant_checkout_available ? 54 : 0)
        }
        self.saldoSwitch.hidden = self.selectedCategory.attributes.instant_checkout_available ? false : true
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            self.productButton.hidden = false
            self.buyButton.hidden = false
        }, completion: { finished in
        
        })
        
        //prevent keep adding button to handler
        productButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        productButton.bk_addEventHandler({ button -> Void in
            self.didTapProduct!(products)
        }, forControlEvents: .TouchUpInside)
        
        buyButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        buyButton.bk_addEventHandler({ button -> Void in
            self.invalidateViewHeight!()
            
            if(!self.isValidNumber(self.numberField.text!)) {
                self.numberErrorLabel.mas_updateConstraints { make in
                    make.height.equalTo()(22)
                }
            } else {
                self.numberErrorLabel.mas_updateConstraints { make in
                    make.height.equalTo()(0)
                }
            }
        
            
            if(!self.isValidNominal()) {
                self.buttonErrorLabel.mas_updateConstraints { make in
                    make.height.equalTo()(22)
                }
            } else {
                self.buttonErrorLabel.mas_updateConstraints { make in
                    make.height.equalTo()(0)
                }
            }
            
            if(self.isValidNominal() && self.isValidNumber(self.numberField.text!)) {
                self.hideErrors()
                
                self.userManager = UserAuthentificationManager()
                if(!self.userManager.isLogin) {
                    self.didAskedForLogin!()
                } else {
                    //open scrooge
                    var pulsaUrl = "https://pulsa.tokopedia.com?action=init_data&client_number=" + self.numberField.text!
                        pulsaUrl += "&product_id=" + self.selectedProduct.id!
                        pulsaUrl += "&operator_id=" +  self.selectedOperator.id!
                        pulsaUrl += "&instant_checkout=" + (self.saldoSwitch.on ? "1" : "0")
                        pulsaUrl += "&utm_source=ios"
                    
                    let customAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}&").invertedSet
                    var url = "https://js.tokopedia.com/wvlogin?uid=" + self.userManager.getUserId()
                        url += "&token=" + self.userManager.getMyDeviceToken()
                        url += "&url=" + pulsaUrl.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
                    
                    self.didSuccessPressBuy!(NSURL(string: url)!)
                }
            }
        }, forControlEvents: .TouchUpInside)
        
        productButton.setImage(UIImage(named: "icon_arrow_down.png"), forState: .Normal)
        productButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.productButton.frame.size.width - 30, 0, 0)
        
        self.invalidateViewHeight!()
    }
    
    func hideBuyButtons() {
        productButton.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        buyButton.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        saldoButtonPlaceholder.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.saldoSwitch.hidden = true
        productButton.hidden = true
        buyButton.hidden = true
        
        self.invalidateViewHeight!()
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
            make.left.equalTo()(container.mas_left).offset()(10)
            make.top.equalTo()(container.mas_top).offset()(10)
            make.right.equalTo()(container.mas_right).offset()(-10)
            make.bottom.equalTo()(container.mas_bottom)
        }
        
    }
    
}
