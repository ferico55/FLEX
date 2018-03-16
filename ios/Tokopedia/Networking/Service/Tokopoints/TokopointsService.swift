//
//  TokopointsService.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya
import RxSwift
import UIKit

internal class TokopointsService: NSObject {
    internal class func getDrawerData(onSuccess: @escaping ((DrawerData) -> Void), onFailure: @escaping ((Swift.Error) -> Void)) {
        
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
    
    internal class func getDrawerData() -> Observable<DrawerData?> {
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
    
    internal class func getCoupons(serviceType: PromoServiceType, productId: String?, categoryId: String?, page: Int64, onSuccess: @escaping ((GetCouponResponse) -> Void), onFailure: @escaping ((Swift.Error) -> Void)) {
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
    
    internal class func geocode(address: String?, latitudeLongitude: String?, onSuccess: @escaping ((GeocodeResponse) -> Void), onFailure: @escaping ((Swift.Error) -> Void)) {
        let _ = NetworkProvider<TokopointsTarget>()
            .request(.geocode(address: address, latitudeLongitude: latitudeLongitude))
            .mapJSON()
            .mapTo(object: GeocodeResponse.self)
            .subscribe(onNext: { (response) in
                onSuccess(response)
            }, onError: { (error) in
                let newError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : (error as? MoyaError)?.userFriendlyErrorMessage() ?? error.localizedDescription])
                onFailure(newError)
            })
    }
}
