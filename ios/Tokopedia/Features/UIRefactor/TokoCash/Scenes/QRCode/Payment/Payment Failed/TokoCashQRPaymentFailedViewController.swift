//
//  TokoCashQRPaymentFailedViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class TokoCashQRPaymentFailedViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descLabel: UILabel!
    @IBOutlet weak private var retryButton: UIButton!
    
    // view model
    public var viewModel: TokoCashQRPaymentFailedViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transaksi Gagal"
        bindViewModel()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
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
        
        output.retry.drive().disposed(by: rx_disposeBag)
    }
}
