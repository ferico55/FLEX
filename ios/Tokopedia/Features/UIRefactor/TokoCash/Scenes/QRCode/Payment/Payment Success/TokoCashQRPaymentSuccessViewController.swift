//
//  TokoCashQRPaymentSuccessViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Lottie
import RxCocoa
import RxSwift
import UIKit

public class TokoCashQRPaymentSuccessViewController: UIViewController {
    
    @IBOutlet weak private var animationView: UIView!
    @IBOutlet weak private var checkmarkImageView: UIImageView!
    @IBOutlet weak private var descView: UIView!
    @IBOutlet weak private var merchantNameLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var datetimeLabel: UILabel!
    @IBOutlet weak private var transactionIdLabel: UILabel!
    @IBOutlet weak private var balanceLabel: UILabel!
    @IBOutlet weak private var backToHomeButton: UIButton!
    @IBOutlet weak private var helpButton: UIButton!
    
    private var isAnimation = false
    
    // view model
    public var viewModel: TokoCashQRPaymentSuccessViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transaksi Berhasil"
        bindViewModel()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isAnimation {
            configureCheckmarkAnimation()
            configureDescAnimation()
        }
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashQRPaymentSuccessViewModel.Input(trigger: viewWillAppear,
                                                            backToHomeTrigger: backToHomeButton.rx.tap.asDriver(),
                                                            helpTrigger: helpButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.merchantName
            .drive(merchantNameLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.amount
            .drive(amountLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.datetime
            .drive(datetimeLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.transactionId
            .drive(transactionIdLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.balance
            .drive(balanceLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.backToHome
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.help
            .drive()
            .disposed(by: rx_disposeBag)
    }
    
    private func configureCheckmarkAnimation() {
        let animation = LOTAnimationView(name: "Success-animation")
        animation.frame = CGRect(x: 0.0, y: 0.0, width: animationView.frame.width, height: animationView.frame.height)
        animation.backgroundColor = .clear
        
        animationView.addSubview(animation)
        
        animation.translatesAutoresizingMaskIntoConstraints = true
        animation.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        
        animation.play()
    }
    
    private func configureDescAnimation() {
        descView.frame = CGRect(x: view.frame.minX, y: view.frame.height, width: view.frame.width, height: self.descView.frame.height)
        descView.isHidden = true
        
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .curveEaseIn, animations: {
            self.descView.isHidden = false
            self.descView.frame = CGRect(x: self.view.frame.minX, y: 264, width: self.view.frame.width, height: self.descView.frame.height)
            
        }, completion: { _ in
            self.isAnimation = true
        })
    }
}
