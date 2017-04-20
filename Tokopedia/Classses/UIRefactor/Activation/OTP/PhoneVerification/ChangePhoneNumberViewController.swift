//
//  ChangePhoneNumberViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import MMNumberKeyboard

@objc(ChangePhoneNumberViewController)
class ChangePhoneNumberViewController: UIViewController, MMNumberKeyboardDelegate {
    
    fileprivate let phoneNumber : String
    fileprivate let onPhoneNumberChanged : ((String) -> Void)
    
    @IBOutlet fileprivate var phoneNumberTextField: UITextField!
    @IBOutlet fileprivate var changePhoneNumberButton: UIButton!
    
    init(phoneNumber: String, onPhoneNumberChanged: @escaping ((String) -> Void)) {
        self.phoneNumber = phoneNumber
        self.onPhoneNumberChanged = onPhoneNumberChanged
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ubah Nomor Ponsel"
        AnalyticsManager.trackScreenName("Change Phone Number Page")
        
        self.phoneNumberTextField.text = self.phoneNumber
        
        let keyboard = MMNumberKeyboard(frame: CGRect.zero)
        keyboard.allowsDecimalPoint = false
        keyboard.delegate = self
        
        phoneNumberTextField.inputView = keyboard

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapChangePhoneNumber(_ sender: Any) {
        if self.phoneNumberTextField.text?.characters.count == 0 {
            StickyAlertView.showErrorMessage(["Harap masukkan nomor ponsel Anda"])
        } else {
            self.onPhoneNumberChanged(self.phoneNumberTextField.text!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: MMNumberKeyboard Delegate
    func numberKeyboardShouldReturn(_ numberKeyboard: MMNumberKeyboard!) -> Bool {
        return true
    }
}
