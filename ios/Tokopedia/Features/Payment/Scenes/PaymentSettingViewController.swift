//
//  PaymentSettingViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import MoyaUnbox
import RxCocoa
import RxSwift
import UIKit

public class PaymentSettingViewController: UIViewController {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var refreshActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var descView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewheightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var authenticationView: UIView!
    @IBOutlet private weak var authenticationSettingButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    private var emptyStateView: EmptyStateView?
    private let retry = PublishSubject<Void>()
    // view model
    public var viewModel: PaymentSettingViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pengaturan Pembayaran"
        
        configureTableView()
        bindViewModel()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
        tableViewheightConstraint.constant = tableView.contentSize.height
        view.layoutIfNeeded()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = PaymentSettingViewModel.Input(trigger: Driver.merge(viewWillAppear, retry.asDriverOnErrorJustComplete()),
                                                  selected: tableView.rx.itemSelected.asDriver(),
                                                  saveTrigger: Driver.merge(addButton.rx.tap.asDriver(), saveButton.rx.tap.asDriver()),
                                                  authenticationSettingTrigger: authenticationSettingButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.activityIndicator
            .drive(activityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.activityIndicator
            .drive(refreshActivityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.desc
            .drive(descLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.hideDesc.drive(onNext: { isHidden in
            UIView.animate(withDuration: 0.3) {
                self.descView.subviews.forEach { $0.isHidden = isHidden }
                self.descView.isHidden = isHidden
            }
        }).addDisposableTo(rx_disposeBag)
        
        output.creditCard.drive(tableView.rx.items(cellIdentifier: PaymentCCTableViewCell.reuseID, cellType: PaymentCCTableViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
        }.addDisposableTo(rx_disposeBag)
        
        output.creditCard.drive(onNext: { _ in
            UIView.animate(withDuration: 0.3) {
                self.scrollView.isHidden = false
            }
        }).addDisposableTo(rx_disposeBag)
        
        output.hideAddButton
            .drive(addButton.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
        
        output.selectedCC.drive().addDisposableTo(rx_disposeBag)
        output.saveCC.drive().addDisposableTo(rx_disposeBag)
        output.authenticationSetting.drive().addDisposableTo(rx_disposeBag)
        
        output.error.drive(onNext: { error in
            
            self.scrollView.isHidden = true
            
            var title = "Oops"
            var description = ""
            let buttonTitle = "Coba Lagi"
            if let moyaError = error as? MoyaError,
                case let .underlying(responseError) = moyaError,
                responseError._code == NSURLErrorNotConnectedToInternet {
                title = "Oops, Tidak ada koneksi internet"
                description = "Mohon cek kembali jaringan Anda"
            } else {
                description = "Mohon maaf terjadi kendala pada server.\nSilakan ulangi beberapa saat lagi."
            }
            
            self.emptyStateView = EmptyStateView(
                frame: self.view.frame,
                title: title,
                description: description,
                buttonTitle: buttonTitle)
            guard let emptyStateView = self.emptyStateView else { return }
            self.view.addSubview(emptyStateView)
            emptyStateView.snp.makeConstraints({ make in
                make.height.equalTo(280)
                make.center.equalTo(self.view)
            })
            emptyStateView.onTapButton = { [weak self] _ in
                guard self != nil else { return }
                emptyStateView.removeFromSuperview()
                self?.retry.onNext()
            }
        }).addDisposableTo(rx_disposeBag)
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: "PaymentCCTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentCCTableViewCell")
        tableView.estimatedRowHeight = 61
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}
