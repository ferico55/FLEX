//
//  TokoCashMoveToSaldoFailedViewConstroller.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashMoveToSaldoFailedViewConstroller: UIViewController {
   
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    // view model
    var viewModel: TokoCashMoveToSaldoFailedViewModel!
    
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
        let input = TokoCashMoveToSaldoFailedViewModel.Input(retryTrigger: retryButton.rx.tap.asDriver(),
                                                             homeTrigger: homeButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.retry
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.home
            .drive()
            .disposed(by: rx_disposeBag)
    }
}
