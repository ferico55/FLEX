//
//  PulsaNavigator.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import AddressBookUI
import ContactsUI
import Foundation

internal class PulsaNavigator: NSObject, CNContactPickerDelegate, ABPeoplePickerNavigationControllerDelegate {
    internal var controller: UIViewController {
        guard let c = UIApplication.topViewController() else { fatalError("no top vc when accesed") }
        return c
    }
    internal var pulsaView: PulsaView!
    
    internal override init() {
        super.init()
    }
    
    internal func navigateToAddressBook() {
        if #available(iOS 9.0, *) {
            let contactPicker = CNContactPickerViewController()
            
            contactPicker.delegate = self
            contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            self.controller.present(contactPicker, animated: true)
            
        } else {
            // Fallback on earlier versions
            let contactPicker = ABPeoplePickerNavigationController()
            contactPicker.peoplePickerDelegate = self
            contactPicker.displayedProperties = [NSNumber(value: kABPersonPhoneProperty as Int32)]
            self.controller.present(contactPicker, animated: true)
            
        }
        
    }
    
    func navigateToPulsaProduct(_ products: [PulsaProduct], selectedOperator: PulsaOperator) {
        guard let navigationController = self.controller.navigationController else { return }
        let controller = PulsaProductViewController()
        
        controller.products = products.sorted(by: {
            $0.attributes.weight < $1.attributes.weight
        })
        
        controller.didSelectProduct = { [unowned self] product in
            self.pulsaView.selectedProduct = product
            self.pulsaView.hideErrors()
            self.pulsaView.productButton.setTitle(product.attributes.desc, for: .normal)
        }
        controller.selectedOperator = selectedOperator
        
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }
    
    func navigateToPulsaOperator(_ operators: [PulsaOperator]) {
        guard let navigationController = self.controller.navigationController else { return }
        let controller = PulsaOperatorViewController()
        
        controller.didTapOperator = { [unowned self] selectedOperator in
            self.pulsaView.buildViewByOperator(selectedOperator)
        }
        
        controller.operators = operators.sorted(by: {
            $0.attributes.weight < $1.attributes.weight
        })
        
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }
    
    func navigateToLoginIfRequired() {
        AuthenticationService.shared.ensureLoggedInFromViewController(self.controller, onSuccess: nil)
    }
    
    func navigateToSuccess(_ url: URL) {
        guard let navigationController = self.controller.navigationController else { return }
        let controller = WebViewController()
        controller.hidesBottomBarWhenPushed = true
        
        controller.strURL = url.absoluteString
        controller.shouldAuthorizeRequest = true
        
        navigationController.pushViewController(controller, animated: true)
    }
    
    func navigateToWKWebView(_ url: URL) {
        guard let navigationController = self.controller.navigationController else { return }
        let controller = WKWebViewController(urlString: url.absoluteString, shouldAuthorizeRequest: true)
        controller.didReceiveNavigationAction = { [weak self] action in
            let url = action.request.url
            
            if action.navigationType == .backForward && url?.host == "pay.tokopedia.com" {
                self?.controller.navigationController?.popViewController(animated: true)
            }
        }
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }
    
    func navigateToCart(_ category: String) {
        guard let navigationController = self.controller.navigationController else { return }
        let controller = DigitalCartViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.categoryId = category
        
        navigationController.pushViewController(controller, animated: true)
    }
    
    func navigateToWebTicker(_ url: URL) {
        TPRoutes.routeURL(url)
    }
    
    internal func navigateToDigitalCategories() {
        let controller = DigitalCategoryListViewController()
        controller.title = "Pembayaran & Top Up"
        controller.hidesBottomBarWhenPushed = true
        
        self.controller.navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func didSelectContact(_ contact: String) {
        var phoneNumber = contact
        phoneNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
        phoneNumber = self.replaceAreaNumber(phoneNumber)
        
        self.pulsaView.numberField.text = phoneNumber
        self.pulsaView.checkInputtedNumber()
    }
    
    fileprivate func showInvalidNumberError() {
        StickyAlertView.showErrorMessage(["Nomor yang Anda pilih tidak valid."])
    }
    
    fileprivate func replaceAreaNumber(_ phoneNumber: String) -> String {
        var phone = ""
        
        if phoneNumber.characters.count > 2 {
            phone = phoneNumber.replacingOccurrences(of: "62", with: "0", options: .literal, range: phoneNumber.startIndex ..< phoneNumber.characters.index(phoneNumber.startIndex, offsetBy: 2))
        }
        
        return phone
    }
    
    // MARK: CNContactPickerdelegate
    @available(iOS 9.0, *)
    internal func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Select Contact on Phonebook")
        if contactProperty.key == CNContactPhoneNumbersKey {
            guard let phoneNumber = contactProperty.value else { return }
            
            let phone = phoneNumber as! CNPhoneNumber
            self.didSelectContact(phone.stringValue)
        } else {
            self.showInvalidNumberError()
        }
    }
    
    // MARK: ABPeoplePickerNavigationControllerDelegate
    internal func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        let phones: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Select Contact on Phonebook")
        if ABMultiValueGetCount(phones) > 0 {
            let index = Int(identifier) as CFIndex
            let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as! String
            
            self.didSelectContact(phoneNumber)
        } else {
            self.showInvalidNumberError()
        }
    }
}
