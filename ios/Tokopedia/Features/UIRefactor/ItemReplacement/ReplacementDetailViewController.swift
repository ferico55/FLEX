//
//  ReplacementDetailViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Render

@objc(ReplacementDetailViewController) class ReplacementDetailViewController: UIViewController {
    
    private var viewModel : ReplacementDetailViewModel!
    private var component : ReplacementDetailView!
    var didTakeReplacement: (() -> Void)?
    
    init(_ replacement: Replacement) {
        super.init(nibName: nil, bundle: nil)
        
        viewModel = ReplacementDetailViewModel(replacement: replacement)
        component = ReplacementDetailView(viewModel:viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Replacement Detail Page")
    }
    
    override func viewDidLayoutSubviews() {
        component.render(in: self.view.bounds.size)
    }
    
    func setupView() {
        self.title = "Peluang Baru"
        
        self.view.backgroundColor = .tpBackground()
        self.view.addSubview(component)
        component.render(in: self.view.bounds.size)
    }
    
    func setupButton() {
        viewModel.seeProduct
            .asObserver()
            .subscribe(onNext: { [unowned self] in
                self.showProductDetail()
            })
            .disposed(by: rx_disposeBag)
        
        viewModel.takeReplacement
            .asObserver()
            .flatMap({ () -> Observable<Void> in
                AnalyticsManager.trackEventName("clickPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: GA_EVENT_ACTION_CLICK, label: "Ambil Peluang")
                return self.showAlert()
            }).subscribe(onNext: { [unowned self] in
                AnalyticsManager.trackEventName("clickPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: GA_EVENT_ACTION_CLICK, label: "Ya")
                self.viewModel.takeReplacementTrigger.onNext()
            })
            .disposed(by: rx_disposeBag)
        
        viewModel.didTakeOpportunity
            .asObservable()
            .subscribe(onNext: { [unowned self] result in
                guard let message = result.message else { return }
                guard result.status == 1 else {
                    StickyAlertView.showErrorMessage([message])
                    return
                }
                self.didTakeReplacement?()
                self.viewModel.canTakeOpportunity.value = false
                StickyAlertView.showSuccessMessage([message])
            }, onError: { error in
                StickyAlertView.showErrorMessage(["Terjadi kendala pada server."])
            })
            .disposed(by: rx_disposeBag)
    }
    
    func showAlert() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let alertVC = UIAlertController(title: "", message: "Dengan klik \"Setuju\", anda menyetujui barang yang akan dikirim sudah sesuai pesanan pembeli.\n\nPembatalan akan dikenakan penalti reputasi: -10", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Setuju", style: .default, handler: { _ in
                observer.onNext()
                observer.onCompleted()
            }))
            alertVC.addAction(UIAlertAction(title: "Kembali", style: .cancel, handler: { _ in
                AnalyticsManager.trackEventName("clickPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: GA_EVENT_ACTION_CLICK, label: "Tidak")
                observer.onCompleted()
            }))
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showProductDetail() {
        let product = self.viewModel.rxReplacement.value.products.first!
        let vc = ProductDetailViewController(productID: product.identifier, name: product.name, price: product.priceWithFormat, imageURL: product.thumbnailUrlString, isReplacementMode: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
