//
//  ChooseVariantManager.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 07/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import React
import SwiftyJSON

@objc(VariantManager)
internal class VariantManager: NSObject {
    
    internal var bridge: RCTBridge?
    
    internal static var product: ProductUnbox?
    
    internal static var completionSelectedVariant: ((ProductUnbox) -> Void)?
    
    @objc internal func chooseVariant(_ reactTag: NSNumber, productSelected: [String : AnyObject]) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            guard let product = self.productVariant(productSelected) else { return }
            
            VariantManager.completionSelectedVariant?(product)
            
            DispatchQueue.main.async(execute: {
                if let view = self.bridge?.uiManager.view(forReactTag: reactTag) {
                    let presentedViewController: UIViewController! = view.reactViewController()
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc internal func buyVariant(_ reactTag: NSNumber, productSelected: [String : AnyObject]) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            guard let product = self.productVariant(productSelected) else { return }
            
            DispatchQueue.main.async(execute: {
                if let view = self.bridge?.uiManager.view(forReactTag: reactTag) {
                    let presentedViewController: UIViewController! = view.reactViewController()
                    
                    AnalyticsManager.trackEventName("clickBuy", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Buy")
                    
                    let userAuthManager = UserAuthentificationManager()
                    if !userAuthManager.isLogin {
                        AuthenticationService.shared.ensureLoggedInFromViewController(presentedViewController) {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: product.id)
                        }
                        return
                    }
                    
                    let vc = TransactionATCViewController()
                    if product.preorderDetail.isPreorder {
                        let detailProduct = DetailProductResult()
                        let preorderDetail = PreorderDetail()
                        preorderDetail.preorder_status = product.preorderDetail.isPreorder
                        preorderDetail.preorder_process_time = Int(product.preorderDetail.preorderTime)!
                        preorderDetail.preorder_process_time_type_string = product.preorderDetail.preorderTimeType
                        detailProduct.preorder = preorderDetail
                        vc.data = ["product": detailProduct]
                    }
                    vc.productPrice = product.info.price
                    vc.productID = product.id
                    
                    if let selectedProduct = product.variantProduct?.productVariantSelected {
                        let variantValue = selectedProduct.map { $0.variantValue }.joined(separator: ", ")
                        vc.notesToSeller = variantValue
                        AnalyticsManager.trackEventName("addToCart", category: "product detail page", action: "click - buy on variants page", label: "{\(variantValue)}")
                    }
                    
                    presentedViewController.navigationController?.pushViewController(vc, animated: true)
                    
                }
            })
        }
    }
    
    private func productVariant(_ productSelected: [String : AnyObject]) -> ProductUnbox? {
        let productJSON = JSON(productSelected)
        
        guard var product = VariantManager.product else { return nil }
    
        product.id = productJSON["productID"].stringValue
        product.name = productJSON["productName"].stringValue
        product.info.price = productJSON["productPrice"].stringValue
        product.isWishlisted = productJSON["productIsWishlist"].boolValue
        product.url = productJSON["productURL"].stringValue
        
        let isBuyable = productJSON["productIsBuyable"].boolValue
        
        if isBuyable, let productSelected = productJSON["productVariantSelected"].array {
            product.variantProduct?.productVariantSelected = productSelected.map { ProductVariantSelected(json: $0) }
            
            if product.info.status != .active {
                product.info.status = .active
            }
        }
        
        if let productCampaign = productJSON["productCampaign"].dictionaryObject {
            let campaign = ShopProductCampaign(formatted: JSON(productCampaign))
            product.info.price = campaign.discountedPriceFormat
            product.campaign = campaign
        } else {
            product.campaign = nil
        }
        
        if !product.images.isEmpty && !product.fullImages.isEmpty {
            product.images[0].normalURL = productJSON["productImage"].stringValue
            product.fullImages[0].normalURL = productJSON["productImage"].stringValue
        }
        
        return product
    }
}
