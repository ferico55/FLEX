//
//  PulsaNavigator.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import ContactsUI
import AddressBookUI

class PulsaNavigator: NSObject, CNContactPickerDelegate, ABPeoplePickerNavigationControllerDelegate {
    var controller: UIViewController!
    var loginDelegate: LoginViewDelegate?
    var pulsaView: PulsaView!
    
    override init() {
        super.init()
    }
    
    func navigateToAddressBook() {
        UINavigationBar.appearance().translucent = false
        if #available(iOS 9.0, *) {
            let contactPicker = CNContactPickerViewController()
            
            contactPicker.delegate = self
            contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            
            self.controller.presentViewController(contactPicker, animated: true, completion: nil)

        } else {
            // Fallback on earlier versions
            let contactPicker = ABPeoplePickerNavigationController()
            contactPicker.peoplePickerDelegate = self

            self.controller.presentViewController(contactPicker, animated: true, completion: nil)
        }
        
    }
    
    func navigateToPulsaProduct(products: [PulsaProduct], selectedOperator: PulsaOperator) {
        let controller = PulsaProductViewController()
        
        controller.products = products.sort({
            $0.attributes.weight < $1.attributes.weight
        })
        
        controller.didSelectProduct = { [unowned self] product in
            self.pulsaView.selectedProduct = product
            self.pulsaView.hideErrors()
            self.pulsaView.productButton.setTitle(product.attributes.desc, forState: .Normal)
        }
        controller.selectedOperator = selectedOperator
        
        controller.hidesBottomBarWhenPushed = true
        self.controller.navigationController!.pushViewController(controller, animated: true)
    }
    
    func navigateToPulsaOperator(operators: [PulsaOperator]) {
        let controller = PulsaOperatorViewController()
        
        
        controller.didTapOperator = { [unowned self] (selectedOperator) in
            self.pulsaView.buildViewByOperator(selectedOperator)
        }
        
        controller.operators = operators.sort({
            $0.attributes.weight < $1.attributes.weight
        })
        
        controller.hidesBottomBarWhenPushed = true
        self.controller.navigationController!.pushViewController(controller, animated: true)
    }
    
    func navigateToLoginIfRequired() {
        let navigation = UINavigationController()
        navigation.navigationBar.backgroundColor = UIColor(red: (18.0/255.0), green: (199.0/255.0), blue: (0/255.0), alpha: 1)
        navigation.navigationBar.translucent = false
        navigation.navigationBar.tintColor = UIColor.whiteColor()
        
        let controller = LoginViewController()
        controller.isPresentedViewController = true
        controller.redirectViewController = self.controller
        controller.delegate = self.loginDelegate
        
        navigation.viewControllers = [controller]
        
        self.controller.navigationController!.presentViewController(navigation, animated: true, completion: nil)
    }
    
    func navigateToSuccess(url: NSURL) {
        let controller = WebViewController()
        controller.strURL = url.absoluteString
        controller.shouldAuthorizeRequest = true
        
        self.controller.navigationController!.pushViewController(controller, animated: true)
    }
    
    func navigateToWebTicker(url: NSURL) {
        let controller = WebViewController()
        controller.strURL = url.absoluteString
        controller.strTitle = ""
        controller.onTapLinkWithUrl = {[weak self] (url) in
            if url.absoluteString == "https://www.tokopedia.com/" {
                self!.controller.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        self.controller.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func didSelectContact(contact: String) {
        var phoneNumber = contact
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
        phoneNumber = self.replaceAreaNumber(phoneNumber)
        
        self.pulsaView.numberField.text = phoneNumber
        self.pulsaView.checkInputtedNumber()
    }
    
    private func showInvalidNumberError() {
        StickyAlertView.showErrorMessage(["Nomor yang Anda pilih tidak valid."])
    }
    
    private func replaceAreaNumber(phoneNumber: String) -> String {
        var phone = ""
        
        if phoneNumber != "" {
            phone = phoneNumber.stringByReplacingOccurrencesOfString("62", withString: "0", options: .LiteralSearch, range: phoneNumber.startIndex ..< phoneNumber.startIndex.advancedBy(2))
        }
        
        return phone
    }
    
    
    //MARK : CNContactPickerdelegate
    @available(iOS 9.0, *)
    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
        AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Select Contact on Phonebook")
        if contactProperty.key == CNContactPhoneNumbersKey {
            guard let phoneNumber = contactProperty.value else { return }
            
            let phone = phoneNumber as! CNPhoneNumber
            self.didSelectContact(phone.stringValue)
        } else {
            showInvalidNumberError()
        }
    }

    //MARK : ABPeoplePickerNavigationControllerDelegate
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        let phones: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Select Contact on Phonebook")
        if ABMultiValueGetCount(phones) > 0 {
            let index = Int(identifier) as CFIndex
            let phoneNumber = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as! String
            
            self.didSelectContact(phoneNumber)
        } else {
            showInvalidNumberError()
        }
    }
}
