//
//  PaymentSaveCCViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class PaymentSaveCCViewController: UIViewController {
    
    @IBOutlet private weak var webView: UIWebView!
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate let urlRequest = PublishSubject<(request: URLRequest, navigationType: UIWebViewNavigationType)>()
    
    // view model
    public var viewModel: PaymentSaveCCViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Simpan Kartu Kredit"
        
        configureActivityIndicator()
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = PaymentSaveCCViewModel.Input(trigger: viewWillAppear,
                                                 URLRequestTrigger: urlRequest.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.isFetching
            .drive(activityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.urlRequest.drive(onNext: { urlRequest in
            self.webView.loadRequest(urlRequest)
        }).addDisposableTo(rx_disposeBag)
        
        output.isCallback.filter { isCallback -> Bool in
            return isCallback
        }.drive(onNext: { _ in
            self.navigationController?.popViewController(animated: true)
        }).addDisposableTo(rx_disposeBag)
    }
    
    private func configureActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(barButton, animated: true)
    }
}

extension PaymentSaveCCViewController: UIWebViewDelegate {
    public func webView(_ webView: UIWebView,
                        shouldStartLoadWith request: URLRequest,
                        navigationType: UIWebViewNavigationType) -> Bool {
        urlRequest.onNext((request: request, navigationType: navigationType))
        return true
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
}
