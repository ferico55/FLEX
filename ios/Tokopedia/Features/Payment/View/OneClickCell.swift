//
//  OneClickCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class OneClickCell: UITableViewCell {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var rekeningNumberLabel: UILabel!
    @IBOutlet private var limitLabel: UILabel!
    @IBOutlet var editButton: UIButton!
    @IBOutlet private var deleteButton: UIButton!

    var delete: Observable<Void> {
        return deleteButton.rx.tap.asObservable()
    }
    var edit: Observable<Void> {
        return editButton.rx.tap.asObservable()
    }

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag() // because life cicle of every cell ends on prepare for reuse
    }

    func set(name: String, rekeningNumber: String, limit: String) {
        nameLabel.text = name
        rekeningNumberLabel.text = rekeningNumber
        var formatedLimit = "Rp 0"
        if let limitInt = Int(limit) {
            formatedLimit = NumberFormatter.idr().string(from: NSNumber(value: limitInt)) ?? "Rp 0"
        }
        limitLabel.text = formatedLimit
    }
}
