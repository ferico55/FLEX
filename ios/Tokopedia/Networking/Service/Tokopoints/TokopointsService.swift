//
//  TokopointsService.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class TokopointsService: NSObject {
    class func getDrawerData(onSuccess: @escaping ((DrawerData) -> Void), onFailure: @escaping ((Swift.Error) -> Void)) {
        
        let _ = NetworkProvider<TokopointsTarget>()
            .request(.getDrawerData)
            .mapJSON()
            .mapTo(object: DrawerData.self)
            .subscribe(onNext: { (response) in
                onSuccess(response)
            }, onError: { (error) in
                onFailure(error)
            })
    }
    
    class func getDrawerData() -> Observable<DrawerData?> {
        return NetworkProvider<TokopointsTarget>()
            .request(.getDrawerData)
            .mapJSON()
            .mapTo(object: DrawerData.self)
            .map({ (drawerData) -> DrawerData? in
                return drawerData
            })
            .catchError({ (error) -> Observable<DrawerData?> in
                return .just(nil)
            })
    }
    
    class func getCoupons(serviceType: PromoServiceType, productId: String?, categoryId: String?, page: Int64, onSuccess: @escaping ((GetCouponResponse) -> Void), onFailure: @escaping ((Swift.Error) -> Void)) {
        let _ = NetworkProvider<TokopointsTarget>()
            .request(.getCoupons(serviceType: serviceType, productId: productId, categoryId: categoryId, page: page))
            .mapJSON()
            .mapTo(object: GetCouponResponse.self)
            .subscribe(onNext: { (response) in
                onSuccess(response)
            }, onError: { (error) in
                onFailure(error)
            })
    }
}
