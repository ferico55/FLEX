//
//  PaymentViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Moya
import RxDataSources
import SwiftOverlays
import Lottie

@objc(PaymentViewController) class PaymentViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    private var viewModel: PaymentViewModel!
    let refreshControl: UIRefreshControl = UIRefreshControl()
    let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PaymentViewModel(provider: ScroogeProvider(),
                                     doRefresh: refreshControl.rx.controlEvent(.valueChanged).map { _ in () })

        setupTableView()

        title = "Pengaturan Pembayaran"
    }
    
    func setupRefreshControl() {
        tableView.addSubview(refreshControl)
    }

    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.backgroundColor = .tpBackground()
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "OneClickCell", bundle: nil), forCellReuseIdentifier: "OneClickCellIdentifier")
        tableView.register(UINib(nibName: "CreditCardCell", bundle: nil), forCellReuseIdentifier: "CreditCardIdentifier")
        tableView.register(UINib(nibName: "OneClickRegisterCell", bundle: nil), forCellReuseIdentifier: "OneClickRegisterCellIdentifier")

        configureDataSource(dataSource)

        viewModel.listItems?
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx_disposeBag)

        viewModel.listActivityIndicator.asObservable()
            .bindTo(refreshControl.rx.isRefreshing)
            .addDisposableTo(rx_disposeBag)

        viewModel.actionActivityIndicator.asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                guard let `self` = self else { return }
                if isLoading {
                    SwiftOverlays.showCenteredWaitOverlay(self.view)
                } else {
                    SwiftOverlays.removeAllOverlaysFromView(self.view)
                }
            }).disposed(by: rx_disposeBag)
    }

    func configureDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { dataSource, _, indexPath, _ in
            switch dataSource[indexPath] { 
            case let .oneClick(userData):
                guard let oneClickCell = self.tableView.dequeueReusableCell(withIdentifier: "OneClickCellIdentifier") as? OneClickCell else {
                    fatalError("nil cell")
                }
                let auth = UserAuthentificationManager()
                oneClickCell.set(name: auth.getUserFullName() ?? "-",
                                 rekeningNumber: userData.credentialNumber,
                                 limit: userData.maxLimit)

                oneClickCell.edit.flatMap({ [weak self] _ -> Observable<OneClickAuth> in
                    guard let `self` = self else { return .empty() }
                    oneClickCell.editButton.isEnabled = false
                    return self.viewModel.getToken()
                }).subscribe(onNext: { [weak self] data in
                    guard let `self` = self else { return }
                    oneClickCell.editButton.isEnabled = true
                    if let accessToken = data.token?.accessToken {
                        let editVC = OneClickEditViewController(userData: userData, accessToken: accessToken, viewModel: self.viewModel)
                        self.navigationController?.pushViewController(editVC, animated: true)
                    } else {
                        guard let message = data.message else { return }
                        StickyAlertView.showErrorMessage([message])
                    }
                }).disposed(by: oneClickCell.disposeBag)

                oneClickCell.delete
                    .flatMap({ [weak self] _ -> Observable<Void> in
                        guard let `self` = self else { return .empty() }
                        return self.showAlertConfrimationDeleteOneClick(userData)
                    }).subscribe(onNext: { [weak self] _ in
                        guard let `self` = self else { return }
                        self.viewModel.deleteOneClickData(userData)
                    }).disposed(by: oneClickCell.disposeBag)

                return oneClickCell

            case .oneClickRegister():
                guard let registerCell: OneClickRegisterCell = self.tableView.dequeueReusableCell(withIdentifier: "OneClickRegisterCellIdentifier") as? OneClickRegisterCell else {
                    fatalError("nil cell")
                }

                registerCell.register.flatMap({ _ -> Observable<OneClickAuth> in
                    registerCell.registerButton.isEnabled = false
                    return self.viewModel.getToken()
                }).subscribe(onNext: { [weak self] data in
                    guard let `self` = self else { return }
                    registerCell.registerButton.isEnabled = true
                    if let accessToken = data.token?.accessToken {
                        let registerVC = OneClickRegisterViewController(accessToken: accessToken, viewModel: self.viewModel)
                        self.navigationController?.pushViewController(registerVC, animated: true)
                    } else {
                        guard let message = data.message else { return }
                        StickyAlertView.showErrorMessage([message])
                    }
                }).disposed(by: registerCell.disposeBag)

                return registerCell

            case let .creditCard(userData):
                guard let creditCardCell: CreditCardCell = self.tableView.dequeueReusableCell(withIdentifier: "CreditCardIdentifier") as? CreditCardCell else {
                    fatalError("nil cell")
                }
                creditCardCell.setData(userData)
                creditCardCell.delete
                    .flatMap({ [weak self] _ -> Observable<Void> in
                        guard let `self` = self else { return .empty() }
                        return self.showAlertConfrimationDeleteCreditCard(userData)
                    }).subscribe(onNext: { [weak self] _ in
                        guard let `self` = self else { return }
                        self.viewModel.deleteCreditCardData(userData)
                    }).disposed(by: creditCardCell.disposeBag)
                return creditCardCell

            case .emptyCreditCard():
                let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCreditCardCellIdentifier")
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                let emptyStateView = EmptyStateView(
                    frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: self.view.frame.width, height: cell.frame.size.height),
                    title: "Oops, kartu kredit masih kosong",
                    description: "Segera transaksi menggunakan kartu kredit untuk menyimpan data Anda")
                cell.contentView.addSubview(emptyStateView)
                emptyStateView.snp.makeConstraints({ make in
                    make.height.equalTo(240)
                    make.left.equalTo(10)
                    make.bottom.right.equalTo(-10)
                    make.top.equalTo(0)
                })

                return cell
            case .errorFetchData():
                let cell = UITableViewCell(style: .default, reuseIdentifier: "ErrorFetchCellIdentifier")
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                let emptyStateView = EmptyStateView(
                    frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: self.view.frame.width, height: cell.frame.size.height),
                    title: "Oops!",
                    description: "Mohon maaf terjadi kendala pada server.\nSilakan ulangi beberapa saat lagi.",
                    buttonTitle: "Coba Lagi")
                cell.contentView.addSubview(emptyStateView)
                emptyStateView.snp.makeConstraints({ make in
                    make.height.equalTo(280)
                    make.left.equalTo(10)
                    make.bottom.right.equalTo(-10)
                    make.top.equalTo(0)
                })
                emptyStateView.onTapButton = { [weak self] _ in
                    guard let `self` = self else { return }
                    self.refreshData()
                    emptyStateView.isHidden = true
                }

                return cell

            case .errorInternetConnection():
                let cell = UITableViewCell(style: .default, reuseIdentifier: "ErrorConnectionCellIdentifier")
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                let emptyStateView = EmptyStateView(
                    frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: self.view.frame.width, height: cell.frame.size.height),
                    title: "Oops, Tidak ada koneksi internet",
                    description: "Mohon cek kembali jaringan Anda",
                    buttonTitle: "Coba Lagi")
                cell.contentView.addSubview(emptyStateView)
                emptyStateView.snp.makeConstraints({ make in
                    make.height.equalTo(280)
                    make.left.equalTo(10)
                    make.bottom.right.equalTo(-10)
                    make.top.equalTo(0)
                })

                emptyStateView.onTapButton = { [weak self] _ in
                    guard let `self` = self else { return }
                    self.refreshData()
                    emptyStateView.isHidden = true
                }

                return cell

            case .empty():
                guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "EmptyCellIdentifier") else {
                    fatalError("nil cell")
                }
                return cell
            }
        }

        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.title
        }
    }

    func refreshData() {
        DispatchQueue.main.async { [weak self] _ in
            guard let `self` = self else { return }
            self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            self.refreshControl.beginRefreshing()
        }
        DispatchQueue.global(qos: .background).async { [weak self] _ in
            guard let `self` = self else { return }
            self.refreshControl.sendActions(for: .valueChanged)
        }

    }

    func showAlertConfrimationDeleteCreditCard(_ data: CreditCardData) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create()}
            let alertVC = UIAlertController(title: "Hapus Kartu Kredit", message: "Hapus nomor kartu kredit\n\(data.number) ?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Batal", style: .default, handler: { _ in
                observer.onCompleted()
            }))
            alertVC.addAction(UIAlertAction(title: "Hapus", style: .default, handler: { _ in
                observer.onNext()
                observer.onCompleted()
            }))
            self.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func showAlertConfrimationDeleteOneClick(_ data: OneClickData) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else { return Disposables.create()}
            let alertVC = UIAlertController(title: "Hapus BCA Oneklik", message: "Hapus nomor rekening BCA Oneklik\n\(data.credentialNumber) ?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Batal", style: .default, handler: { _ in
                observer.onCompleted()
            }))
            alertVC.addAction(UIAlertAction(title: "Hapus", style: .default, handler: { _ in
                observer.onNext()
                observer.onCompleted()
            }))
            self.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
