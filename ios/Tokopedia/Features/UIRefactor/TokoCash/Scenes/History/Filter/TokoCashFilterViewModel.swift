//
//  TokoCashFilterViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 20/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final class TokoCashFilterViewModel {
    let header: TokoCashHistoryHeader
    let title: String
    let selected: Bool
    var color: UIColor = .white
    
    init(with header: TokoCashHistoryHeader) {
        self.header = header
        self.title = header.name ?? ""
        self.selected = header.selected ?? false
        
        if (header.type == "paid") {
            self.color = UIColor(red: 66.0/255.0, green: 181.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        }else if (header.type == "topup") {
            self.color = UIColor(red: 237.0/255.0, green: 107.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        }else if (header.type == "received") {
            self.color = UIColor(red: 41.0/255.0, green: 187.0/255.0, blue: 209.0/255.0, alpha: 1.0)
        }else if (header.type == "refund") {
            self.color = UIColor(red: 162.0/255.0, green: 207.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        }else {
            self.color = .tpGreen()
        }
    }
}
