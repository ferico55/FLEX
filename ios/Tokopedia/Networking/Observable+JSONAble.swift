//
//  Observable.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    
    typealias Dictionary = [String: AnyObject]
    
    /// Get given JSONified data, pass back objects
    func mapTo<B: JSONAbleType>(object classType: B.Type) -> Observable<B> {
        return self.map { json in
            guard let dict = json as? Dictionary else {
                throw NSError(domain: "", code: 9999, userInfo: nil)
            }
            
            return B.fromJSON(dict)
        }
    }
    
    /// Get given JSONified data, pass back objects as an array
    func mapTo<B: JSONAbleType>(arrayOf classType: B.Type) -> Observable<[B]> {
        return self.map { json in
            guard let array = json as? [AnyObject] else {
                throw NSError(domain: "", code: 9999, userInfo: nil)
            }
            
            guard let dicts = array as? [Dictionary] else {
                throw NSError(domain: "", code: 9999, userInfo: nil)
            }
            
            return dicts.map { B.fromJSON($0) }
        }
    }
    
}
