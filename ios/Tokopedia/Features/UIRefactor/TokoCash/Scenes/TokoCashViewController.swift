//
//  TokoCashWalletHistoryViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import CFAlertViewController
import RxSwift
import RxCocoa

class TokoCashViewController: UIViewController, TokoCashNominalDelegate {
    
    // outlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var optionBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var balanceActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var totalActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var thresholdActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var topUpView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var holdBalanceView: UIView!
    @IBOutlet weak var holdBalanceDescView: UIView!
    @IBOutlet weak var holdBalanceInfoButton: UIButton!
    @IBOutlet weak var holdBalanceLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var walletProgressView: UIProgressView!
    @IBOutlet weak var nominalLabel: UILabel!
    @IBOutlet weak var nominalButton: UIButton!
    @IBOutlet weak var topUpButton: UIButton!
    @IBOutlet weak var topUpActivityIndicator: UIActivityIndicatorView!
    
    private let refreshControl = UIRefreshControl()
    private var nominal: Variable<DigitalProduct?> = Variable(nil)
    
    // view model
    var viewModel: TokoCashViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRefreshControl()
        bindViewModel()
        configureTapHoldBalanceInfo()
        configureTapOptionButton()
    }
    
    private func configureRefreshControl() {
        if #available(iOS 10.0, *) {
            scrollView.refreshControl = refreshControl
        } else {
            scrollView.addSubview(refreshControl)
        }
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        let pull = refreshControl.rx
            .controlEvent(.valueChanged)
            .asDriver()
        
        let nominalTrigger = nominal.asDriver().flatMapLatest { digitalProduct -> SharedSequence<DriverSharingStrategy, DigitalProduct?> in
            guard let dp = digitalProduct else { return Driver.empty() }
            return Driver.of(dp)
        }
        
        let input = TokoCashViewModel.Input(trigger: Driver.merge(Driver.just(), pull),
                                            nominal: nominalTrigger,
                                            nominalTrigger: nominalButton.rx.tap.asDriver(),
                                            topUpTrigger: topUpButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.fetching
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: rx_disposeBag)
        output.fetching
            .drive(balanceActivityIndicatorView.rx.isAnimating)
            .disposed(by: rx_disposeBag)
        output.fetching
            .drive(totalActivityIndicatorView.rx.isAnimating)
            .disposed(by: rx_disposeBag)
        output.fetching
            .drive(thresholdActivityIndicatorView.rx.isAnimating)
            .disposed(by: rx_disposeBag)
        output.fetching
            .drive(onNext: { isHidden in
                self.balanceLabel.isHidden = isHidden
                self.totalBalanceLabel.isHidden = isHidden
                self.thresholdLabel.isHidden = isHidden
            })
            .disposed(by: rx_disposeBag)
        output.isTopUpVisible
            .debug()
            .drive(topUpView.rx.isHidden)
            .dispose()
        output.selectedNominalString
            .drive(nominalLabel.rx.text)
            .disposed(by: rx_disposeBag)
        output.balance
            .drive(balanceLabel.rx.text)
            .disposed(by: rx_disposeBag)
        output.holdBalanceView
            .drive(onNext: { isHidden in
                UIView.animate(withDuration: 0.3){
                    self.holdBalanceDescView.isHidden = isHidden
                    self.holdBalanceLabel.isHidden = isHidden
                    self.holdBalanceView.isHidden = isHidden
                    self.holdBalanceView.backgroundColor = isHidden ? .clear : .white
                    self.stackView.layoutIfNeeded()
                }
            })
            .disposed(by: rx_disposeBag)
        output.holdBalance
            .drive(holdBalanceLabel.rx.text)
            .disposed(by: rx_disposeBag)
        output.totalBalance
            .drive(totalBalanceLabel.rx.text)
            .disposed(by: rx_disposeBag)
        output.threshold
            .drive(thresholdLabel.rx.text)
            .disposed(by: rx_disposeBag)
        output.spendingProgress
            .drive(onNext: { progress in
                self.walletProgressView.setProgress(progress, animated: true)
            })
            .disposed(by: rx_disposeBag)
        output.nominal
            .drive()
            .disposed(by: rx_disposeBag)
        output.topUp
            .drive()
            .disposed(by: rx_disposeBag)
        output.topUpActivityIndicator
            .drive(topUpActivityIndicator.rx.isAnimating)
            .disposed(by: rx_disposeBag)
        output.disableTopUpButton
            .drive(topUpButton.rx.isEnabled)
            .disposed(by: rx_disposeBag)
        output.backgroundButtonColor
            .drive(onNext: { color in
                self.topUpButton.backgroundColor = color
            }).addDisposableTo(rx_disposeBag)
        
    }
    
    private func configureTapHoldBalanceInfo() {
        holdBalanceInfoButton.rx.tap
            .subscribe(onNext: { _ in
                let closeButton = CFAlertAction.action(title: "Tutup",
                                                       style: .Default,
                                                       alignment: .justified,
                                                       backgroundColor: UIColor.tpGreen(),
                                                       textColor: .white,
                                                       handler: nil)
                let actionSheet = TooltipAlert.createAlert(title: "Dana Tertahan",
                                                           subtitle: "Dana Anda tertahan, untuk Transaksi yang Belum Lunas. Dana akan dikembalikan bila transaksi batal.",
                                                           image: UIImage(named: "icon_tokocash_lock")!,
                                                           buttons:[closeButton])
                self.present(actionSheet, animated: true, completion: nil)
            })
            .disposed(by: rx_disposeBag)
    }
    
    private func configureTapOptionButton() {
        optionBarButtonItem.rx.tap
            .subscribe(onNext: { _ in
                
                let navigator = TokoCashNavigator(navigationController: self.navigationController!)
                
                let alertController = UIAlertController(title: nil, message: "Lainnya", preferredStyle: .actionSheet)
                let openWalletHistoryAction = UIAlertAction(title: "Riwayat Transaksi", style: .default) { _ in
                    navigator.toWalletHistory()
                }
                let settingAction = UIAlertAction(title: "Pengaturan Akun", style: .default) { _ in
                    navigator.toAccountSetting()
                }
                let helpAction = UIAlertAction(title: "Bantuan", style: .default) { _ in
                    navigator.toHelpWebView()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
                
                alertController.addAction(openWalletHistoryAction)
                alertController.addAction(settingAction)
                alertController.addAction(helpAction)
                alertController.addAction(cancelAction)
                alertController.popoverPresentationController?.barButtonItem = self.optionBarButtonItem
                self.present(alertController, animated: true)
            })
            .disposed(by: rx_disposeBag)
    }
    
    func getNominal(_ nominal: DigitalProduct) {
        self.nominal.value = nominal
    }
}
