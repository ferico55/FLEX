//
//  TokoCashQRPaymentFailedViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TokoCashQRPaymentFailedViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    // view model
    var viewModel: TokoCashQRPaymentFailedViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashQRPaymentFailedViewModel.Input(trigger: viewWillAppear,
                                                           retryTrigger: retryButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.retry
            .drive()
            .disposed(by: rx_disposeBag)
    }
}
