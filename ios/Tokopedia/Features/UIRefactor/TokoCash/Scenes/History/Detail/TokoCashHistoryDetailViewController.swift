//
//  TokoCashHistoryDetailViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TokoCashHistoryDetailViewController: UIViewController {
    
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descLabel: UILabel!
    @IBOutlet weak private var nominalLabel: UILabel!
    @IBOutlet weak private var notesLabel: UILabel!
    @IBOutlet weak private var transactionLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var helpButton: UIButton!
    @IBOutlet weak private var moveToSaldoButton: UIButton!
    
    // view model
    public var viewModel: TokoCashHistoryDetailViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detail Transaksi"
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashHistoryDetailViewModel.Input(trigger: viewWillAppear,
                                                         helpTrigger: helpButton.rx.tap.asDriver(),
                                                         moveToTrigger: moveToSaldoButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.icon.drive(onNext: { [unowned self] icon in
            self.iconImageView.setImageWith(URL(string: icon))
        }).addDisposableTo(rx_disposeBag)
        
        output.title
            .drive(titleLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.desc
            .drive(descLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.nominal
            .drive(nominalLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.nominalColor.drive(onNext: { color in
            self.nominalLabel.textColor = color
        }).addDisposableTo(rx_disposeBag)
        
        output.notes
            .drive(notesLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.message
            .drive(messageLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.transaction
            .drive(transactionLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.showMoveToSaldoButton
            .drive(moveToSaldoButton.rx.isHidden)
            .disposed(by: rx_disposeBag)
        
        output.helpButtonBorderColor
            .drive(onNext: { color in self.helpButton.layer.borderColor = color })
            .disposed(by: rx_disposeBag)
        
        output.helpButtonBackgroundColor
            .drive(onNext: { color in self.helpButton.backgroundColor = color })
            .disposed(by: rx_disposeBag)
        
        output.helpButtonTitleColor
            .drive(onNext: { color in self.helpButton.setTitleColor(color, for: .normal)})
            .disposed(by: rx_disposeBag)
        
        output.help
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.moveToSaldo
            .drive()
            .disposed(by: rx_disposeBag)
    }
}

