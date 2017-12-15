//
//  ReplacementDestination.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ReplacementDestination: Unboxable {
    
    var phone: String
    var street: String
    var city: String
    var province: String
    var country: String
    var postal: String
    var name: String
    var district: String
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            phone: try unboxer.unbox(key:"receiver_phone"),
            street: try unboxer.unbox(key:"address_street"),
            city: try unboxer.unbox(key:"address_city"),
            province: try unboxer.unbox(key:"address_province"),
            country: try unboxer.unbox(key:"address_country"),
            postal: try unboxer.unbox(key:"address_postal"),
            name: try unboxer.unbox(key:"receiver_name"),
            district: try unboxer.unbox(key:"address_district")
        )
    }
    
    init(phone: String, street: String, city: String, province: String, country: String, postal: String, name: String, district: String) {
        self.phone = phone
        self.street = street
        self.city = city
        self.province = province
        self.country = country
        self.postal = postal
        self.name = name
        self.district = district
    }
}
