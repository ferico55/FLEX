//
//  GeocodeResponse.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 09/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit

internal final class GeocodeResponse : NSObject {
    internal let fullAddress: String
    internal let shortAddress: String
    internal let latitude: Double
    internal let longitude: Double
    
    internal init(fullAddress: String, shortAddress: String, latitude: Double, longitude: Double) {
        self.fullAddress = fullAddress
        self.shortAddress = shortAddress
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension GeocodeResponse : JSONAbleType {
    internal static func fromJSON(_ source: [String: Any]) -> GeocodeResponse {
        let json = JSON(source)
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        var fullAddress = ""
        var shortAddress = ""
        
        var streetAddress = ""
        var streetNumber = ""
        
        if let data = json["data"].arrayValue.first {
            latitude = data["geometry"]["location"]["lat"].doubleValue
            longitude = data["geometry"]["location"]["lng"].doubleValue
            
            data["address_components"].arrayValue.forEach({ address in
                if !address["short_name"].stringValue.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty && address["types"].arrayValue.count > 0 {
                    let type = address["types"].arrayValue[0]
                    if type.stringValue == "premise" || type.stringValue == "point_of_interest" || type.stringValue == "street_address" || type.stringValue == "route" {
                        streetAddress = address["short_name"].stringValue + (streetAddress.count > 0 ? " " : "") + streetAddress
                    }
                    else if type.stringValue == "street_number" {
                        streetNumber = address["short_name"].stringValue + (streetNumber.count > 0 ? ", " : "") + streetNumber
                    }
                }
            })
            
            fullAddress = data["formatted_address"].stringValue
            shortAddress = streetAddress + (streetNumber.count > 0 ? " no. \(streetNumber)" : "")
        }
        
        return GeocodeResponse(fullAddress: fullAddress, shortAddress: shortAddress, latitude: latitude, longitude: longitude)
    }
}
