//
//  SecurityQuestionViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 4/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

@objc(SecurityQuestionViewController)
class SecurityQuestionViewController : UIViewController, UITextFieldDelegate {
    /*
     questionType1 = "1" => Phone Number Question
     questionType1 = "2" => Account Number Question
     
     questionType2 = "1" => OTP to email
     questionType2 = "2" => OTP to phone
     */
    var questionType1 : String!
    var questionType2 : String!
    var userID : String!
    var deviceID : String!
    var successAnswerCallback: ((SecurityAnswer) -> Void)!
    
    @IBOutlet var questionViewType1: UIView!
    @IBOutlet var questionTitle: UILabel!
    @IBOutlet var answerField: UITextField!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var questionViewType2: UIView!
    @IBOutlet var requestOTPButton: UIButton!
    @IBOutlet var otpField: UITextField!
    @IBOutlet var otpInfoLabel: UILabel!
    
    var _networkManager : TokopediaNetworkManager!
    var _securityQuestion : SecurityQuestion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Batal", style: .Plain, target: self, action: Selector("didTapBackButton:"))
        
        _networkManager = TokopediaNetworkManager()
        _networkManager.isUsingHmac = true
        self .requestQuestionForm()
        
        self.setLabelSpacing(infoLabel)
        self.setLabelSpacing(otpInfoLabel)
        answerField.delegate = self
        otpField.delegate = self
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        self.view .addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didKeyboardShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didKeyboardHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func dismissKeyboard() {
        answerField.resignFirstResponder()
        otpField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        answerField.resignFirstResponder()
        otpField.resignFirstResponder()
        
        return true
    }
    
    func didKeyboardShow(notification : NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            var frame = self.questionViewType1.frame
            frame.origin.y -= keyboardFrame.size.height - 20
            self.questionViewType1.frame = frame
            
            var frame2 = self.questionViewType1.frame
            frame2.origin.y -= keyboardFrame.size.height - 20
            self.questionViewType1.frame = frame2
        })
    }
    
    func didKeyboardHide(notification : NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            var frame = self.questionViewType1.frame
            frame.origin.y += keyboardFrame.size.height - 20
            self.questionViewType1.frame = frame
            
            var frame2 = self.questionViewType2.frame
            frame2.origin.y += keyboardFrame.size.height - 20
            self.questionViewType2.frame = frame2
        })
    }
    
    func setLabelSpacing (label : UILabel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attrString = NSMutableAttributedString(string: label.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    }
    
    func requestQuestionForm() {
        _networkManager .
            requestWithBaseUrl(NSString.v4Url(),
                               path: "/v4/interrupt/get_question_form.pl",
                               method: .GET,
                               parameter: ["user_check_security_1" : questionType1, "user_check_security_2" : questionType2, "user_id" : userID, "device_id" : deviceID],
                               mapping: SecurityQuestion.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let result = mappingResult.dictionary()[""] as! SecurityQuestion
                                self.didReceiveSecurityForm(result)
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func didReceiveSecurityForm(securityQuestion : SecurityQuestion) {
        _securityQuestion = securityQuestion
        
        if((_securityQuestion.message_error) != nil) {
            let stickyAlert = StickyAlertView.init(errorMessages: _securityQuestion.message_error, delegate: self)
            stickyAlert.show()
        } else {
            if(questionType2 == "0") {
                //set phone number view
                self.view .addSubview(questionViewType1)
                questionViewType1.HVD_fillInSuperViewWithInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                questionTitle.text = securityQuestion.data.title
                self.setLabelSpacing(questionTitle)
                answerField.placeholder = securityQuestion.data.example
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Konfirmasi", style: .Plain, target: self, action: Selector("didTapSavePhoneButton"))
                
            } else if(questionType1 == "0"){
                //set OTP view
                let buttonTitle = questionType2 == "1" ? "Kirim OTP ke HP" : "Kirim OTP ke Email"
                self.view .addSubview(questionViewType2)
                questionViewType2.HVD_fillInSuperViewWithInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                requestOTPButton .setTitle(buttonTitle, forState: .Normal)
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Konfirmasi", style: .Plain, target: self, action: Selector("didSubmitOTP"))
            }
        }
    }
    
    @IBAction func didTapBackButton(sender: AnyObject) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapSavePhoneButton() {
        guard let text = answerField.text where !text.isEmpty else {
            let stickyAlert = StickyAlertView.init(errorMessages: ["Jawaban tidak boleh kosong"], delegate: self)
            stickyAlert.show()
            return
        }
        
        self.submitSecurityAnswer(answerField.text!)
    }
    
    func submitSecurityAnswer(answer : String) {
        _networkManager.requestWithBaseUrl(NSString.v4Url(),
                                           path: "/v4/action/interrupt/answer_question.pl",
                                           method: .GET,
                                           parameter: ["question" : _securityQuestion.data.question, "answer" : answer, "user_check_security_1" : questionType1, "user_check_security_2" : questionType2, "user_id" : userID],
                                           mapping: SecurityAnswer .mapping(),
                                           onSuccess: { (mappingResult, operation) -> Void in
                                            let answer = mappingResult.dictionary()[""] as! SecurityAnswer
                                            self.didReceiveAnswerRespond(answer)
            },
                                           onFailure: nil)
    }
    
    func didReceiveAnswerRespond(answer : SecurityAnswer) {
        if((answer.message_error) != nil) {
            let stickyAlert = StickyAlertView.init(errorMessages: answer.message_error, delegate: self)
            stickyAlert.show()
        } else if((answer.data.error) == "1") {
            let stickyAlert = StickyAlertView.init(errorMessages: ["Jawaban yang Anda masukkan tidak sesuai."], delegate: self)
            stickyAlert.show()
        }
        
        if(answer.data.change_to_otp == "1") {
            questionType1 = answer.data.user_check_security_1
            questionType2 = answer.data.user_check_security_2
            self.switchToOTPView()
        }
        
        if(answer.data.allow_login == "1") {
            self.successAnswerCallback(answer)
            self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func didTapRequestOTP(sender: AnyObject) {
        _networkManager .
            requestWithBaseUrl(NSString.v4Url(),
                               path: "/v4/action/interrupt/request_otp.pl",
                               method: .GET,
                               parameter: ["user_id" : userID, "user_check_question_2" : questionType2],
                               mapping: SecurityRequestOTP .mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let otp = mappingResult.dictionary()[""] as! SecurityRequestOTP
                                if(otp.data.is_success == "1") {
                                    let stickyAlert = StickyAlertView.init(successMessages: ["Kode OTP sukses terkirim."], delegate: self)
                                    stickyAlert.show()
                                }
                },
                               onFailure: nil)
    }
    
    func didSubmitOTP() {
        guard let text = otpField.text where !text.isEmpty else {
            let stickyAlert = StickyAlertView.init(errorMessages: ["Kode OTP tidak boleh kosong"], delegate: self)
            stickyAlert.show()
            return
        }
        
        self.submitSecurityAnswer(otpField.text!)
    }
    
    func switchToOTPView() {
        for subview in self.view.subviews {
            if (subview.viewWithTag(11) != nil) {
                subview.removeFromSuperview()
            }
        }
        self .requestQuestionForm()
    }
    
}