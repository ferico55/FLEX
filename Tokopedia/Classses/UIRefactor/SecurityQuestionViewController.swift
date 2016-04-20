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
    var questionType1 : String!
    var questionType2 : String!
    var userID : String!
    var deviceID : String!
    
    @IBOutlet var questionViewType1: UIView!
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var answerField: UITextField!
    
    var _networkManager : TokopediaNetworkManager!
    var _securityQuestion : SecurityQuestion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Batal", style: .Plain, target: self, action: Selector("didTapBackButton"))
        
        _networkManager = TokopediaNetworkManager()
        _networkManager.isUsingHmac = true

        _networkManager .
            requestWithBaseUrl(NSString.v4Url(),
                path: "/v4/interrupt/get_question_form.pl",
                method: .GET,
                parameter: ["user_check_security_1" : questionType1, "user_check_security_2" : questionType2, "user_id" : userID, "device_id" : deviceID],
                mapping: SecurityQuestion.mapping(),
                onSuccess: { (mappingResult, operation) -> Void in
                    let result = mappingResult.dictionary()[""] as! SecurityQuestion
                    self.didReceiveSecurityResult(result)
                },
                onFailure: { (errors) -> Void in
                    
            });
    }
    
    func didReceiveSecurityResult(securityQuestion : SecurityQuestion) {
        _securityQuestion = securityQuestion
        
        if(securityQuestion.data.question == "1") {
            self.view .addSubview(questionViewType1)
            questionTitle.text = securityQuestion.data.title
            answerField.placeholder = securityQuestion.data.example
        } else {
            
        }
    }
    
    func didTapBackButton() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func didTapSavePhoneButton(sender: AnyObject) {
        let button = sender as! UIButton;
        
    }
    
}