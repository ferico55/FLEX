//
//  TokoCashAccountTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class TokoCashAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var identifierLabel: UILabel!
    @IBOutlet weak private var authDateLabel: UILabel!
    @IBOutlet weak private var deleteButton: UIButton!

    public let account = PublishSubject<TokoCashAccount>()
    
    public func bind(_ viewModel: TokoCashAccountViewModel) {
        
        let input =  TokoCashAccountViewModel.Input(deleteButtonTrigger: deleteButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.identifier.drive(identifierLabel.rx.text).addDisposableTo(rx_disposeBag)
        output.authDate.drive(authDateLabel.rx.text).addDisposableTo(rx_disposeBag)
        output.deleteAccount.drive(account).addDisposableTo(rx_disposeBag)
    }
}
