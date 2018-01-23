//
//  TokoCashNominalItemViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final class TokoCashNominalItemViewModel {
    let title: String
    
    init(with digitalProduct: DigitalProduct) {
        title = digitalProduct.name
    }
}
