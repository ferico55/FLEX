//
//  ReplacementDetailViewModel.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class ReplacementDetailViewModel: NSObject {
    
    var rxReplacement: Variable<Replacement>! = nil
    var didTakeOpportunity = Variable<TakeReplacementResult>(TakeReplacementResult.init(orderId: "0", status: 0, message: nil))
    let takeReplacement = PublishSubject<Void>()
    let takeReplacementTrigger = PublishSubject<Void>()
    let seeProduct = PublishSubject<Void>()
    let loading = Variable<Bool>(false)
    let canTakeOpportunity = Variable<Bool>(true)
    let error = PublishSubject<Swift.Error>()
    private let activityIndicator = ActivityIndicator()
    private var provider = ReplacementProvider()
    
    
    init(replacement: Replacement){
        
        super.init()
        
        rxReplacement = Variable<Replacement>(replacement)
        
        let request = loading.asObservable()
            .sample(takeReplacementTrigger)
            .flatMap { loading -> Observable<TakeReplacementResult> in
                if loading {
                    return Observable.empty()
                } else {
                    return self.takeReplacement(replacement.identifier)
                }
            }
            .shareReplay(1)

        let response = request
            .flatMap { replacement-> Observable<TakeReplacementResult> in
                request
                    .do(onError: { (error) in
                        self.error.onNext(error)
                    })
                    .catchError({ error -> Observable<TakeReplacementResult> in
                        Observable.empty()
                    })
            }
            
            .shareReplay(1)
        
        response
            .asObservable()
            .bindTo(didTakeOpportunity)
            .disposed(by: rx_disposeBag)
        
        activityIndicator
            .asDriver()
            .drive(loading)
            .disposed(by: rx_disposeBag)
    }

    
    func takeReplacement(_ id: String) -> Observable<TakeReplacementResult> {
        return self.provider
            .request(.takeReplacement(id: id))
            .filterSuccessfulStatusCodes()
            .catchError({ error -> Observable<Response> in
                return Observable.empty()
            })
            .map(to: TakeReplacementResult.self, fromKey: "data")
            .observeOn(MainScheduler.instance)
            .trackActivity(activityIndicator)
    }
    
}
