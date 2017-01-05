//
//  PulsaView.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import OAStackView
import MMNumberKeyboard

@objc
class PulsaView: OAStackView, MMNumberKeyboardDelegate {
    
    var numberField: UITextField!
    var productButton: UIButton!
    
    private var pulsaCategoryControl: UISegmentedControl!
    private var numberErrorLabel: UILabel!
    private var buttonErrorLabel: UILabel!
    
    private var buyButton: UIButton!
    private var buttonsPlaceholder: UIView!
    private var operatorPickerPlaceholder: UIView!
    private var operatorButton: UIButton!
    private var operatorErrorLabel: UILabel!
    
    private var fieldPlaceholder: UIView!
    private var saldoButtonPlaceholder: UIView!
    private var phoneBook: UIImageView!
    
    private var saldoSwitch = UISwitch()
    private var saldoLabel: UILabel!
    
    var selectedOperator = PulsaOperator()
    var selectedCategory = PulsaCategory()
    var selectedProduct = PulsaProduct()
    
    private var userManager = UserAuthentificationManager()
    private var prefixView: UIView?
    private var inputtedNumber: String?
    private var listOperators: [PulsaOperator]?
    
    var didTapAddressbook: (Void -> Void)?
    var didTapProduct:([PulsaProduct] -> Void)?
    var didTapOperator:([PulsaOperator] -> Void)?
    var didAskedForLogin: (Void -> Void)?
    var didShowAlertPermission: (Void -> Void)?
    var didSuccessPressBuy: (NSURL -> Void)?
    
    let WIDGET_LEFT_MARGIN: CGFloat = 20
    let WIDGET_RIGHT_MARGIN: CGFloat = 20
    
    private var arrangedPrefix = [Prefix]()

    struct Prefix {
        var phoneNumber: String
        var image: String
        var id: String
    }
    
    struct ButtonConstant {
        static let defaultProductButtonTitle = "- Pilih -"
    }
    
    struct CategoryConstant {
        static let Pulsa = "1"
        static let PaketData = "2"
        static let Listrik = "3"
    }
    
    init(categories: [PulsaCategory]) {
        super.init(arrangedSubviews: [])
        
        setupStackViewFormat()
        
        NSNotificationCenter .defaultCenter().addObserver(self, selector: #selector(self.didSwipeHomePage), name: "didSwipeHomePage", object: nil)
        NSNotificationCenter .defaultCenter().addObserver(self, selector: #selector(self.didSwipeHomePage), name: "didSwipeHomeTab", object: nil)
        
        
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
        
        self.layoutMarginsRelativeArrangement = true
        self.layoutMargins = UIEdgeInsets(top: 0, left: self.WIDGET_LEFT_MARGIN, bottom: 0, right: self.WIDGET_RIGHT_MARGIN)
        self.addArrangedSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make.height.equalTo()(44)
        }
        
        
        pulsaCategoryControl .bk_addEventHandler({[unowned self] control in
            self.buildViewByCategory(categories[control.selectedSegmentIndex])
        }, forControlEvents: .ValueChanged)
        
        requestOperatorsWithInitialCategory(categories.first!)

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func requestOperatorsWithInitialCategory(category: PulsaCategory) {
        let requestManager = PulsaRequest()
        
        requestManager.didReceiveOperator = { operators in
            let sortedOperators = operators.sort({ (op0, op1) -> Bool in
                op0.attributes.weight < op1.attributes.weight
            })
            
            self.listOperators = sortedOperators
            self .createPrefixCollection(sortedOperators)
            
            //view must be built after receive operator
            //because on some case like pulsa and data, we need prefixes (only exists in operator attributes)
            //and if we show view, when there is no prefix, this will cause crash
            self.buildViewByCategory(category)
            self.pulsaCategoryControl.selectedSegmentIndex = 0
            self.pulsaCategoryControl.backgroundColor = UIColor.whiteColor()
        }
        requestManager.requestOperator()
    }
    
    private func createPrefixCollection(operators: [PulsaOperator]) {
        operators.enumerate().forEach { id, op in
            op.attributes.prefix.forEach { prefix in
                let prefix = Prefix(phoneNumber: prefix, image: op.attributes.image, id: op.id!)
                arrangedPrefix.append(prefix)
            }
        }
    }
    
    private func buildViewByCategory(category: PulsaCategory) {
        self.selectedCategory = category
        self.resetPulsaOperator()
        self.buildAllView(category)
        
        //Ignoring add action on number field, when client_number attribute is not show
        //instead find product directly, because some product which doesn't has number field (saldo), will show product only
        if(self.selectedCategory.attributes.client_number.is_shown) {
            self.addActionNumberField()
        }
        
        let shouldShowProduct = (self.selectedOperator.id != nil && !self.selectedOperator.attributes.rule.show_product)
        
        if(shouldShowProduct) {
            self.setDefaultProductWithOperatorId(self.selectedOperator.id!)
        } else {
            if !self.selectedCategory.attributes.validate_prefix {
                self.setSelectedOperatorWithOperatorId(self.selectedCategory.attributes.default_operator_id)
                self.findProducts(self.selectedCategory.attributes.default_operator_id, categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
            }
            
        }
        
    }
    
    func buildViewByOperator(pulsaOperator: PulsaOperator) {
        self.resetPulsaOperator()
        self.buildAllView(self.selectedCategory)
        
        self.findProducts(pulsaOperator.id!, categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
        self.setSelectedOperatorWithOperatorId(pulsaOperator.id!)
        self.operatorButton.setTitle(pulsaOperator.attributes.name, forState: .Normal)
        
        if(self.selectedOperator.id != nil && !self.selectedOperator.attributes.rule.show_product) {
            self.setDefaultProductWithOperatorId(self.selectedOperator.id!)
        }
    }
    
    private func findProducts(operatorId: String, categoryId: String, didReceiveProduct: ([PulsaProduct] -> Void)?) {
        let requestProductsManager = PulsaRequest()
        requestProductsManager.didReceiveProduct = {[unowned self] products in
            if(products.count > 0) {
                self.showProductButton(products)
                didReceiveProduct?(products)
            } else {
                self.hideProductButton()
            }
        }
        requestProductsManager.requestProduct(operatorId, categoryId: categoryId)
        
    }
    
    private func findOperatorsFromProducts(products: [PulsaProduct]) -> [PulsaOperator]{
        var operators = [PulsaOperator]()
        
        products.enumerate().forEach { (index, product) in
            let operatorId = product.relationships.relationOperator.data.id
            let foundOperator = self .findOperatorById(operatorId!)! as PulsaOperator
            
            if(!operators.contains(foundOperator)) {
                operators.append(foundOperator)
            }
        }
        
        return operators
    }
    
    func findOperatorById(id: String) -> PulsaOperator? {
        return self.listOperators?.filter({ (op) -> Bool in
            op.id == id
        }).first
    }
    
    private func setSelectedOperatorWithOperatorId(id : String) {
        if let selectedOperator = self.findOperatorById(id) {
            self.selectedOperator = selectedOperator
        }
    }
    
    private func setDefaultProductWithOperatorId(operatorId: String) {
        self.findProducts(operatorId, categoryId: self.selectedCategory.id!) { (product) in
            self.selectedProduct = product.first!
        }
    }
    
    
    func buildAllView(category: PulsaCategory) {
        self.arrangedSubviews.enumerate().forEach { index, subview in
            if(index > 0) {
                self.removeArrangedSubview(subview)
            }
        }
        
        if(category.attributes.show_operator) {
            let operatorId = selectedOperator.id ?? category.attributes.default_operator_id
            
            self.setSelectedOperatorWithOperatorId(operatorId)
            self.findProducts(operatorId, categoryId: category.id!, didReceiveProduct: nil)
            
            
            self .buildOperatorButton()
        }
        
        
        if(category.attributes.client_number.is_shown) {
            self.buildNumberField(category)
        }
        
        self.buildButtons(category)
        self.buildUseSaldoView()
        
        
        // jika user sudah input angka kemudian berganti category widget, maka angka tersebut tidak akan tereset
        if let inputtedNumber = self.inputtedNumber {
            if !inputtedNumber.isEmpty {
                numberField.text = inputtedNumber
                self.checkInputtedNumber()
            }
        }
    }
    
    
    func buildUseSaldoView() {
        saldoButtonPlaceholder = UIView(frame: CGRectZero)
        self.addArrangedSubview(saldoButtonPlaceholder)
        saldoButtonPlaceholder.mas_makeConstraints { make in
            make.height.equalTo()(44)
        }
        
        self.saldoSwitch = UISwitch(frame: CGRectZero)
        self.saldoSwitch.on = false
        self.saldoSwitch.hidden = !self.selectedCategory.attributes.instant_checkout_available
        
        saldoButtonPlaceholder.addSubview(self.saldoSwitch)
        
        self.saldoSwitch.mas_makeConstraints { make in
            make.height.equalTo()(self.saldoButtonPlaceholder.mas_height)
            make.top.equalTo()(self.saldoButtonPlaceholder.mas_top).offset()(10)
            make.width.equalTo()(51)
            make.left.equalTo()(self.saldoButtonPlaceholder.mas_left)
        }
        
        
        //saldo label
        saldoLabel = UILabel(frame: CGRectZero)
        saldoLabel.text = "Bayar instan"
        saldoLabel.numberOfLines = 2
        saldoLabel.textColor = UIColor.grayColor()
        saldoLabel.font = UIFont.systemFontOfSize(12)
        saldoLabel.hidden = !self.selectedCategory.attributes.instant_checkout_available
        saldoButtonPlaceholder.addSubview(saldoLabel)
        
        saldoLabel.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(self.saldoButtonPlaceholder)
            make.width.equalTo()(120)
            make.left.equalTo()(self.saldoSwitch.mas_right).offset()(5)
        }
        
        buyButton = UIButton(frame: CGRectZero)
        buyButton.setTitle("BELI", forState: .Normal)
        buyButton.layer.cornerRadius = 3
        buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buyButton.backgroundColor = UIColor.orangeColor()
        buyButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        saldoButtonPlaceholder.addSubview(buyButton)
        
        buyButton.mas_makeConstraints { make in
            make.height.equalTo()(44)
            make.top.equalTo()(self.saldoButtonPlaceholder.mas_top)
            make.left.equalTo()(self.saldoLabel.mas_right).offset()(10)
            make.right.equalTo()(self.saldoButtonPlaceholder.mas_right)
        }
        
        buyButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        buyButton.bk_addEventHandler({ button -> Void in
            self.didPressBuyButton()
        }, forControlEvents: .TouchUpInside)
    }
    
    func buildNumberField(category: PulsaCategory) {
        //if no client number shown, then skip build field control
        if(!self.selectedCategory.attributes.client_number.is_shown) {
            return;
        }
        
        fieldPlaceholder = UIView(frame: CGRectZero)
          self.addArrangedSubview(fieldPlaceholder)
        fieldPlaceholder.mas_makeConstraints { make in
            make.height.mas_equalTo()(44)
        }
        
        if numberField != nil {
            self.inputtedNumber = numberField.text!
        }
        numberField = UITextField(frame: CGRectZero)
        
        numberField.placeholder = category.attributes.client_number.placeholder
        numberField.borderStyle = .RoundedRect
        numberField.rightViewMode = .Always
        numberField.keyboardType = .NumberPad
        numberField.clearButtonMode = .Always
        
        let keyboard =  MMNumberKeyboard(frame: CGRectZero)
        keyboard.allowsDecimalPoint = false
        keyboard.delegate = self
        keyboard.returnKeyTitle = "Beli"
        
        numberField.inputView = keyboard
        
        
        fieldPlaceholder.addSubview(numberField)
        numberField.mas_makeConstraints { make in
            make.bottom.equalTo()(self.fieldPlaceholder.mas_bottom)
            make.top.equalTo()(self.fieldPlaceholder.mas_top)
            make.left.equalTo()(self.mas_left).offset()(self.WIDGET_LEFT_MARGIN)
            make.right.equalTo()(self.mas_right).offset()(category.attributes.use_phonebook ? -55 : -self.WIDGET_RIGHT_MARGIN)
        }
        
        self.prefixView = UIView()
        self.numberField.addSubview(self.prefixView!)
        self.prefixView!.mas_makeConstraints({ (make) in
            make.right.mas_equalTo()(self.numberField.mas_right).with().offset()(-90)
            make.centerY.mas_equalTo()(self.numberField.mas_centerY).with().offset()(-15)
        })
        
        if(category.attributes.use_phonebook) {
            phoneBook = UIImageView(image: UIImage(named: "icon_phonebook.png"))
            phoneBook.userInteractionEnabled = true
            fieldPlaceholder.addSubview(phoneBook)
            
            phoneBook.mas_makeConstraints { make in
                make.height.equalTo()(32)
                make.width.equalTo()(32)
                make.left.equalTo()(self.numberField.mas_right).offset()(5)
                make.centerY.equalTo()(self.numberField.mas_centerY)
            }
            
            phoneBook.bk_whenTapped { [unowned self] in
                self.activateContactPermission()
            }
        }
        
        numberErrorLabel = UILabel(frame: CGRectZero)
        numberErrorLabel.text = "Error"
        numberErrorLabel.textColor = UIColor.redColor()
        numberErrorLabel.font = UIFont.systemFontOfSize(12)
        
        self.addArrangedSubview(numberErrorLabel)
        
        numberErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
        }
    }
    
    func activateContactPermission() {
        let permission = JLContactsPermission.sharedInstance()
        let permissionStatus = permission.authorizationStatus()
        
        if(permissionStatus == JLAuthorizationStatus.PermissionNotDetermined) {
            permission.extraAlertEnabled = false
            permission.authorize({ (granted, error) in
                if(granted) {
                    self.showAddressBook()
                } else {
                    self.showContactAlertPermission()
                }
            })
        } else if(permissionStatus == JLAuthorizationStatus.PermissionDenied) {
            self.showContactAlertPermission()
        } else {
            self.showAddressBook()
        }
    }
    
    func showAddressBook() {
        self.didTapAddressbook?()
    }
    
    func showContactAlertPermission() {
        self.didShowAlertPermission?()
    }
    
    func numberKeyboardShouldReturn(numberKeyboard: MMNumberKeyboard!) -> Bool {
        self.didPressBuyButton()
        return true
    }
    
    // set custom keyboard to textField inputview will remove shouldChangeCharactersInRange:replacementString delegate
    // as an alternative, i tried to check maximum length through MMNumberKeyboard's delegate to estimate maximum length
    func numberKeyboard(numberKeyboard: MMNumberKeyboard!, shouldInsertText text: String!) -> Bool {
        if(self.selectedOperator.attributes.name != "") {
            if(self.numberField.text?.characters.count <= self.selectedOperator.attributes.maximum_length - 1) {
                return true
            }
            
            return false
        }
        
        return true
    }
    
    func addActionNumberField() {
        numberField?.bk_addEventHandler ({[unowned self] number in
            self.hideErrors()
            self.checkInputtedNumber()
            self.numberField.rightViewMode = .Always
            self.numberField.clearButtonMode = .Always
            }, forControlEvents: .EditingChanged)
    }
    
    func checkInputtedNumber() {
        self.hideErrors()
        //operator must exists first
        //fix this to prevent crash using serial dispatch
        var inputtedText = self.numberField.text!
        
        if(self.selectedCategory.id == CategoryConstant.PaketData || self.selectedCategory.id == CategoryConstant.Pulsa ) {
            inputtedText = self.convertAreaNumber(inputtedText)
        }
        
        self.setRightViewNumberField(inputtedText)
        self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, forState: .Normal)
    }
    
    //convert code area from +62 into 0
    private func convertAreaNumber(phoneNumber: String) -> String{
        var convertedNumber = phoneNumber
        if(phoneNumber.characters.count >= 2) {
            let countryCode = phoneNumber.substringWithRange(phoneNumber.startIndex.advancedBy(0)..<phoneNumber.startIndex.advancedBy(2))
            if(countryCode == "62") {
                convertedNumber = phoneNumber.stringByReplacingCharactersInRange(phoneNumber.startIndex..<phoneNumber.startIndex.advancedBy(2), withString: "0")
            }
        }
        
        return convertedNumber
    }
    
    func resetPulsaOperator() {
        selectedOperator = PulsaOperator()
    }
    
    func hideErrors() {
        self.numberErrorLabel?.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.buttonErrorLabel?.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.operatorErrorLabel?.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
    }
    
    private func findPrefix(inputtedString: String) -> Prefix {
        var returnPrefix = Prefix(phoneNumber: "", image: "", id: "")
        self.arrangedPrefix.forEach { (prefix) in
            if(inputtedString.hasPrefix(prefix.phoneNumber)) {
                returnPrefix = prefix
            }
        }
        
        return returnPrefix
    }
    
    func setRightViewNumberField(inputtedPrefix: String) {
        if(self.selectedCategory.attributes.validate_prefix) {
            let prefix = self.findPrefix(inputtedPrefix)
            
            if(prefix.phoneNumber != "") {
                self.findProducts((prefix.id), categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
                self.setSelectedOperatorWithOperatorId(prefix.id)
                
                let prefixImage = UIImageView(frame: CGRectMake(0, 0, 60, 30))
                prefixView?.removeAllSubviews()
                prefixView?.addSubview(prefixImage)
                prefixImage.setImageWithURL((NSURL(string: (prefix.image))))
                self.prefixView?.hidden = false
                
                self.numberField.rightViewMode = .Always
                self.numberField.clearButtonMode = .Always
            } else {
                if let prefixView = self.prefixView {
                    prefixView.hidden = true
                }
                
                resetPulsaOperator()
                self.hideProductButton()
            }
        } else {
            self.findProducts(self.selectedCategory.attributes.default_operator_id, categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
            self.setSelectedOperatorWithOperatorId(self.selectedCategory.attributes.default_operator_id)
            
            let prefixImage = UIImageView(frame: CGRectMake(0, 0, 60, 30))
            self.prefixView = UIView(frame: CGRectMake(0, 0, prefixImage.frame.size.width + 10.0, prefixImage.frame.size.height ))
            self.prefixView!.addSubview(prefixImage)
            
            prefixImage.contentMode = .ScaleAspectFill
            prefixImage.setImageWithURL((NSURL(string: self.selectedOperator.attributes.image)))
            self.numberField.rightView = prefixView
            self.numberField.rightViewMode = .Always
            self.numberField.clearButtonMode = .Always

        }
                
        self.numberField.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = { textField, range, string in
            guard let text = textField.text else { return true }
            
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= self.selectedOperator.attributes.maximum_length
        }
    }
    
    func buildOperatorButton() {
        let operatorTitle = (self.selectedOperator.attributes.name != "") ? self.selectedOperator.attributes.name : ButtonConstant.defaultProductButtonTitle
        operatorPickerPlaceholder = UIView(frame: CGRectZero)
        self.addArrangedSubview(operatorPickerPlaceholder)
        
        operatorButton = UIButton(frame: CGRectZero)
        operatorButton.setTitle(operatorTitle, forState: .Normal)
        operatorButton.layer.cornerRadius = 3
        
        operatorButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        operatorButton.backgroundColor = UIColor.whiteColor()
        operatorButton.layer.borderColor = UIColor(red: (231.0/255.0), green: (231.0/255.0), blue: (231/255.0), alpha: 1).CGColor
        operatorButton.layer.borderWidth = 1.0
        operatorButton.contentHorizontalAlignment = .Left
        operatorButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        
        operatorPickerPlaceholder.addSubview(operatorButton)
        
        operatorPickerPlaceholder.mas_makeConstraints { (make) in
            make.height.equalTo()(self.selectedCategory.attributes.show_operator ? 44 : 0)
            make.width.equalTo()(self.operatorButton.mas_width)
        }
        
        operatorButton.mas_makeConstraints { make in
            make.top.equalTo()(self.operatorPickerPlaceholder.mas_top)
            make.bottom.equalTo()(self.operatorPickerPlaceholder.mas_bottom)
            make.left.right().equalTo()(self.operatorPickerPlaceholder)
        }
        
        operatorButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        operatorButton.bk_addEventHandler({ [weak self](button) in
            guard let `self` = self else { return }
            
            self.findProducts("", categoryId: self.selectedCategory.id!, didReceiveProduct: { receivedProducts in
                let operators = self.findOperatorsFromProducts(receivedProducts)
                self.didTapOperator?(operators)
            })
            
        }, forControlEvents: .TouchUpInside)
        
        operatorErrorLabel = UILabel(frame: CGRectZero)
        operatorErrorLabel.textColor = UIColor.redColor()
        operatorErrorLabel.font = UIFont.systemFontOfSize(12)
        self.addArrangedSubview(operatorErrorLabel)
        
        operatorErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
        }
        self.attachArrowToButton(operatorButton)
    }

    func buildButtons(category: PulsaCategory) {
        buttonsPlaceholder = UIView(frame: CGRectZero)
        self.addArrangedSubview(buttonsPlaceholder)
        
        
        productButton = UIButton(frame: CGRectZero)
        productButton.setTitle(ButtonConstant.defaultProductButtonTitle, forState: .Normal)
        productButton.layer.cornerRadius = 3

        productButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        productButton.backgroundColor = UIColor.whiteColor()
        productButton.hidden = true
        productButton.layer.borderColor = UIColor(red: (231.0/255.0), green: (231.0/255.0), blue: (231/255.0), alpha: 1).CGColor
        productButton.layer.borderWidth = 1.0
        productButton.contentHorizontalAlignment = .Left
        productButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        
        buttonsPlaceholder.addSubview(productButton)
        
        buttonsPlaceholder.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.width.equalTo()(self.productButton.mas_width)
        }
        
        productButton.mas_makeConstraints { make in
            make.top.equalTo()(self.buttonsPlaceholder.mas_top)
            make.bottom.equalTo()(self.buttonsPlaceholder.mas_bottom)
            make.left.equalTo()(self.buttonsPlaceholder.mas_left)
        }
        
        buttonErrorLabel = UILabel(frame: CGRectZero)
        buttonErrorLabel.textColor = UIColor.redColor()
        buttonErrorLabel.font = UIFont.systemFontOfSize(12)
        self.addArrangedSubview(buttonErrorLabel)
        
        buttonErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.attachArrowToButton(productButton)
    }
    
    private func attachArrowToButton(button: UIButton) {
        let arrowImage = UIImageView(image: UIImage(named: "icon_arrow_down.png"))
        button .addSubview(arrowImage)
        
        arrowImage.mas_makeConstraints { (make) in
            make.top.equalTo()(button.mas_top).offset()(15)
            make.width.height().equalTo()(14)
            make.right.equalTo()(button.mas_right).offset()(-10)
        }
    }
    
    private func isValidNumber(number: String) -> Bool{
        guard self.selectedOperator.id != nil else {
            if(self.selectedCategory.attributes.validate_prefix) {
                return self.isValidNumberLength(number)
            }
            
            return true
        }
        
        return self.isValidNumberLength(number)
        
    }
    
    private func isValidNumberLength(number: String) -> Bool {
        if self.selectedOperator.attributes.maximum_length > 0 {
            if(number.characters.count < self.selectedOperator.attributes.minimum_length) {
                self.numberErrorLabel.text = "Nomor terlalu pendek, minimal "+String(self.selectedOperator.attributes.minimum_length)+" karakter"
                return false
            } else if(number.characters.count > self.selectedOperator.attributes.maximum_length) {
                self.numberErrorLabel.text = "Nomor terlalu panjang, maksimal "+String(self.selectedOperator.attributes.maximum_length)+" karakter"
                return false
            }
        } else {
            self.numberErrorLabel.text = "Nomor tidak valid"
            return false
        }
        
        return true
    }
    
    private func isValidOperator() -> Bool {
        if(self.operatorButton?.currentTitle == ButtonConstant.defaultProductButtonTitle && self.selectedCategory.attributes.show_operator == true) {
            operatorErrorLabel.text = "Pilih operator terlebih dahulu"
            return false
        }
        
        return true
    }
    
    private func isValidProduct() -> Bool {
        if(self.productButton.currentTitle == ButtonConstant.defaultProductButtonTitle && self.selectedOperator.attributes.rule.show_product == true) {
            buttonErrorLabel.text = "Pilih nominal terlebih dahulu"
            return false
        }
        
        return true
    }
    
    func showProductButton(products: [PulsaProduct]) {
        productButton.hidden = false
        self.buttonsPlaceholder.mas_updateConstraints { make in
            make.height.equalTo()(self.selectedOperator.attributes.rule.show_product ? 44 : 0)
        }
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            self.productButton.hidden = !self.selectedOperator.attributes.rule.show_product
        }, completion: { finished in
        
        })
        
        //prevent keep adding button to handler
        productButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        productButton.bk_addEventHandler({ button -> Void in
            self.didTapProduct!(products)
        }, forControlEvents: .TouchUpInside)
   
    }
    
    private func hideProductButton() {
        buttonsPlaceholder.mas_updateConstraints { (make) in
            make.height.equalTo()(0)
        }
        
        productButton.hidden = true
        self.prefixView?.hidden = true
    }
    
    func didPressBuyButton() {
        let isValidNumber = (!self.selectedCategory.attributes.client_number.is_shown || self.isValidNumber(self.numberField.text!))
        
        self.numberErrorLabel?.mas_updateConstraints { make in
            make.height.equalTo()(!isValidNumber ? 22 : 0)
        }

        self.buttonErrorLabel.mas_updateConstraints { make in
            make.height.equalTo()((self.productButton.hidden == false && !self.isValidProduct()) ? 22 : 0)
        }
        
        self.operatorErrorLabel?.mas_updateConstraints { make in
            make.height.equalTo()((!self.operatorButton.hidden && !self.isValidOperator()) ? 22 : 0)
        }
        
        
        if(isValidOperator() && self.isValidProduct() && isValidNumber) {
            self.hideErrors()
            
            self.userManager = UserAuthentificationManager()
            if(!self.userManager.isLogin) {
                self.didAskedForLogin!()
            } else {
                //open scrooge
                var clientNumber = ""
                if numberField != nil {
                    clientNumber = numberField.text!
                }
                
                let pulsaUrl = "\(NSString.pulsaUrl())?action=init_data&client_number=\(clientNumber)&product_id=\(self.selectedProduct.id!)&operator_id=\(self.selectedOperator.id!)&instant_checkout=\(self.saldoSwitch.on ? "1" : "0")&utm_source=ios&utm_medium=widget&utm_campaign=pulsa+widget&utm_content=\(NSString.encodeString(self.selectedCategory.attributes.name))"
                
                self.didSuccessPressBuy?(NSURL(string: self.userManager.webViewUrlFromUrl(pulsaUrl))!)
            }
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
    
    func didSwipeHomePage() {
        self.numberField?.resignFirstResponder()
    }
    
    func setupStackViewFormat() {
        self.axis = .Vertical
        self.distribution = .Fill
        self.alignment = .Fill
        self.spacing = 5.0
    }
    
}

