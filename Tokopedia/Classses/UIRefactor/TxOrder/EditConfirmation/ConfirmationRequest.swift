//
//  ConfirmationRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ConfirmationRequest: NSObject {
    class func fetchEditForm(paymentID:String, onSuccess: ((PaymentConfirmationForm) -> Void), onFailure:(()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String : String] = [
            "payment_id":paymentID
        ]
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/tx-order/get_edit_payment_toppay_form.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(PaymentConfirmation.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
                                            let data = response.data as! PaymentConfirmation
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(data.form)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchEdit(form:PaymentConfirmationForm, onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String : String] = [
            "payment_id"            : form.payment_id,
            "sysbank_id"            : form.system_bank_id,
            "bank_account_name"     : form.user_acc_name,
            "bank_account_number"   : form.user_acc_no,
            "comments"              : form.comment
        ]
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/tx-order/edit_payment_toppay.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(GeneralActionResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
                                            let data = response.data as! GeneralActionResult
                                            
                                            if data.is_success == "1" {
                                                
                                                if response.message_status.count == 0  {
                                                    response.message_status = ["sukses mengubah konfirmasi pembayaran"]
                                                }
                                                
                                                StickyAlertView.showSuccessMessage(response.message_status)
                                                onSuccess()
                                                
                                            } else {
                                                
                                                if response.message_error.count == 0  {
                                                    response.message_error = ["gagal mengubah konfirmasi pembayaran"]
                                                }

                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            }
        }) { (error) in
            onFailure()
        }
    }
}
