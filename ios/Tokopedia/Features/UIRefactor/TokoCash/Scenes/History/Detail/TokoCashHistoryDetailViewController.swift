//
//  TokoCashHistoryDetailViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TokoCashHistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var nominalLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var moveToSaldoButton: UIButton!
    
    // view model
    var viewModel: TokoCashHistoryDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
