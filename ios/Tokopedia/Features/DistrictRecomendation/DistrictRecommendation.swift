//
//  DistrictRecomendation.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 11/1/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class DistrictRecommendation: NSObject {
    var nextAvailable = false
    var districtList: [DistrictDetail]?

    init(nextAvailable: Bool, districtList: [DistrictDetail]) {
        self.nextAvailable = nextAvailable
        self.districtList = districtList
    }
}

extension DistrictRecommendation: Unboxable {
    convenience init(unboxer: Unboxer) throws {
        let nextAvailable = try unboxer.unbox(key: "next_available") as Bool
        let districtList = try unboxer.unbox(keyPath: "data") as [DistrictDetail]

        self.init(nextAvailable: nextAvailable, districtList: districtList)
    }
}

final class DistrictDetail: NSObject {
    var districtID: String
    var districtName: String
    var cityID: String
    var cityName: String
    var provinceID: String
    var provinceName: String
    var zipCodes: [String]

    init(districtID: String, districtName: String, cityID: String, cityName: String, provinceID: String, provinceName: String, zipCodes: [String]) {
        self.districtID = districtID
        self.districtName = districtName
        self.cityID = cityID
        self.cityName = cityName
        self.provinceID = provinceID
        self.provinceName = provinceName
        self.zipCodes = zipCodes
    }
    
    var districtLabel: String {
        return "\(provinceName) \(cityName) \(districtName)"
    }
}

extension DistrictDetail: Unboxable {
    convenience init(unboxer: Unboxer) throws {
        let districtID = try unboxer.unbox(key: "district_id") as String
        let districtName = try unboxer.unbox(keyPath: "district_name") as String
        let cityID = try unboxer.unbox(keyPath: "city_id") as String
        let cityName = try unboxer.unbox(keyPath: "city_name") as String
        let provinceID = try unboxer.unbox(keyPath: "province_id") as String
        let provinceName = try unboxer.unbox(keyPath: "province_name") as String
        let zipCodes = try unboxer.unbox(keyPath: "zip_code") as [String]

        self.init(districtID: districtID, districtName: districtName, cityID: cityID, cityName: cityName, provinceID: provinceID, provinceName: provinceName, zipCodes: zipCodes)
    }
}
