//
//  CategoryDataForCategoryResultVC.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc(CategoryDataForCategoryResultVC)
class CategoryDataForCategoryResultVC: NSObject {
    let department1: String!
    let department2: String!
    let department3: String!
    let st: String = "product"
    let scIdentifier: String!
    
    init(pathComponent: [String]){
        self.department1 = pathComponent[0]
        self.department2 = pathComponent.count > 1 ? pathComponent[1] : ""
        self.department3 = pathComponent.count > 2 ? pathComponent[2] : ""
        self.scIdentifier = pathComponent.joined(separator: "_")
    }
    
    
    func mapToDictionary() -> [String : String] {
        return [
            "department_1" : department1!,
            "department_2" : department2!,
            "department_3" : department3!,
            "st" : st,
            "sc_identifier" : scIdentifier!,
            "type" : "search_product"
        ]
    }
}
