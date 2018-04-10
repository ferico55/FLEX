//
//  TokoCashFilterViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 20/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

public final class TokoCashFilterViewModel {
    public let header: TokoCashHistoryHeader
    public let title: String
    public let selected: Bool
    public var color: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    public init(with header: TokoCashHistoryHeader) {
        self.header = header
        self.title = header.name ?? ""
        self.selected = header.selected ?? false

        if header.type == "paid" {
            self.color = #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
        } else if header.type == "topup" {
            self.color = #colorLiteral(red: 1, green: 0.4790000021, blue: 0.003000000026, alpha: 1)
        } else if header.type == "received" {
            self.color = #colorLiteral(red: 0.1609999985, green: 0.7329999804, blue: 0.8199999928, alpha: 1)
        } else if header.type == "refund" {
            self.color = #colorLiteral(red: 0.6349999905, green: 0.8119999766, blue: 0.3880000114, alpha: 1)
        } else {
            self.color = #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
        }
    }
}
