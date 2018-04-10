//
//  TokoCashMoveToSaldoStatusViewConstroller.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 30/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashMoveToSaldoSuccessViewController: UIViewController {
    
    @IBOutlet weak private var descLabel: UILabel!
    @IBOutlet weak private var homeButton: UIButton!
    
    // view model
    public var viewModel: TokoCashMoveToSaldoSuccessViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dana Telah Dipindahkan"
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
        let input = TokoCashMoveToSaldoSuccessViewModel.Input(trigger: viewWillAppear,
                                                              homeTrigger: homeButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.desc
            .drive(descLabel.rx.attributedText)
            .disposed(by: rx_disposeBag)
        
        output.home
            .drive()
            .disposed(by: rx_disposeBag)
    }
}
