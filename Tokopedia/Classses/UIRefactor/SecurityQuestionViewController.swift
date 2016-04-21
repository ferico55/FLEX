//
//  SecurityQuestionViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 4/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

class SecurityQuestionViewController : UIViewController {
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
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet var questionViewType2: UIView!
    @IBOutlet weak var requestOTPButton: UIButton!
    @IBOutlet weak var otpField: UITextField!
    @IBOutlet weak var saveOTPButton: UIButton!
    
    var _networkManager : TokopediaNetworkManager!
    var _securityQuestion : SecurityQuestion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Batal", style: .Plain, target: self, action: Selector("didTapBackButton"))
        
        _networkManager = TokopediaNetworkManager()
        _networkManager.isUsingHmac = true
        self .doRequestQuestionForm()
        
    }
    
    func doRequestQuestionForm() {
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
                self.view .addSubview(questionViewType1)
                questionTitle.text = securityQuestion.data.title
                answerField.placeholder = securityQuestion.data.example
            } else if(questionType1 == "0"){
                self.view .addSubview(questionViewType2)
                requestOTPButton .setTitle(securityQuestion.data.title, forState: .Normal)
            }
        }
    }
    
    func didTapBackButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func didTapSavePhoneButton(sender: AnyObject) {
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
                    
                },
                onFailure: nil)
    }
    
    @IBAction func didSubmitOTP(sender: AnyObject) {
        guard let text = otpField.text where !text.isEmpty else {
            let stickyAlert = StickyAlertView.init(errorMessages: ["Kode OTP tidak boleh kosong"], delegate: self)
            stickyAlert.show()
            return
        }
        
        self.submitSecurityAnswer(otpField.text!)
    }
    
    func switchToOTPView() {
        self.view.removeAllSubviews()
        self .doRequestQuestionForm()
    }

}