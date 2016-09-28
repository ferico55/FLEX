//
//  RequestCartShipment.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class CalculatePostObject : NSObject {
    var productID   : String = ""
    var quantity    : String = ""
    var insuranceID : String = ""
    var weight      : String = "1"
    var shopID      : String = ""
    var addressID   : String = ""
    var postalCode  : String = ""
    var districtID  : String = ""
}

class ShippingFormPostObject : NSObject {
    var change   : String = ""
    var addressID    : String = ""
    var shipmentID : String = ""
    var shipmentPackageID      : String = ""
    var shopID      : String = ""
    var userID   : String = ""
}

class CartEditAddressPostObject : NSObject {
    
    static let noAddress : String = "-1"
    
    var shopID          : String = ""
    var oldAddressID    : String = ""
    var oldShipmentID   : String = ""
    var oldShipmentPackageID : String = ""
    var shipmentID      : String = ""
    var shipmentPackageID : String = ""
    var addressID   : String = CartEditAddressPostObject.noAddress
    var addressName        : String = ""
    var addressStreet      : String = ""
    var provinceID  : String = ""
    var cityID      : String = ""
    var districtID  : String = ""
    var receiverName: String = ""
    var receiverPhone: String = ""
    var postalCode  : String = ""
}

class CartEditInsurancePostObject: NSObject {
    var addressID        : String = "-1"
    var productInsurance : String = "0"
    var shipmentID       : String = ""
    var shipmentPackageID: String = ""
    var shopID           : String = ""
    var userID           : String = ""
}

class RequestCartShipment: NSObject {
    
    class func fetchShipmentFormWithObject(postObject: ShippingFormPostObject,onSuccess: ((data:CartShipmentForm) -> Void), onFailure:(()->Void)) {
        
        let auth = UserAuthentificationManager()
        
        let param : [String : String] = [
            "change"            : "",
            "address_id"        : postObject.addressID,
            "shipment_id"       : postObject.shipmentID,
            "shipment_package_id" :postObject.shipmentPackageID,
            "shop_id"           : postObject.shopID,
            "user_id"           : auth.getUserId()
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/tx-cart/get_edit_address_shipping_form.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: CartEditShipmentResponse.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : CartEditShipmentResponse = result[""] as! CartEditShipmentResponse
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                if response.message_status.count > 0{
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(data: response.data.form)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchCalculatePriceWithObject(postObject: CalculatePostObject,onSuccess: ((data:TransactionCalculatePriceResult) -> Void), onFailure:(()->Void)) {
        
        let param : [String : String] = [
            "do"            : "calculate_address_shipping",
            "address_id"    : postObject.addressID,
            "district_id"   : postObject.districtID,
            "product_id"    : postObject.productID,
            "postal_code"   : postObject.postalCode,
            "qty"           : postObject.quantity,
            "shop_id"       : postObject.shopID,
            "weight"        : postObject.weight
            ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/tx-cart/calculate_cart.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: TransactionCalculatePrice.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : TransactionCalculatePrice = result[""] as! TransactionCalculatePrice
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                if response.message_status.count > 0{
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                
                                                let shipments : [ShippingInfoShipments] = response.data.shipment.filter{ $0.shipment_available == "1" }
                                                response.data.shipment = shipments
                                                shipments.forEach({ (shipment) in
                                                    if response.data.auto_resi .contains(shipment.shipment_id) && shipment.shipment_id == "3" {
                                                        shipment.auto_resi_image = response.data.rpx.indomaret_logo
                                                    } 
                                                    let packages : [ShippingInfoShipmentPackage] = shipment.shipment_package.filter{ $0.package_available == "1" }
                                                    shipment.shipment_package = packages
                                                })
                                                
                                                onSuccess(data: response.data)
                                            }
                                            
            }) { (error) in
                onFailure()
        }
    }
    
    class func fetchEditAddress(postObject: CartEditAddressPostObject,onSuccess: ((data:TransactionAction) -> Void), onFailure:(()->Void)) {
        
        let auth = UserAuthentificationManager()
        
        let param : [String : String] = [
            "address_id"            : postObject.addressID,
            "address_name"          : postObject.addressName,
            "address_street"        : postObject.addressStreet,
            "city_id"               : postObject.cityID,
            "district_id"           : postObject.districtID,
            "old_address_id"        : postObject.oldAddressID,
            "old_shipment_id"       : postObject.oldShipmentID,
            "old_shipment_package_id": postObject.oldShipmentPackageID,
            "postal_code"           : postObject.postalCode,
            "province_id"           : postObject.provinceID,
            "receiver_name"         : postObject.receiverName,
            "receiver_phone"        : postObject.receiverPhone,
            "shipment_id"           : postObject.shipmentID,
            "shipment_package_id"   : postObject.shipmentPackageID,
            "shop_id"               : postObject.shopID,
            "user_id"               : auth.getUserId()
            ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/tx-cart/edit_address.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: TransactionAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : TransactionAction = result[""] as! TransactionAction
                                            
                                            if response.data.is_success == 1 {
                                                if response.message_status.count > 0{
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(data: response)
                                            } else {
                                                if response.message_error.count > 0{
                                                    StickyAlertView.showErrorMessage(response.message_error)
                                                }
                                                onFailure()
                                            }
            }) { (error) in
                onFailure()
        }
        
    }
    
    class func fetchEditInsurance(postObject: CartEditInsurancePostObject,onSuccess: ((data:TransactionAction) -> Void), onFailure:(()->Void))  {
        let auth = UserAuthentificationManager()
        
        let param : [String : String] = [
            "address_id"            : postObject.addressID,
            "product_insurance"     : postObject.productInsurance,
            "shipment_id"           : postObject.shipmentID,
            "shipment_package_id"   : postObject.shipmentPackageID,
            "shop_id"               : postObject.shopID,
            "user_id"               : auth.getUserId()
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/tx-cart/edit_insurance.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: TransactionAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : TransactionAction = result[""] as! TransactionAction
                                            
                                            if response.data.is_success == 1 {
                                                if response.message_status.count > 0{
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(data: response)
                                            } else {
                                                if response.message_error.count > 0{
                                                    StickyAlertView.showErrorMessage(response.message_error)
                                                }
                                                onFailure()
                                            }
        }) { (error) in
            onFailure()
        }
    }

}
