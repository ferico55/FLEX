//
//  DistrictService.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 11/1/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya

class DistrictService: NSObject {

    func fetchDistricts(token: String, unixTime: NSInteger, query: String, page: NSInteger, onSuccess: @escaping (DistrictRecommendation) -> Void, onFailure: @escaping () -> Void) {
        NetworkProvider<KeroTarget>()
            .request(.getDistricts(token: token, unixTime: unixTime, query: query, page: page))
            .map(to: DistrictRecommendation.self)
            .subscribe(onNext: { districts in
                onSuccess(districts)
            }, onError: { _ in
                onFailure()
            })
            .disposed(by: rx_disposeBag)
    }
}
