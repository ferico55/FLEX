//
//  PulsaView.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import BEMCheckBox
import CFAlertViewController
import Foundation
import HMSegmentedControl
import JLPermissions
import MMNumberKeyboard
import UIKit

@objc
internal class PulsaView: UIView, MMNumberKeyboardDelegate, BEMCheckBoxDelegate {
    internal weak var navigator: PulsaNavigator!
    
    internal var onConsraintChanged: (() -> Void)?
    internal var onLayoutComplete: ((CGSize) -> Void)?
    
    fileprivate var stackView: UIStackView = UIStackView()
    fileprivate var pulsaCategoryControl: HMSegmentedControl = {
        let pulsaCategoryControl = HMSegmentedControl(sectionTitles: [])
        pulsaCategoryControl?.segmentWidthStyle = .fixed
        pulsaCategoryControl?.selectionIndicatorBoxOpacity = 0
        pulsaCategoryControl?.selectionStyle = .box
        pulsaCategoryControl?.selectedSegmentIndex = HMSegmentedControlNoSegment
        pulsaCategoryControl?.type = .text
        pulsaCategoryControl?.selectionIndicatorLocation = .down
        pulsaCategoryControl?.selectionIndicatorHeight = 2
        return pulsaCategoryControl!
    }()
    lazy fileprivate var noHandphoneLabel: UILabel = {
        var noHandphoneLabel = UILabel()
        noHandphoneLabel.font = UIFont.microTheme()
        noHandphoneLabel.textColor = self.titleTextColor
        return noHandphoneLabel
    }()
    internal var numberField: UITextField!
    lazy var productButton: UIButton = {
        var productButton = UIButton(frame: CGRect.zero)
        productButton.setTitle(ButtonConstant.defaultProductButtonTitle, for: UIControlState())
        productButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.54), for: UIControlState())
        productButton.backgroundColor = UIColor.white
        productButton.layer.borderWidth = 0
        productButton.contentHorizontalAlignment = .left
        return productButton
    }()
    lazy fileprivate var productButtonUnderlineView: UIView = {
        let productButtonUnderlineView = UIView()
        productButtonUnderlineView.backgroundColor = self.underlineViewColor
        return productButtonUnderlineView
    }()
    lazy fileprivate var numberFieldUnderlineView: UIView = {
        let numberFieldUnderlineView = UIView()
        numberFieldUnderlineView.backgroundColor = self.underlineViewColor
        return numberFieldUnderlineView
    }()
    
    lazy fileprivate var buyButton: UIButton = {
        let buyButton = UIButton(type: .system)
        buyButton.setTitle("Beli", for: .normal)
        buyButton.setTitleColor(.white, for: .disabled)
        buyButton.layer.cornerRadius = 3
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.backgroundColor = #colorLiteral(red: 1, green: 0.3411764706, blue: 0.1333333333, alpha: 1)
        buyButton.isHidden = true
        buyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        return buyButton
    }()
    
    fileprivate var buttonsPlaceholder: UIView!
    fileprivate var fieldPlaceholder: UIView!
    fileprivate var saldoButtonPlaceholder: UIView!
    fileprivate var buyButtonPlaceholder:UIView!
    fileprivate var phoneBook: UIImageView = {
        var phoneBook = UIImageView(image: #imageLiteral(resourceName: "icon_phonebook"))
        phoneBook.isUserInteractionEnabled = true
        return phoneBook
    }()
    lazy fileprivate var nominalLabel: UILabel = {
        let nominalLabel = UILabel()
        nominalLabel.text = "Nominal"
        nominalLabel.font = UIFont.microTheme()
        nominalLabel.textColor = self.titleTextColor
        return nominalLabel
    }()
    
    lazy fileprivate var saldoCheckBox: BEMCheckBox = {
        let saldoCheckBox = BEMCheckBox()
        saldoCheckBox.boxType = .square
        saldoCheckBox.lineWidth = 1
        saldoCheckBox.onTintColor = UIColor.white
        saldoCheckBox.onCheckColor = UIColor.white
        saldoCheckBox.onFillColor = self.tokopediaGreenColor
        saldoCheckBox.animationDuration = 0
        saldoCheckBox.isHidden = true
        saldoCheckBox.delegate = self
        return saldoCheckBox
    }()
    lazy fileprivate var saldoLabel: UILabel = {
        let saldoLabel = UILabel(frame: CGRect.zero)
        saldoLabel.text = "Bayar Instan"
        saldoLabel.numberOfLines = 2
        saldoLabel.textColor = UIColor.gray
        saldoLabel.font = UIFont.largeTheme()
        saldoLabel.isHidden = true
        return saldoLabel
    }()
    
    lazy fileprivate var infoButton: UIButton = {
        let infoButton = UIButton(frame: CGRect.zero)
        infoButton.setImage(#imageLiteral(resourceName: "icon_info_grey"), for: .normal)
        infoButton.isHidden = true
        infoButton.bk_addEventHandler({ [weak self] button -> Void in
            self?.showInfo()
        }, for: .touchUpInside)
        return infoButton
    }()
    
    fileprivate var numberErrorPlaceholder: UIView!
    lazy fileprivate var numberErrorLabel: UILabel = {
        let numberErrorLabel = UILabel(frame: CGRect.zero)
        numberErrorLabel.backgroundColor = UIColor.white
        numberErrorLabel.text = "Error"
        numberErrorLabel.textColor = UIColor.red
        numberErrorLabel.font = UIFont.microTheme()
        return numberErrorLabel
    }()
    fileprivate var buttonErrorPlaceholder: UIView!
    lazy fileprivate var buttonErrorLabel: UILabel = {
        let buttonErrorLabel = UILabel(frame: CGRect.zero)
        buttonErrorLabel.backgroundColor = UIColor.white
        buttonErrorLabel.textColor = UIColor.red
        buttonErrorLabel.font = UIFont.microTheme()
        return buttonErrorLabel
    }()
    
    fileprivate var operatorPickerPlaceholder: UIView!
    fileprivate var operatorButton: UIButton!
    fileprivate var operatorErrorLabel: UILabel!
    
    fileprivate var seeAllButtonPlaceholder:UIView!
    lazy fileprivate var seeAllLabel:UILabel = {
        let seeAllLabel = UILabel(frame: CGRect.zero)
        seeAllLabel.backgroundColor = UIColor.white
        seeAllLabel.textColor = UIColor.tpGreen()
        seeAllLabel.font = UIFont.smallThemeMedium()
        seeAllLabel.text = "Lihat Semua"
        return seeAllLabel
    }()
    
    lazy fileprivate var titleLabel:UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.tpPrimaryBlackText()
        titleLabel.font = UIFont.semiboldSystemFont(ofSize: 16)
        titleLabel.text = "Bayar ini itu di Tokopedia"
        return titleLabel
    }()
    
    internal var selectedOperator = PulsaOperator()
    internal var selectedCategory = PulsaCategory()
    internal var selectedProduct = PulsaProduct() {
        didSet {
            AnalyticsManager.trackEventName(GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE_DIGITAL, category: GA_EVENT_CATEGORY_HOMEPAGE_DIGITAL_WIDGET, action: "select product", label: "\(selectedCategory.attributes.name) - \(selectedProduct.attributes.desc)")
        }
    }
    
    fileprivate var userManager = UserAuthentificationManager()
    fileprivate var prefixView: UIView?
    fileprivate var inputtedNumber: String?
    fileprivate var listOperators: [PulsaOperator]?
    
    internal var didTapAddressbook: (() -> Void)?
    internal var didTapProduct:(([PulsaProduct]) -> Void)?
    internal var didTapOperator:(([PulsaOperator]) -> Void)?
    internal var didTapSeeAll: (() -> Void)?
    internal var didAskedForLogin: (() -> Void)?
    internal var didShowAlertPermission: (() -> Void)?
    internal var didSuccessPressBuy: ((URL) -> Void)?
    
    fileprivate let widgetLeftMargin: CGFloat = 16
    fileprivate let widgetRightMargin: CGFloat = 16
    fileprivate let underlineOffset: CGFloat = 4
    
    fileprivate var arrangedPrefix = [Prefix]()
    
    fileprivate let tokopediaGreenColor = #colorLiteral(red: 0.2588235294, green: 0.7098039216, blue: 0.2862745098, alpha: 1)
    fileprivate let underlineViewColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    fileprivate let titleTextColor = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
    
    internal struct Prefix {
        internal var phoneNumber: String
        internal var image: String
        internal var id: String
    }
    
    internal struct ButtonConstant {
        internal static let defaultProductButtonTitle = "- Pilih -"
    }
    
    internal struct CategoryConstant {
        internal static let Pulsa = "1"
        internal static let PaketData = "2"
        internal static let Listrik = "3"
    }
    
    public init(categories: [PulsaCategory]) {
        super.init(frame: .zero)
        
        self.setCornerRadius()
        setupStackViewFormat()
        NotificationCenter .default.addObserver(self, selector: #selector(self.didSwipeHomePage), name: NSNotification.Name(rawValue: "didSwipeHomePage"), object: nil)
        NotificationCenter .default.addObserver(self, selector: #selector(self.didSwipeHomePage), name: NSNotification.Name(rawValue: "didSwipeHomeTab"), object: nil)
        
        pulsaCategoryControl.redDotImage = #imageLiteral(resourceName: "red_dot")
        categories.enumerated().forEach { index, category in
            pulsaCategoryControl.sectionTitles.append(category.attributes.name)
            if category.attributes.is_new {
                pulsaCategoryControl.showRedDot(at: index)
            }
        }
        
        let categoryControlPlaceHolder = UIView()
        categoryControlPlaceHolder.mas_makeConstraints { (make) in
            make?.height.equalTo()(51)
        }
        stackView.addArrangedSubview(categoryControlPlaceHolder)
        categoryControlPlaceHolder.addSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make?.top.left().right().mas_equalTo()(categoryControlPlaceHolder)
            make?.bottom.mas_equalTo()(categoryControlPlaceHolder)?.offset()(-1)
        }
        pulsaCategoryControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : self.tokopediaGreenColor, NSFontAttributeName : UIFont.largeThemeMedium()]
        pulsaCategoryControl.titleTextAttributes = [NSForegroundColorAttributeName : self.titleTextColor
            , NSFontAttributeName : UIFont.largeTheme()]
        pulsaCategoryControl.selectionIndicatorColor = self.tokopediaGreenColor
        pulsaCategoryControl.bk_addEventHandler({[unowned self] (control: Any) in
            self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, for: UIControlState())
            guard let control = control as? HMSegmentedControl else { return }
            let selectedCategory = categories[control.selectedSegmentIndex]
            self.buildViewByCategory(selectedCategory)
            }, for: .valueChanged)
        
        let categoryControlUnderline = UIView()
        categoryControlUnderline.backgroundColor = underlineViewColor
        categoryControlPlaceHolder.addSubview(categoryControlUnderline)
        categoryControlUnderline.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(self.pulsaCategoryControl.mas_bottom)
            make?.left.right().mas_equalTo()(categoryControlPlaceHolder)
            make?.height.mas_equalTo()(1)
        }
        
        if let firstCategory = categories.first {
            requestOperatorsWithInitialCategory(firstCategory)
        }
        self.buildSeeAllButton()
    }
    
    public func setCategories(categories: [PulsaCategory]) {
        pulsaCategoryControl = HMSegmentedControl(sectionTitles: [])
        pulsaCategoryControl.redDotImage = #imageLiteral(resourceName: "red_dot")
        pulsaCategoryControl.segmentWidthStyle = .fixed
        pulsaCategoryControl.selectionIndicatorBoxOpacity = 0
        pulsaCategoryControl.selectionStyle = .box
        pulsaCategoryControl.selectedSegmentIndex = HMSegmentedControlNoSegment
        pulsaCategoryControl.type = .text
        pulsaCategoryControl.selectionIndicatorLocation = .down
        pulsaCategoryControl.selectionIndicatorHeight = 2

        categories.enumerated().forEach { index, category in
            pulsaCategoryControl.sectionTitles.append(category.attributes.name)
            if category.attributes.is_new {
                pulsaCategoryControl.showRedDot(at: index)
            }
        }
        
        let categoryControlPlaceHolder = UIView()
        categoryControlPlaceHolder.mas_makeConstraints { (make) in
            make?.height.equalTo()(51)
        }
        stackView.removeAllSubviews()
        stackView.addArrangedSubview(categoryControlPlaceHolder)
        categoryControlPlaceHolder.addSubview(pulsaCategoryControl)
        pulsaCategoryControl.mas_makeConstraints { make in
            make?.top.left().right().mas_equalTo()(categoryControlPlaceHolder)
            make?.bottom.mas_equalTo()(categoryControlPlaceHolder)?.offset()(-1)
        }
        pulsaCategoryControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : self.tokopediaGreenColor, NSFontAttributeName : UIFont.largeThemeMedium()]
        pulsaCategoryControl.titleTextAttributes = [NSForegroundColorAttributeName : self.titleTextColor
            , NSFontAttributeName : UIFont.largeTheme()]
        pulsaCategoryControl.selectionIndicatorColor = self.tokopediaGreenColor
        pulsaCategoryControl.bk_addEventHandler({[unowned self] (control: Any) in
            self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, for: UIControlState())
            guard let control = control as? HMSegmentedControl else { return }
            let selectedCategory = categories[control.selectedSegmentIndex]
            self.buildViewByCategory(selectedCategory)
            self.resignFirstResponder()
            }, for: .valueChanged)
        
        let categoryControlUnderline = UIView()
        categoryControlUnderline.backgroundColor = underlineViewColor
        categoryControlPlaceHolder.addSubview(categoryControlUnderline)
        categoryControlUnderline.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(self.pulsaCategoryControl.mas_bottom)
            make?.left.right().mas_equalTo()(categoryControlPlaceHolder)
            make?.height.mas_equalTo()(1)
        }
        
        requestOperatorsWithInitialCategory(categories.first!)
    }
    
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func requestOperatorsWithInitialCategory(_ category: PulsaCategory) {
        let requestManager = PulsaRequest()
        
        requestManager.didReceiveOperator = { operators in
            let sortedOperators = operators.sorted(by: { (op0, op1) -> Bool in
                op0.attributes.weight < op1.attributes.weight
            })
            
            self.listOperators = sortedOperators
            self .createPrefixCollection(sortedOperators)
            
            //view must be built after receive operator
            //because on some case like pulsa and data, we need prefixes (only exists in operator attributes)
            //and if we show view, when there is no prefix, this will cause crash
            self.buildViewByCategory(category)
            self.pulsaCategoryControl.selectedSegmentIndex = 0
            self.pulsaCategoryControl.backgroundColor = UIColor.white
        }
        requestManager.requestOperator()
    }
    
    fileprivate func createPrefixCollection(_ operators: [PulsaOperator]) {
        operators.enumerated().forEach { id, op in
            op.attributes.prefix.forEach { prefix in
                let prefix = Prefix(phoneNumber: prefix, image: op.attributes.image, id: op.id!)
                arrangedPrefix.append(prefix)
            }
        }
    }
    
    fileprivate func findProducts(_ operatorId: String, categoryId: String, didReceiveProduct: (([PulsaProduct]) -> Void)?) {
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
    
    fileprivate func findOperatorsFromProducts(_ products: [PulsaProduct]) -> [PulsaOperator]{
        var operators = [PulsaOperator]()
        
        products.enumerated().forEach { (index, product) in
            let operatorId = product.relationships.relationOperator.data.id
            let foundOperator = self .findOperatorById(operatorId!)! as PulsaOperator
            
            if(!operators.contains(foundOperator)) {
                operators.append(foundOperator)
            }
        }
        
        return operators
    }
    
    func findOperatorById(_ id: String) -> PulsaOperator? {
        return self.listOperators?.filter({ (op) -> Bool in
            op.id == id
        }).first
    }
    
    fileprivate func setSelectedOperatorWithOperatorId(_ id : String?) {
        let operatorId = id ?? self.selectedCategory.attributes.default_operator_id
        if let selectedOperator = self.findOperatorById(operatorId) {
            self.selectedOperator = selectedOperator
            if (self.operatorButton != nil) {
                self.operatorButton.setTitle(self.selectedOperator.attributes.name, for: .normal)
                 AnalyticsManager.trackEventName(GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE_DIGITAL, category: GA_EVENT_CATEGORY_HOMEPAGE_DIGITAL_WIDGET, action: "select operator", label: "\(selectedCategory.attributes.name) - \(selectedOperator.attributes.name)")
            }
        }
    }
    
    fileprivate func setDefaultProductWithOperatorId(_ operatorId: String) {
        self.findProducts(operatorId, categoryId: self.selectedCategory.id!) { (product) in
            self.selectedProduct = product.first!
        }
    }
    
    fileprivate func setSelectedProduct(with productId: String?) {
        let id = productId ?? self.selectedOperator.attributes.default_product_id
        guard self.selectedOperator.id != nil else {
            return
        }
        
        self.findProducts(self.selectedOperator.id!, categoryId: self.selectedCategory.id!) { (product) in
            let selected = product.filter { $0.id! == id }.first
            if let select = selected {
                self.selectedProduct = select
                self.productButton.setTitle(self.selectedProduct.attributes.desc, for: .normal)
            } else {
                self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, for: .normal)
            }
        }
    }
    
    // MARK: Build View
    
    func buildViewByOperator(_ pulsaOperator: PulsaOperator) {
        self.resetPulsaOperator()
        self.buildAllView(self.selectedCategory)
        
        self.findProducts(pulsaOperator.id!, categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
        self.setSelectedOperatorWithOperatorId(pulsaOperator.id!)
        self.operatorButton.setTitle(pulsaOperator.attributes.name, for: .normal)
        
        if(self.selectedOperator.id != nil && !self.selectedOperator.attributes.rule.show_product) {
            self.setDefaultProductWithOperatorId(self.selectedOperator.id!)
        }
    }
    
    fileprivate func buildViewByCategory(_ category: PulsaCategory) {
        self.selectedCategory = category
        AnalyticsManager.trackEventName(GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE_DIGITAL, category: GA_EVENT_CATEGORY_HOMEPAGE_DIGITAL_WIDGET, action: "click widget", label: selectedCategory.attributes.name)
        self.resetPulsaOperator()
        self.buildAllView(category)
        self.getLastOrder(category: category.id!)
        self.resetCheckBox()
        
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
                self.findProducts(self.selectedCategory.attributes.default_operator_id, categoryId: self.selectedCategory.id!,didReceiveProduct: nil)
            }
        }
    }
    
    fileprivate func buildOperatorButton() {
        let operatorTitle = (self.selectedOperator.attributes.name != "") ? self.selectedOperator.attributes.name : ButtonConstant.defaultProductButtonTitle
        operatorPickerPlaceholder = UIView(frame: CGRect.zero)
        operatorPickerPlaceholder.backgroundColor = UIColor.white
        stackView.addArrangedSubview(operatorPickerPlaceholder)
        
        operatorButton = UIButton(frame: CGRect.zero)
        operatorButton.setTitle(operatorTitle, for: .normal)
        
        operatorButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.54), for: UIControlState())
        operatorButton.contentHorizontalAlignment = .left
        operatorButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        
        operatorPickerPlaceholder.addSubview(operatorButton)
        
        operatorPickerPlaceholder.mas_makeConstraints { (make) in
            make?.height.equalTo()(self.selectedCategory.attributes.show_operator ? 38 : 0)
        }
        
        operatorButton.mas_makeConstraints { make in
            make?.centerY.mas_equalTo()(self.operatorPickerPlaceholder)
            make?.height.mas_equalTo()(25)
            make?.left.mas_equalTo()(self.operatorPickerPlaceholder.mas_left)?.offset()(15)
            make?.right.equalTo()(self.operatorPickerPlaceholder.mas_right)?.offset()(-15)
        }
        
        operatorButton.bk_removeEventHandlers(for: .touchUpInside)
        operatorButton.bk_addEventHandler({ [weak self](button) in
            guard let `self` = self else { return }
            
            self.findProducts("", categoryId: self.selectedCategory.id!, didReceiveProduct: { receivedProducts in
                let operators = self.findOperatorsFromProducts(receivedProducts)
                self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, for: UIControlState())
                self.didTapOperator?(operators)
            })
            
            }, for: .touchUpInside)
        let operatorButtonUnderline = UIView()
        operatorButtonUnderline.backgroundColor = underlineViewColor
        operatorPickerPlaceholder.addSubview(operatorButtonUnderline)
        operatorButtonUnderline.mas_makeConstraints({ make in
            make?.height.mas_equalTo()(1)
            make?.top.mas_equalTo()(self.operatorButton.mas_bottom)?.offset()(self.underlineOffset)
            make?.left.mas_equalTo()(self.operatorButton.mas_left)
            make?.right.mas_equalTo()(self.operatorButton.mas_right)
        })
        
        operatorErrorLabel = UILabel(frame: CGRect.zero)
        operatorErrorLabel.textColor = UIColor.red
        operatorErrorLabel.font = UIFont.systemFont(ofSize: 12)
        stackView.addArrangedSubview(operatorErrorLabel)
        
        operatorErrorLabel.mas_makeConstraints { make in
            make?.height.equalTo()(0)
        }
        self.attachArrowToButton(operatorButton)
        
        notifyContentSizeChanged()
    }
    
    fileprivate func buildButtons(_ category: PulsaCategory) {
        buttonsPlaceholder = UIView(frame: CGRect.zero)
        buttonsPlaceholder.backgroundColor = UIColor.white
        stackView.addArrangedSubview(buttonsPlaceholder)

        buttonsPlaceholder.addSubview(nominalLabel)
        nominalLabel.mas_makeConstraints{ make in
            make?.top.equalTo()(self.buttonsPlaceholder.mas_top)?.with().offset()(16)
            make?.left.equalTo()(self.buttonsPlaceholder)?.with().offset()(16)
        }
    
        buttonsPlaceholder.addSubview(productButton)
        
        productButton.mas_makeConstraints { make in
            make?.top.equalTo()(self.nominalLabel.mas_bottom)?.with().offset()(6)
            make?.height.equalTo()(25)
            make?.left.equalTo()(self.nominalLabel)
            make?.right.equalTo()(self.buttonsPlaceholder)?.with().offset()(-16)
        }
        
        productButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        
        buttonsPlaceholder.mas_makeConstraints { make in
            make?.height.equalTo()(0)
        }
        
        buttonsPlaceholder.addSubview(productButtonUnderlineView)
        productButtonUnderlineView.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(self.productButton.mas_bottom)?.with().offset()(self.underlineOffset)
            make?.left.right().mas_equalTo()(self.productButton)
            make?.height.mas_equalTo()(1)
        }
        
        buttonErrorPlaceholder = UIView()
        buttonErrorPlaceholder.backgroundColor = UIColor.white
        buttonErrorPlaceholder.clipsToBounds = true
        buttonErrorPlaceholder.mas_makeConstraints { (make) in
            make?.height.equalTo()(0)
        }
        
        stackView.addArrangedSubview(buttonErrorPlaceholder)
        buttonErrorPlaceholder.addSubview(buttonErrorLabel)
        
        buttonErrorLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.nominalLabel)
            make?.centerY.mas_equalTo()(self.buttonErrorPlaceholder)
        }
        attachArrowToButton(productButton)
        
        notifyContentSizeChanged()
    }
    
    fileprivate func buildAllView(_ category: PulsaCategory) {
        stackView.arrangedSubviews.enumerated().forEach { index, subview in
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
        self.buildBuyButtonPlaceholder()
    }
    
    fileprivate func buildBuyButtonPlaceholder() {
        buyButtonPlaceholder = UIView(frame: CGRect.zero)
        buyButtonPlaceholder.backgroundColor = UIColor.white
        stackView.addArrangedSubview(buyButtonPlaceholder)
        buyButtonPlaceholder.mas_makeConstraints { make in
            make?.height.equalTo()(0)
        }
        
        buyButtonPlaceholder.addSubview(buyButton)
        buyButton.mas_makeConstraints { make in
            make?.width.equalTo()(self.buyButtonPlaceholder.mas_width)?.dividedBy()(2)?.offset()(-16)
            make?.centerY.equalTo()(self.buyButtonPlaceholder)
            make?.right.equalTo()(self.buyButtonPlaceholder.mas_right)?.with().offset()(-16)
            make?.top.equalTo()(self.buyButtonPlaceholder.mas_top)?.offset()(16)
            make?.bottom.equalTo()(self.buyButtonPlaceholder.mas_bottom)?.offset()(-16)
        }
        
        buyButton.bk_removeEventHandlers(for: .touchUpInside)
        buyButton.bk_addEventHandler({ button -> Void in
            self.didPressBuyButton()
            }, for: .touchUpInside)
        showBuyButton()
        
        buyButtonPlaceholder.addSubview(self.saldoCheckBox)
        self.saldoCheckBox.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.buyButtonPlaceholder)
            make?.width.height().equalTo()(18)
            make?.left.equalTo()(self.productButton.mas_left)
        }
        
        buyButtonPlaceholder.addSubview(saldoLabel)
        saldoLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.saldoCheckBox)
            make?.width.equalTo()(120)
            make?.left.equalTo()(self.saldoCheckBox.mas_right)?.offset()(5)
        }
        
        buyButtonPlaceholder.addSubview(self.infoButton)
        self.infoButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.saldoCheckBox)
            make?.left.equalTo()(self.saldoLabel.mas_right)?.offset()(-35)
        }
    }
    
    fileprivate func buildNumberField(_ category: PulsaCategory) {
        //if no client number shown, then skip build field control
        if(!self.selectedCategory.attributes.client_number.is_shown) {
            return;
        }
        
        fieldPlaceholder = UIView(frame: CGRect.zero)
        fieldPlaceholder.backgroundColor = UIColor.white
        stackView.addArrangedSubview(fieldPlaceholder)
        fieldPlaceholder.mas_makeConstraints { make in
            make?.height.mas_equalTo()(62)
        }

        noHandphoneLabel.text = category.attributes.client_number.text
        fieldPlaceholder.addSubview(noHandphoneLabel)
        
        noHandphoneLabel.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(self.fieldPlaceholder.mas_top)?.offset()(16)
            make?.left.equalTo()(self.fieldPlaceholder.mas_left)?.offset()(self.widgetLeftMargin)
        }
        
        if numberField != nil {
            self.inputtedNumber = numberField.text!
        }
        numberField = UITextField(frame: CGRect.zero)
        numberField.placeholder = category.attributes.client_number.placeholder
        numberField.borderStyle = .none
        numberField.rightViewMode = .always
        numberField.keyboardType = .numberPad
        numberField.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.54)
        numberField.clearButtonMode = .always
        
        let keyboard =  MMNumberKeyboard(frame: CGRect.zero)
        keyboard.allowsDecimalPoint = false
        keyboard.delegate = self
        keyboard.returnKeyTitle = "Beli"
        
        numberField.inputView = keyboard
        
        if(category.attributes.use_phonebook) {
            phoneBook = UIImageView(image: #imageLiteral(resourceName: "icon_phonebook"))
            phoneBook.isUserInteractionEnabled = true
            fieldPlaceholder.addSubview(phoneBook)
            
            phoneBook.mas_makeConstraints { make in
                make?.height.equalTo()(25)
                make?.width.equalTo()(25)
                make?.right.equalTo()(self.fieldPlaceholder.mas_right)?.offset()(-15)
                make?.top.equalTo()(self.noHandphoneLabel.mas_bottom)?.offset()(4)
            }
            
            phoneBook.bk_(whenTapped: { [unowned self] in
                self.activateContactPermission()
            })
        }
        
        fieldPlaceholder.addSubview(numberField)
        numberField.mas_makeConstraints { make in
            make?.height.equalTo()(25)
            make?.top.equalTo()(self.noHandphoneLabel.mas_bottom)?.offset()(4)
            make?.left.equalTo()(self.noHandphoneLabel.mas_left)
            if(category.attributes.use_phonebook) {
                make?.right.equalTo()(self.phoneBook.mas_left)?.offset()(-16)
            } else {
                make?.right.equalTo()(self.fieldPlaceholder.mas_right)?.offset()(-16)
            }

        }
        
        fieldPlaceholder.addSubview(numberFieldUnderlineView)
        numberFieldUnderlineView.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(self.numberField.mas_bottom)?.offset()(self.underlineOffset)
            make?.left.mas_equalTo()(self.numberField.mas_left)
            make?.right.mas_equalTo()(self.numberField.mas_right)
            make?.height.mas_equalTo()(1)
        }
        
        self.prefixView = UIView()
        self.numberField.addSubview(self.prefixView!)
        self.prefixView!.mas_makeConstraints({ (make) in
            make?.right.mas_equalTo()(self.numberField.mas_right)?.with().offset()(-75)
            make?.centerY.mas_equalTo()(self.numberField.mas_centerY)?.with().offset()(-16)
        })
        
        numberErrorPlaceholder = UIView()
        numberErrorPlaceholder.backgroundColor = UIColor.white
        numberErrorPlaceholder.clipsToBounds = true
        numberErrorPlaceholder.mas_makeConstraints { (make) in
            make?.height.mas_equalTo()(0)
        }
        
        stackView.addArrangedSubview(numberErrorPlaceholder)
        numberErrorPlaceholder.addSubview(numberErrorLabel)
        
        numberErrorLabel.mas_makeConstraints { make in
            make?.left.mas_equalTo()(self.noHandphoneLabel)
            make?.centerY.mas_equalTo()(self.numberErrorPlaceholder)
        }
    }
    
    fileprivate func buildSeeAllButton() {
        seeAllButtonPlaceholder = UIView(frame: CGRect.zero)
        seeAllButtonPlaceholder.backgroundColor = UIColor.white
        stackView.addArrangedSubview(seeAllButtonPlaceholder)
        seeAllButtonPlaceholder.mas_makeConstraints { (make) in
            make?.height.equalTo()(56)
        }
        
        seeAllButtonPlaceholder.addSubview(seeAllLabel)
        seeAllLabel.mas_makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make?.centerY.equalTo()(self.seeAllButtonPlaceholder.mas_centerY)
            make?.right.equalTo()(self.seeAllButtonPlaceholder.mas_right)?.offset()(-16)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToDigitalCategory(sender:)))
        seeAllLabel.isUserInteractionEnabled = true
        seeAllLabel.addGestureRecognizer(tap)
        
        seeAllButtonPlaceholder.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { [weak self] (make) in
            guard let `self` = self else { return }
            make?.centerY.equalTo()(self.seeAllButtonPlaceholder.mas_centerY)
            make?.left.equalTo()(self.seeAllButtonPlaceholder.mas_left)?.offset()(16)
        }
    }
    
    internal func goToDigitalCategory(sender:UITapGestureRecognizer) {
        AnalyticsManager.trackEventName("clickDigitalNative", category: "homepage digital", action: "click lihat semua produk", label: "")
        self.didTapSeeAll?()
    }
    
    fileprivate func getLastOrder(category:String) {
        DigitalService()
            .lastOrder(categoryId: category)
            .subscribe(onNext: { [weak self] lastOrder in
                self?.setLastOrderData(order: lastOrder)
            }).disposed(by: self.rx_disposeBag)
    }
    
    internal func setLastOrderData(order:DigitalLastOrder) {
        self.inputtedNumber = order.clientNumber
        if let input = self.inputtedNumber, let numberField = self.numberField {
            numberField.text = input
            self.checkInputtedNumber()
        }
        self.setSelectedOperatorWithOperatorId(order.operatorId)
        
        self.setSelectedProduct(with: order.productId)
    }
    
    //MARK: Show or Hide View
    internal func hideErrors() {
        _ = self.numberErrorPlaceholder?.mas_updateConstraints { make in
            make?.height.equalTo()(0)
        }
        
        _ = self.buttonErrorPlaceholder?.mas_updateConstraints { make in
            make?.height.equalTo()(0)
        }
        
        _ = self.operatorErrorLabel?.mas_updateConstraints { make in
            make?.height.equalTo()(0)
        }
    }
    
    fileprivate func showProductButton(_ products: [PulsaProduct]) {
        UIView.animate(withDuration: 0.25) {
            _ = self.saldoButtonPlaceholder?.mas_updateConstraints({ (make) in
                make?.height.equalTo()(self.selectedCategory.attributes.instant_checkout_available ? 41 : 0)
            })
            self.buttonsPlaceholder.mas_updateConstraints { make in
                make?.height.equalTo()(self.selectedOperator.attributes.rule.show_product ? 66 : 0)
            }
            self.layoutIfNeeded()
            self.notifyContentSizeChanged()
        }
        //prevent keep adding button to handler
        productButton.bk_removeEventHandlers(for: .touchUpInside)
        productButton.bk_addEventHandler({ button -> Void in
            self.didTapProduct!(products)
            }, for: .touchUpInside)
    }
    
    fileprivate func hideBuyButtons() {
        buttonsPlaceholder.mas_updateConstraints { (make) in
            make?.height.equalTo()(0)
        }
        
        buyButton.mas_updateConstraints { make in
            make?.height.equalTo()(0)
        }
        
        buyButtonPlaceholder.mas_updateConstraints { (make) in
            make?.height.equalTo()(0)
        }
        self.saldoCheckBox.isHidden = true
        self.saldoLabel.isHidden = true
        self.infoButton.isHidden = true
        
        _ = saldoButtonPlaceholder?.mas_updateConstraints({ (make) in
            make?.height.equalTo()(0)
        })
        
        notifyContentSizeChanged()
    }
    
    fileprivate func showBuyButton() {
        
        buyButton.mas_updateConstraints { make in
            make?.height.equalTo()(40)
        }
        
        buyButtonPlaceholder.mas_updateConstraints { (make) in
            make?.height.equalTo()(72)
        }
        
        self.saldoCheckBox.isHidden = self.selectedCategory.attributes.instant_checkout_available ? false : true
        self.saldoLabel.isHidden = self.selectedCategory.attributes.instant_checkout_available ? false : true
        self.infoButton.isHidden = self.selectedCategory.attributes.instant_checkout_available ? false : true
        
        self.buyButton.isHidden = false
        
        notifyContentSizeChanged()
    }
    
    fileprivate func hideProductButton() {
        buttonsPlaceholder.mas_updateConstraints { (make) in
            make?.height.equalTo()(0)
        }
        
        buyButton.bk_removeEventHandlers(for: .touchUpInside)
        buyButton.bk_addEventHandler({ button -> Void in
            self.didPressBuyButton()
            }, for: .touchUpInside)
        self.prefixView?.isHidden = true
        
        notifyContentSizeChanged()
    }
    
    fileprivate func showAddressBook() {
        self.didTapAddressbook?()
    }
    
    fileprivate func showContactAlertPermission() {
        self.didShowAlertPermission?()
    }
    
    // MARK: Did Press Button
    
    fileprivate func didPressBuyButton() {
        let isValidNumber = (!self.selectedCategory.attributes.client_number.is_shown || self.isValidNumber(self.numberField.text!))
        if let callback = self.onConsraintChanged {
            callback()
        }
        
        _ = self.numberErrorPlaceholder?.mas_updateConstraints { make in
            make?.height.equalTo()(!isValidNumber ? 22 : 0)
        }
        
        self.buttonErrorPlaceholder.mas_updateConstraints { make in
            make?.height.equalTo()((!self.isValidProduct()) ? 22 : 0)
        }
        
        _ = self.operatorErrorLabel?.mas_updateConstraints { make in
            make?.height.equalTo()((!self.operatorButton.isHidden && !self.isValidOperator()) ? 22 : 0)
        }
        
        if(isValidOperator() && self.isValidProduct() && isValidNumber) {
            func revertBuyButton() {
                buyButton.setTitle("Beli", for: .normal)
                buyButton.isEnabled = true
                buyButton.titleLabel?.textColor = .white
            }
            
            self.hideErrors()
            
            var clientNumber = ""
            if numberField != nil {
                clientNumber = numberField.text!
            }
            
            buyButton.titleLabel?.textColor = .white
            buyButton.setTitle("Sedang proses...", for: .normal)
            buyButton.isEnabled = false
            
            if (self.saldoCheckBox.on) {
                AnalyticsManager.trackEventName(GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE_DIGITAL, category: "homepage digital widget", action: "click beli - \(self.selectedCategory.attributes.name)", label: "instant")
            } else {
                AnalyticsManager.trackEventName(GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE_DIGITAL, category: "homepage digital widget", action: "click beli - \(self.selectedCategory.attributes.name)", label: "no instant")
            }
            AnalyticsManager.trackDigitalProductAddToCart(category: self.selectedCategory, operators: self.selectedOperator, product: self.selectedProduct, isInstant: self.saldoCheckBox.on)
            
            let cache = PulsaCache()
            let lastOrder = DigitalLastOrder(categoryId: self.selectedCategory.id!, operatorId: self.selectedOperator.id, productId: self.selectedProduct.id, clientNumber: clientNumber)
            cache.storeLastOrder(lastOrder: lastOrder)
            self.saveInstantPaymentCheck()
            
            DigitalService()
                .purchase(from: self.navigator.controller,
                          withProductId: self.selectedProduct.id!,
                          categoryId: self.selectedCategory.id!,
                          inputFields: ["client_number": clientNumber],
                          instantPaymentEnabled: self.saldoCheckBox.on,
                          onNavigateToCart: revertBuyButton)
                .subscribe(
                    onNext: {
                        revertBuyButton()
                    },
                    onError: { error in
                        let errorMessage = error as? String ?? "Kendala koneksi internet, silahkan coba kembali"
                        StickyAlertView.showErrorMessage([errorMessage])
                        AnalyticsManager.trackRechargeEvent(event: .homepage, category: self.selectedCategory, operators: self.selectedOperator, product: self.selectedProduct, action: "Homepage Error Widget- \(errorMessage)")
                        revertBuyButton()
                    }
                )
                .disposed(by: self.rx_disposeBag)

        }
    }
    
    // MARK: MMNumberKeyboard Delegate
    
    internal func numberKeyboardShouldReturn(_ numberKeyboard: MMNumberKeyboard!) -> Bool {
        self.didPressBuyButton()
        return true
    }
    
    // set custom keyboard to textField inputview will remove shouldChangeCharactersInRange:replacementString delegate
    // as an alternative, i tried to check maximum length through MMNumberKeyboard's delegate to estimate maximum length
    internal func numberKeyboard(_ numberKeyboard: MMNumberKeyboard!, shouldInsertText text: String!) -> Bool {
        if(self.selectedOperator.attributes.name != "") {
            if((self.numberField.text?.characters.count)! <= self.selectedOperator.attributes.maximum_length - 1) {
                return true
            }
            
            return false
        }
        
        return true
    }
    
    // MARK: Validation Checking
    
    fileprivate func isValidNumber(_ number: String) -> Bool{
        guard self.selectedOperator.id != nil else {
            if(self.selectedCategory.attributes.validate_prefix) {
                return self.isValidNumberLength(number)
            }
            
            return true
        }
        
        return self.isValidNumberLength(number)
        
    }
    
    fileprivate func isValidNumberLength(_ number: String) -> Bool {
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
    
    fileprivate func isValidOperator() -> Bool {
        if(self.operatorButton?.currentTitle == ButtonConstant.defaultProductButtonTitle && self.selectedCategory.attributes.show_operator == true) {
            operatorErrorLabel.text = "Pilih operator terlebih dahulu"
            return false
        }
        
        return true
    }
    
    fileprivate func isValidProduct() -> Bool {
        if(self.productButton.currentTitle == ButtonConstant.defaultProductButtonTitle && self.selectedOperator.attributes.rule.show_product == true) {
            buttonErrorLabel.text = "Pilih nominal terlebih dahulu"
            return false
        }
        
        return true
    }
    
    fileprivate func attachToView(_ container: UIView) {
        container.addSubview(self)
        
        self.mas_makeConstraints {make in
            make?.left.equalTo()(container.mas_left)?.offset()(10)
            make?.top.equalTo()(container.mas_top)?.offset()(10)
            make?.right.equalTo()(container.mas_right)?.offset()(-10)
            make?.bottom.equalTo()(container.mas_bottom)
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
    
    fileprivate func setupStackViewFormat() {
        self.addSubview(stackView)
        stackView.mas_makeConstraints { (make) in
            make?.edges.mas_equalTo()(self)
        }
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
    }
    
    fileprivate func resetPulsaOperator() {
        selectedOperator = PulsaOperator()
    }
    
    fileprivate func resetCheckBox() {
        saldoCheckBox.on = loadInstantPaymentCheck()
    }
    
    fileprivate func findPrefix(_ inputtedString: String) -> Prefix {
        var returnPrefix = Prefix(phoneNumber: "", image: "", id: "")
        self.arrangedPrefix.forEach { (prefix) in
            if(inputtedString.hasPrefix(prefix.phoneNumber)) {
                returnPrefix = prefix
            }
        }
        
        return returnPrefix
    }
    
    fileprivate func setRightViewNumberField(_ inputtedPrefix: String) {
        if(self.selectedCategory.attributes.validate_prefix) {
            let prefix = self.findPrefix(inputtedPrefix)
            
            if(prefix.phoneNumber != "") {
                self.findProducts((prefix.id), categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
                self.setSelectedOperatorWithOperatorId(prefix.id)
                
                let prefixImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
                prefixView?.removeAllSubviews()
                prefixView?.addSubview(prefixImage)
                prefixImage.setImageWith((URL(string: (prefix.image))))
                prefixImage.contentMode = .scaleAspectFit
                self.prefixView?.isHidden = false
                
                self.numberField.rightViewMode = .always
                self.numberField.clearButtonMode = .always
            } else {
                if let prefixView = self.prefixView {
                    prefixView.isHidden = true
                }
                
                resetPulsaOperator()
                self.hideProductButton()
            }
        } else {
            self.findProducts(self.selectedCategory.attributes.default_operator_id, categoryId: self.selectedCategory.id!, didReceiveProduct: nil)
            self.setSelectedOperatorWithOperatorId(self.selectedCategory.attributes.default_operator_id)
            
            let prefixImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
            self.prefixView!.addSubview(prefixImage)
            prefixImage.setImageWith((URL(string: self.selectedOperator.attributes.image)))
            
            self.numberField.rightViewMode = .always
            self.numberField.clearButtonMode = .always
            
        }
    
        self.numberField.bk_shouldChangeCharactersInRangeWithReplacementStringBlock = { [unowned self] textField, range, string in
            guard let text = textField?.text else { return true }
            
            let convertedString = self.convertAreaNumber(string!)
            let newLength = text.characters.count + convertedString.characters.count - range.length
            // 14 is longest phone number existed
            return newLength <= (self.selectedOperator.attributes.maximum_length > 0 ? self.selectedOperator.attributes.maximum_length : 14)
        }
    }
    
    fileprivate func attachArrowToButton(_ button: UIButton) {
        button.setImage(#imageLiteral(resourceName: "icon_arrow_down_grey"), for: UIControlState())
        button.layoutIfNeeded()
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.productButton.frame.size.width - 15, bottom: 0, right: 0)
    }
    
    fileprivate func activateContactPermission() {
        let permission = JLContactsPermission.sharedInstance()
        let permissionStatus = permission.authorizationStatus()
        
        if(permissionStatus == JLAuthorizationStatus.permissionNotDetermined) {
            permission.isExtraAlertEnabled = false
            permission.authorize({ (granted, error) in
                if(granted) {
                    self.showAddressBook()
                } else {
                    self.showContactAlertPermission()
                }
            })
        } else if(permissionStatus == JLAuthorizationStatus.permissionDenied) {
            self.showContactAlertPermission()
        } else {
            self.showAddressBook()
        }
    }
    
    fileprivate func addActionNumberField() {
        numberField?.bk_addEventHandler ({[unowned self] number in
            self.hideErrors()
            self.checkInputtedNumber()
            self.numberField.rightViewMode = .always
            self.numberField.clearButtonMode = .always
            }, for: .editingChanged)
    }
    
    internal func checkInputtedNumber() {
        self.hideErrors()
        //operator must exists first
        //fix this to prevent crash using serial dispatch
        var inputtedText = self.numberField.text!
        
        if(self.selectedCategory.id == CategoryConstant.PaketData || self.selectedCategory.id == CategoryConstant.Pulsa ) {
            inputtedText = self.convertAreaNumber(inputtedText)
            self.numberField.text = inputtedText
        }
        
        self.setRightViewNumberField(inputtedText)
        self.productButton.setTitle(ButtonConstant.defaultProductButtonTitle, for: UIControlState())
    }
    
    //convert code area from +62 into 0
    fileprivate func convertAreaNumber(_ phoneNumber: String) -> String{
        var convertedNumber = phoneNumber
        convertedNumber = convertedNumber.replacingOccurrences(of: " ", with: "")
        if(phoneNumber.characters.count >= 3) {
            convertedNumber = convertedNumber.replacingOccurrences(of: "+62", with: "0", options: .caseInsensitive, range: phoneNumber.startIndex..<convertedNumber.index(convertedNumber.startIndex, offsetBy: 3))
            convertedNumber = convertedNumber.replacingOccurrences(of: "62", with: "0", options: .caseInsensitive, range: phoneNumber.startIndex..<convertedNumber.index(convertedNumber.startIndex, offsetBy: 2))
        }
        return convertedNumber
    }
    
    internal func didTap(_ checkBox: BEMCheckBox) {
        
    }
    
    fileprivate func saveInstantPaymentCheck() {
        if !self.saldoCheckBox.isHidden {
            UserDefaults.standard.isInstantPaymentEnabled = self.saldoCheckBox.on
        }
    }
    
    fileprivate func loadInstantPaymentCheck() -> Bool{
        if !self.saldoCheckBox.isHidden {
            return UserDefaults.standard.isInstantPaymentEnabled
        }
        return false
    }
    
    fileprivate func showInfo() {
        let closeButton = CFAlertAction.action(title: "Tutup", style: .Destructive, alignment: .justified, backgroundColor: UIColor.tpGreen(), textColor: .white, handler: nil)
        let actionSheet = TooltipAlert.createAlert(title: "Bayar Instan", subtitle: "Selesaikan transaksi dengan 1 klik saja menggunakan TokoCash", image: #imageLiteral(resourceName:"icon_bayar_instan"), buttons: [closeButton])
        self.navigator.controller.present(actionSheet, animated: true, completion: nil)
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        
        notifyContentSizeChanged()
    }
    
    private func notifyContentSizeChanged() {
        let size = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        self.onLayoutComplete?(size)
    }
}

