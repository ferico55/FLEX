//
//  ConfirmationRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ConfirmationRequest: NSObject {
    class func fetchEditForm(_ paymentID:String, onSuccess: @escaping ((PaymentConfirmationForm) -> Void), onFailure:@escaping (()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String : String] = [
            "payment_id":paymentID
        ]
        
        networkManager.request(withBaseUrl: NSString.v4Url(),
                                      path: "/v4/tx-order/get_edit_payment_toppay_form.pl",
                                      method: .POST,
                                      parameter: param,
                                      mapping: V4Response<AnyObject>.mapping(withData: PaymentConfirmation.mapping()) as RKObjectMapping,
                                      onSuccess: { (mappingResult, operation) in
                                        
                                        let result : Dictionary = mappingResult.dictionary() as Dictionary
                                        let response : V4Response = result[""] as! V4Response<PaymentConfirmation>
                                        let data = response.data as PaymentConfirmation
                                        
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
    
    class func fetchEdit(_ form:PaymentConfirmationForm, onSuccess: @escaping (() -> Void), onFailure:@escaping (()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String : String] = [
            "payment_id"            : form.payment_id,
            "sysbank_id"            : form.system_bank_id,
            "bank_account_name"     : form.user_acc_name,
            "bank_account_number"   : form.user_acc_no,
            "comments"              : form.comment
        ]
        
        networkManager.request(withBaseUrl: NSString.v4Url(),
                                          path: "/v4/action/tx-order/edit_payment_toppay.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: V4Response<AnyObject>.mapping(withData: GeneralActionResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response = result[""] as! V4Response<GeneralActionResult>
                                            let data = response.data as GeneralActionResult
                                            
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
