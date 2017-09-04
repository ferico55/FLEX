//
//  OneClickRegisterCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class OneClickRegisterCell: UITableViewCell {

    @IBOutlet var registerButton: UIButton!

    var register: Observable<Void>!

    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        register = registerButton?.rx.tap.asObservable()
    }
}
