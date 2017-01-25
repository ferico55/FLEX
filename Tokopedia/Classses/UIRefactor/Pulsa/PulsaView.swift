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
import HMSegmentedControl
import BEMCheckBox

@objc
class PulsaView: UIView, MMNumberKeyboardDelegate {
    
    private var stackView: OAStackView = OAStackView()
    private var pulsaCategoryControl: HMSegmentedControl = {
        let pulsaCategoryControl = HMSegmentedControl(sectionTitles: [])
        pulsaCategoryControl.segmentWidthStyle = .Fixed
        pulsaCategoryControl.selectionIndicatorBoxOpacity = 0
        pulsaCategoryControl.selectionStyle = .Box;
        pulsaCategoryControl.selectedSegmentIndex = HMSegmentedControlNoSegment;
        pulsaCategoryControl.type = .Text
        pulsaCategoryControl.selectionIndicatorLocation = .Down;
        pulsaCategoryControl.selectionIndicatorHeight = 2
        return pulsaCategoryControl
    }()
    lazy private var noHandphoneLabel: UILabel = {
        var noHandphoneLabel = UILabel()
        noHandphoneLabel.font = UIFont.microTheme()
        noHandphoneLabel.textColor = self.titleTextColor
        return noHandphoneLabel
    }()
    var numberField: UITextField!
    lazy var productButton: UIButton = {
        var productButton = UIButton(frame: CGRectZero)
        productButton.setTitle(ButtonConstant.defaultProductButtonTitle, forState: .Normal)
        productButton.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.54), forState: .Normal)
        productButton.backgroundColor = UIColor.whiteColor()
        productButton.hidden = true
        productButton.layer.borderWidth = 0
        productButton.contentHorizontalAlignment = .Left
        return productButton
    }()
    lazy private var productButtonUnderlineView: UIView = {
        let productButtonUnderlineView = UIView()
        productButtonUnderlineView.hidden = true
        productButtonUnderlineView.backgroundColor = self.underlineViewColor
        return productButtonUnderlineView
    }()
    lazy private var numberFieldUnderlineView: UIView = {
        let numberFieldUnderlineView = UIView()
        numberFieldUnderlineView.backgroundColor = self.underlineViewColor
        return numberFieldUnderlineView
    }()
    private var buyButton: UIButton = {
        let buyButton = UIButton(frame: CGRectZero)
        buyButton.setTitle("Beli", forState: .Normal)
        buyButton.layer.cornerRadius = 3
        buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buyButton.backgroundColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255, alpha: 1)
        buyButton.hidden = true
        buyButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        return buyButton
    }()
    private var buttonsPlaceholder: UIView!
    private var fieldPlaceholder: UIView!
    private var saldoButtonPlaceholder: UIView!
    private var buyButtonPlaceholder:UIView!
    private var phoneBook: UIImageView = {
        var phoneBook = UIImageView(image: UIImage(named: "icon_phonebook"))
        phoneBook.userInteractionEnabled = true
        return phoneBook
    }()
    lazy private var nominalLabel: UILabel = {
        let nominalLabel = UILabel()
        nominalLabel.text = "Nominal"
        nominalLabel.hidden = true
        nominalLabel.font = UIFont.microTheme()
        nominalLabel.textColor = self.titleTextColor
        return nominalLabel
    }()
    
    lazy private var saldoCheckBox: BEMCheckBox = {
        let saldoCheckBox = BEMCheckBox()
        saldoCheckBox.boxType = .Square
        saldoCheckBox.lineWidth = 1
        saldoCheckBox.onTintColor = UIColor.whiteColor()
        saldoCheckBox.onCheckColor = UIColor.whiteColor()
        saldoCheckBox.onFillColor = self.tokopediaGreenColor
        saldoCheckBox.animationDuration = 0
        saldoCheckBox.hidden = true
        return saldoCheckBox
    }()
    lazy private var saldoLabel: UILabel = {
        let saldoLabel = UILabel(frame: CGRectZero)
        saldoLabel.text = "Bayar Instan"
        saldoLabel.numberOfLines = 2
        saldoLabel.textColor = UIColor.grayColor()
        saldoLabel.font = UIFont.largeTheme()
        saldoLabel.hidden = true
        return saldoLabel
    }()
    
    private var numberErrorPlaceholder: UIView!
    lazy private var numberErrorLabel: UILabel = {
        let numberErrorLabel = UILabel(frame: CGRectZero)
        numberErrorLabel.backgroundColor = UIColor.whiteColor()
        numberErrorLabel.text = "Error"
        numberErrorLabel.textColor = UIColor.redColor()
        numberErrorLabel.font = UIFont.microTheme()
        return numberErrorLabel
    }()
    private var buttonErrorPlaceholder: UIView!
    lazy private var buttonErrorLabel: UILabel = {
        let buttonErrorLabel = UILabel(frame: CGRectZero)
        buttonErrorLabel.backgroundColor = UIColor.whiteColor()
        buttonErrorLabel.textColor = UIColor.redColor()
        buttonErrorLabel.font = UIFont.microTheme()
        return buttonErrorLabel
    }()
    
    private var operatorPickerPlaceholder: UIView!
    private var operatorButton: UIButton!
    private var operatorErrorLabel: UILabel!
    
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
    
    private let WIDGET_LEFT_MARGIN: CGFloat = 15
    private let WIDGET_RIGHT_MARGIN: CGFloat = 15
    private let underlineOffset: CGFloat = 5
    
    private var arrangedPrefix = [Prefix]()
    
    private let tokopediaGreenColor = UIColor(red: 66.0/255, green: 181.0/255, blue: 73.0/255, alpha: 1)
    private let underlineViewColor = UIColor(red: 216.0/255, green: 216.0/255, blue: 216.0/255, alpha: 1)
    private let titleTextColor = UIColor(red: 158.0/255, green: 158.0/255, blue: 158.0/255, alpha: 1)
    
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
        super.init(frame: CGRectZero)
        
        self.setCornerRadius()
        setupStackViewFormat()
        NSNotificationCenter .defaultCenter().addObserver(self, selector: #selector(self.didSwipeHomePage), name: "didSwipeHomePage", object: nil)
        NSNotificationCenter .defaultCenter().addObserver(self, selector: #selector(self.didSwipeHomePage), name: "didSwipeHomeTab", object: nil)
        
        pulsaCategoryControl.redDotImage = UIImage(named: "red_dot")
        categories.enumerate().forEach { index, category in
            pulsaCategoryControl.sectionTitles.append(category.attributes.name)
            if category.attributes.is_new {
                pulsaCategoryControl.showRedDotAtIndex(index)
            }
        }
        
        let categoryControlPlaceHolder = UIView()
        categoryControlPlaceHolder.mas_makeConstraints { (make) in
            make.height.equalTo()(51)
        }
        stackView.addArrangedSubview(categoryControlPlaceHolder)
        categoryControlPlaceHolder.addSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make.top.left().right().mas_equalTo()(categoryControlPlaceHolder)
            make.bottom.mas_equalTo()(categoryControlPlaceHolder).offset()(-1)
        }
        pulsaCategoryControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : self.tokopediaGreenColor, NSFontAttributeName : UIFont.largeThemeMedium()]
        pulsaCategoryControl.titleTextAttributes = [NSForegroundColorAttributeName : self.titleTextColor
            , NSFontAttributeName : UIFont.largeTheme()]
        pulsaCategoryControl.selectionIndicatorColor = self.tokopediaGreenColor
        pulsaCategoryControl.bk_addEventHandler({[unowned self] control in
            self.buildViewByCategory(categories[control.selectedSegmentIndex])
            }, forControlEvents: .ValueChanged)
        
        let categoryControlUnderline = UIView()
        categoryControlUnderline.backgroundColor = underlineViewColor
        categoryControlPlaceHolder.addSubview(categoryControlUnderline)
        categoryControlUnderline.mas_makeConstraints { (make) in
            make.top.mas_equalTo()(self.pulsaCategoryControl.mas_bottom)
            make.left.right().mas_equalTo()(categoryControlPlaceHolder)
            make.height.mas_equalTo()(1)
        }
        
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
    
    // MARK: Build View
    
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
    
    
    private func buildViewByCategory(category: PulsaCategory) {
        self.selectedCategory = category
        self.resetCheckBox()
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
    
    
    private func buildOperatorButton() {
        let operatorTitle = (self.selectedOperator.attributes.name != "") ? self.selectedOperator.attributes.name : ButtonConstant.defaultProductButtonTitle
        operatorPickerPlaceholder = UIView(frame: CGRectZero)
        operatorPickerPlaceholder.backgroundColor = UIColor.whiteColor()
        stackView.addArrangedSubview(operatorPickerPlaceholder)
        
        operatorButton = UIButton(frame: CGRectZero)
        operatorButton.setTitle(operatorTitle, forState: .Normal)
        
        operatorButton.setTitleColor(UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.54), forState: .Normal)
        operatorButton.contentHorizontalAlignment = .Left
        operatorButton.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        
        operatorPickerPlaceholder.addSubview(operatorButton)
        
        operatorPickerPlaceholder.mas_makeConstraints { (make) in
            make.height.equalTo()(self.selectedCategory.attributes.show_operator ? 38 : 0)
        }
        
        operatorButton.mas_makeConstraints { make in
            make.centerY.mas_equalTo()(self.operatorPickerPlaceholder)
            make.height.mas_equalTo()(25)
            make.left.mas_equalTo()(self.operatorPickerPlaceholder.mas_left).offset()(15)
            make.right.equalTo()(self.operatorPickerPlaceholder.mas_right).offset()(-15)
        }
        
        operatorButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        operatorButton.bk_addEventHandler({ [weak self](button) in
            guard let `self` = self else { return }
            
            self.findProducts("", categoryId: self.selectedCategory.id!, didReceiveProduct: { receivedProducts in
                let operators = self.findOperatorsFromProducts(receivedProducts)
                self.didTapOperator?(operators)
            })
            
            }, forControlEvents: .TouchUpInside)
        let operatorButtonUnderline = UIView()
        operatorButtonUnderline.backgroundColor = underlineViewColor
        operatorPickerPlaceholder.addSubview(operatorButtonUnderline)
        operatorButtonUnderline.mas_makeConstraints({ make in
            make.height.mas_equalTo()(1)
            make.top.mas_equalTo()(self.operatorButton.mas_bottom).offset()(self.underlineOffset)
            make.left.mas_equalTo()(self.operatorButton.mas_left)
            make.right.mas_equalTo()(self.operatorButton.mas_right)
        })
        
        operatorErrorLabel = UILabel(frame: CGRectZero)
        operatorErrorLabel.textColor = UIColor.redColor()
        operatorErrorLabel.font = UIFont.systemFontOfSize(12)
        stackView.addArrangedSubview(operatorErrorLabel)
        
        operatorErrorLabel.mas_makeConstraints { make in
            make.height.equalTo()(0)
        }
        self.attachArrowToButton(operatorButton)
    }
    
    private func buildButtons(category: PulsaCategory) {
        buttonsPlaceholder = UIView(frame: CGRectZero)
        buttonsPlaceholder.backgroundColor = UIColor.whiteColor()
        stackView.addArrangedSubview(buttonsPlaceholder)

        buttonsPlaceholder.addSubview(nominalLabel)
        nominalLabel.mas_makeConstraints{ make in
            make.top.equalTo()(self.buttonsPlaceholder.mas_top).with().offset()(10)
            make.left.equalTo()(self.buttonsPlaceholder).with().offset()(15)
        }
    
        buttonsPlaceholder.addSubview(productButton)
        
        productButton.mas_makeConstraints { make in
            make.top.equalTo()(self.nominalLabel.mas_bottom).with().offset()(5)
            make.height.equalTo()(25)
            make.left.equalTo()(self.nominalLabel)
            make.right.equalTo()(self.buttonsPlaceholder).with().offset()(-15)
        }
        
        productButton.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
        
        buttonsPlaceholder.mas_makeConstraints { make in
            make.height.equalTo()(0)
        }
        
        buttonsPlaceholder.addSubview(productButtonUnderlineView)
        productButtonUnderlineView.mas_makeConstraints { (make) in
            make.top.mas_equalTo()(self.productButton.mas_bottom).with().offset()(self.underlineOffset)
            make.left.right().mas_equalTo()(self.productButton)
            make.height.mas_equalTo()(1)
        }
        
        buttonErrorPlaceholder = UIView()
        buttonErrorPlaceholder.backgroundColor = UIColor.whiteColor()
        buttonErrorPlaceholder.clipsToBounds = true
        buttonErrorPlaceholder.mas_makeConstraints { (make) in
            make.height.equalTo()(0)
        }
        
        stackView.addArrangedSubview(buttonErrorPlaceholder)
        buttonErrorPlaceholder.addSubview(buttonErrorLabel)
        
        buttonErrorLabel.mas_makeConstraints { make in
            make.left.mas_equalTo()(self.nominalLabel)
            make.centerY.mas_equalTo()(self.buttonErrorPlaceholder)
        }
        attachArrowToButton(productButton)
    }
    
    
    private func buildAllView(category: PulsaCategory) {
        stackView.arrangedSubviews.enumerate().forEach { index, subview in
            if(index > 0) {
                stackView.removeArrangedSubview(subview)
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
        self.buildBuyButtonPlaceholder()
        
        
        // jika user sudah input angka kemudian berganti category widget, maka angka tersebut tidak akan tereset
        if let inputtedNumber = self.inputtedNumber {
            if !inputtedNumber.isEmpty {
                numberField.text = inputtedNumber
                self.checkInputtedNumber()
            }
        }
    }
    
    
    private func buildUseSaldoView() {
        saldoButtonPlaceholder = UIView(frame: CGRectZero)
        saldoButtonPlaceholder.backgroundColor = UIColor.whiteColor()
        stackView.addArrangedSubview(saldoButtonPlaceholder)
        saldoButtonPlaceholder.mas_makeConstraints { make in
            make.height.equalTo()(41)
        }
        
        saldoButtonPlaceholder.addSubview(self.saldoCheckBox)
        
        self.saldoCheckBox.mas_makeConstraints { make in
            make.centerY.equalTo()(self.saldoButtonPlaceholder)
            make.width.height().equalTo()(18)
            make.left.equalTo()(self.productButton.mas_left)
        }
        
        
        saldoButtonPlaceholder.addSubview(saldoLabel)
        
        saldoLabel.mas_makeConstraints { make in
            make.centerY.equalTo()(self.saldoCheckBox)
            make.width.equalTo()(120)
            make.left.equalTo()(self.saldoCheckBox.mas_right).offset()(5)
        }
    }
    
    private func buildBuyButtonPlaceholder() {
        buyButtonPlaceholder = UIView(frame: CGRectZero)
        buyButtonPlaceholder.backgroundColor = UIColor.whiteColor()
        stackView.addArrangedSubview(buyButtonPlaceholder)
        buyButtonPlaceholder.mas_makeConstraints { make in
            make.height.equalTo()(0)
        }
        
        buyButtonPlaceholder.addSubview(buyButton)
        
        buyButton.mas_makeConstraints { make in
            make.height.equalTo()(0)
            make.top.equalTo()(self.buyButtonPlaceholder.mas_top)
            make.left.equalTo()(self.buyButtonPlaceholder.mas_left).offset()(15)
            make.right.equalTo()(self.buyButtonPlaceholder.mas_right).with().offset()(-15)
        }
        
        buyButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        buyButton.bk_addEventHandler({ button -> Void in
            self.didPressBuyButton()
            }, forControlEvents: .TouchUpInside)
        showBuyButton()
    }
    
    private func buildNumberField(category: PulsaCategory) {
        //if no client number shown, then skip build field control
        if(!self.selectedCategory.attributes.client_number.is_shown) {
            return;
        }
        
        fieldPlaceholder = UIView(frame: CGRectZero)
        fieldPlaceholder.backgroundColor = UIColor.whiteColor()
        stackView.addArrangedSubview(fieldPlaceholder)
        fieldPlaceholder.mas_makeConstraints { make in
            make.height.mas_equalTo()(62)
        }

        noHandphoneLabel.text = category.attributes.client_number.text
        fieldPlaceholder.addSubview(noHandphoneLabel)
        
        noHandphoneLabel.mas_makeConstraints { (make) in
            make.top.mas_equalTo()(self.fieldPlaceholder.mas_top).offset()(10)
            make.left.equalTo()(self.fieldPlaceholder.mas_left).offset()(self.WIDGET_LEFT_MARGIN)
        }
        
        if numberField != nil {
            self.inputtedNumber = numberField.text!
        }
        numberField = UITextField(frame: CGRectZero)
        numberField.placeholder = category.attributes.client_number.placeholder
        numberField.borderStyle = .None
        numberField.rightViewMode = .Always
        numberField.keyboardType = .NumberPad
        numberField.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
        numberField.clearButtonMode = .Always
        
        let keyboard =  MMNumberKeyboard(frame: CGRectZero)
        keyboard.allowsDecimalPoint = false
        keyboard.delegate = self
        keyboard.returnKeyTitle = "Beli"
        
        numberField.inputView = keyboard
        
        if(category.attributes.use_phonebook) {
            phoneBook = UIImageView(image: UIImage(named: "icon_phonebook"))
            phoneBook.userInteractionEnabled = true
            fieldPlaceholder.addSubview(phoneBook)
            
            phoneBook.mas_makeConstraints { make in
                make.height.equalTo()(25)
                make.width.equalTo()(25)
                make.right.equalTo()(self.fieldPlaceholder.mas_right).offset()(-15)
                make.top.equalTo()(self.noHandphoneLabel.mas_bottom).offset()(5)
            }
            
            phoneBook.bk_whenTapped { [unowned self] in
                self.activateContactPermission()
            }
        }
        
        fieldPlaceholder.addSubview(numberField)
        numberField.mas_makeConstraints { make in
            make.height.equalTo()(25)
            make.top.equalTo()(self.noHandphoneLabel.mas_bottom).offset()(5)
            make.left.equalTo()(self.noHandphoneLabel.mas_left)
            if(category.attributes.use_phonebook) {
                make.right.equalTo()(self.phoneBook.mas_left).offset()(-15)
            } else {
                make.right.equalTo()(self.fieldPlaceholder.mas_right).offset()(-15)
            }

        }
        
        fieldPlaceholder.addSubview(numberFieldUnderlineView)
        numberFieldUnderlineView.mas_makeConstraints { (make) in
            make.top.mas_equalTo()(self.numberField.mas_bottom).offset()(self.underlineOffset)
            make.left.mas_equalTo()(self.numberField.mas_left)
            make.right.mas_equalTo()(self.numberField.mas_right)
            make.height.mas_equalTo()(1)
        }
        
        self.prefixView = UIView()
        self.numberField.addSubview(self.prefixView!)
        self.prefixView!.mas_makeConstraints({ (make) in
            make.right.mas_equalTo()(self.numberField.mas_right).with().offset()(-75)
            make.centerY.mas_equalTo()(self.numberField.mas_centerY).with().offset()(-15)
        })
        
        numberErrorPlaceholder = UIView()
        numberErrorPlaceholder.backgroundColor = UIColor.whiteColor()
        numberErrorPlaceholder.clipsToBounds = true
        numberErrorPlaceholder.mas_makeConstraints { (make) in
            make.height.mas_equalTo()(0)
        }
        
        stackView.addArrangedSubview(numberErrorPlaceholder)
        numberErrorPlaceholder.addSubview(numberErrorLabel)
        
        numberErrorLabel.mas_makeConstraints { make in
            make.left.mas_equalTo()(self.noHandphoneLabel)
            make.centerY.mas_equalTo()(self.numberErrorPlaceholder)
        }
    }
    
    
    
    //MARK: Show or Hide View
    
    func hideErrors() {
        self.numberErrorPlaceholder?.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.buttonErrorPlaceholder?.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        self.operatorErrorLabel?.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
    }
    
    
    private func showProductButton(products: [PulsaProduct]) {
        productButton.hidden = false
        
        self.buttonsPlaceholder.mas_updateConstraints { make in
            make.height.equalTo()(self.selectedOperator.attributes.rule.show_product ? 66 : 0)
        }
        
        saldoButtonPlaceholder?.mas_updateConstraints({ (make) in
            make.height.equalTo()(self.selectedCategory.attributes.instant_checkout_available ? 41 : 0)
        })
        
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            self.productButton.hidden = false
            self.productButtonUnderlineView.hidden = false
            self.nominalLabel.hidden = false
            }, completion: { finished in
                
        })
        
        //prevent keep adding button to handler
        productButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        productButton.bk_addEventHandler({ button -> Void in
            self.didTapProduct!(products)
            }, forControlEvents: .TouchUpInside)
    }
    
    private func hideBuyButtons() {
        buttonsPlaceholder.mas_updateConstraints { (make) in
            make.height.equalTo()(0)
        }
        
        buyButton.mas_updateConstraints { make in
            make.height.equalTo()(0)
        }
        
        buyButtonPlaceholder.mas_updateConstraints { (make) in
            make.height.equalTo()(0)
        }
        self.saldoCheckBox.hidden = true
        self.saldoLabel.hidden = true
        
        saldoButtonPlaceholder?.mas_updateConstraints({ (make) in
            make.height.equalTo()(0)
        })
        
        productButton.hidden = true
        productButtonUnderlineView.hidden = true
        buyButton.hidden = true
        nominalLabel.hidden = true
    }
    
    private func showBuyButton() {
        
        buyButton.mas_updateConstraints { make in
            make.height.equalTo()(52)
        }
        
        buyButtonPlaceholder.mas_updateConstraints { (make) in
            make.height.equalTo()(60)
        }
        
        
        self.saldoCheckBox.hidden = self.selectedCategory.attributes.instant_checkout_available ? false : true
        self.saldoLabel.hidden = self.selectedCategory.attributes.instant_checkout_available ? false : true
        
        self.buyButton.hidden = false
    }
    
    private func hideProductButton() {
        buttonsPlaceholder.mas_updateConstraints { (make) in
            make.height.equalTo()(0)
        }
        
        buyButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        buyButton.bk_addEventHandler({ button -> Void in
            self.didPressBuyButton()
            }, forControlEvents: .TouchUpInside)
        
        productButton.hidden = true
        self.prefixView?.hidden = true
    }
    
    private func showAddressBook() {
        self.didTapAddressbook?()
    }
    
    private func showContactAlertPermission() {
        self.didShowAlertPermission?()
    }
    
    // MARK: Did Press Button
    
    private func didPressBuyButton() {
        let isValidNumber = (!self.selectedCategory.attributes.client_number.is_shown || self.isValidNumber(self.numberField.text!))
        
        self.numberErrorPlaceholder?.mas_updateConstraints { make in
            make.height.equalTo()(!isValidNumber ? 22 : 0)
        }
        
        self.buttonErrorPlaceholder.mas_updateConstraints { make in
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
                
                let pulsaUrl = "\(NSString.pulsaUrl())?action=init_data&client_number=\(clientNumber)&product_id=\(self.selectedProduct.id!)&operator_id=\(self.selectedOperator.id!)&instant_checkout=\(self.saldoCheckBox.on ? "1" : "0")&utm_source=ios&utm_medium=widget&utm_campaign=pulsa+widget&utm_content=\(NSString.encodeString(self.selectedCategory.attributes.name))"
                
                
                self.didSuccessPressBuy?(NSURL(string: self.userManager.webViewUrlFromUrl(pulsaUrl))!)
            }
        }
    }
    
    // MARK: MMNumberKeyboard Delegate
    
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
    
    
    
    // MARK: Validation Checking
    
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
    
    private func attachToView(container: UIView) {
        container.addSubview(self)
        
        self.mas_makeConstraints {make in
            make.left.equalTo()(container.mas_left).offset()(10)
            make.top.equalTo()(container.mas_top).offset()(10)
            make.right.equalTo()(container.mas_right).offset()(-10)
            make.bottom.equalTo()(container.mas_bottom)
        }
    }
    
    // MARK: Common Method
    
    func setCornerRadius() {
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
    }
    
    func didSwipeHomePage() {
        self.numberField?.resignFirstResponder()
    }
    
    private func setupStackViewFormat() {
        self.addSubview(stackView)
        stackView.mas_makeConstraints { (make) in
            make.edges.mas_equalTo()(self)
        }
        
        stackView.axis = .Vertical
        stackView.distribution = .Fill
        stackView.alignment = .Fill
        stackView.spacing = 0
    }
    
    private func resetPulsaOperator() {
        selectedOperator = PulsaOperator()
    }
    
    private func resetCheckBox() {
        saldoCheckBox.on = false
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
    
    private func setRightViewNumberField(inputtedPrefix: String) {
        if(self.selectedCategory.attributes.validate_prefix) {
            let prefix = self.findPrefix(inputtedPrefix)
            
            if(prefix.phoneNumber != "") {
                self.findProducts((prefix.id), categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
                self.setSelectedOperatorWithOperatorId(prefix.id)
                
                let prefixImage = UIImageView(frame: CGRectMake(0, 0, 45, 30))
                prefixView?.removeAllSubviews()
                prefixView?.addSubview(prefixImage)
                prefixImage.setImageWithURL((NSURL(string: (prefix.image))))
                prefixImage.contentMode = .ScaleAspectFit
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
            self.prefixView!.addSubview(prefixImage)
            prefixImage.setImageWithURL((NSURL(string: self.selectedOperator.attributes.image)))
            
            self.numberField.rightViewMode = .Always
            self.numberField.clearButtonMode = .Always
            
        }
        
        self.numberField.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = { textField, range, string in
            guard let text = textField.text else { return true }
            
            let newLength = text.characters.count + string.characters.count - range.length
            // 14 is longest phone number existed
            return newLength <= (self.selectedOperator.attributes.maximum_length > 0 ? self.selectedOperator.attributes.maximum_length : 14)
        }
    }
    
    
    
    private func attachArrowToButton(button: UIButton) {
        button.setImage(UIImage(named: "icon_arrow_down_grey"), forState: .Normal)
        button.layoutIfNeeded()
        button.imageEdgeInsets = UIEdgeInsetsMake(0, self.productButton.frame.size.width - 15, 0, 0)
    }
    
    private func activateContactPermission() {
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
    
    private func addActionNumberField() {
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
}

