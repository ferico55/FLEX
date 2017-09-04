//
//  CreditCardCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class CreditCardCell: UITableViewCell {

    @IBOutlet private var typeLabel: UILabel!
    @IBOutlet private var numberLabel: UILabel!

    @IBOutlet private var expiryLabel: UILabel!

    @IBOutlet private var deleteButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!

    var delete: Observable<Void> {
        return deleteButton.rx.tap.asObservable()
    }
    
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setData(_ data: CreditCardData) {
        typeLabel.text = data.cardType
        numberLabel.text = data.number
        expiryLabel.text = "\(data.expiryMonth)/\(data.expiryYear)"
        if let imageURL = URL(string: data.imageURLString) {
            logoImageView.setImageWith(imageURL)
        }
    }
}
