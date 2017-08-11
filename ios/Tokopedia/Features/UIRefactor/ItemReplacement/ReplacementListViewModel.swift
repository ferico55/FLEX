//
//  ReplacementListViewModel.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class ReplacementListViewModel: NSObject {
    
    let refreshTrigger = PublishSubject<Void>()
    let loadNextPageTrigger = PublishSubject<Void>()
    
    var rxReplacements:Variable<[Replacement]>! = Variable([])
    let loading = Variable<Bool>(false)
    var query = Variable<String>("")
    var filter = Variable<[String:String]>([:])
    var sortType = Variable<String>("")
    var isError = false
    
    private let activityIndicator = ActivityIndicator()
    var currentPage: Int = 1
    private var nextPage: Int?
    private var provider = ReplacementProvider()

    
    override init(){
        
        super.init()
        
        let refreshRequest = loading.asObservable()
            .sample(refreshTrigger)
            .flatMap { loading -> Observable<ReplacementData> in
                if loading {
                    return Observable.empty()
                } else {
                    return self.loadReplacements(1)
                }
        }
        
        let queryRequest = query.asObservable()
            .debounce(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap { _ in
                return self.loadReplacements(1)
        }
        
        let filterRequest = filter
            .asObservable()
            .distinctUntilChanged({ (first, last) -> Bool in
                return (first == last)
            })
            .flatMap { _ in
                return self.loadReplacements(1)
        }
        
        let nextPageRequest = loading.asObservable()
            .sample(loadNextPageTrigger)
            .flatMap { loading -> Observable<ReplacementData> in
                if loading {
                    return Observable.empty()
                } else {
                    guard let nextPage = self.nextPage else { return Observable.empty() }
                    return self.loadReplacements(nextPage)
                }
        }
        
        let request = Observable
            .of(refreshRequest, nextPageRequest, queryRequest, filterRequest)
            .merge()
            .shareReplay(1)
        
        let response = request
            .flatMap { replacementData -> Observable<ReplacementData> in
                request
                    .do(onNext: { (replacementData) in
                        self.isError = false
                        self.nextPage = replacementData.page.nextPage
                    },onError: { (error) in
                        self.isError = true
                    })
                    .catchError({ error -> Observable<ReplacementData> in
                        Observable.empty()
                    })
            }
            .shareReplay(1)
        
        Observable
            .combineLatest(request, response, rxReplacements.asObservable()) { request, response, elements in
                return self.currentPage == 1 ? response.replacements : elements + response.replacements
            }
            .sample(request)
            .bindTo(rxReplacements)
            .disposed(by: rx_disposeBag)
        
        activityIndicator
            .asDriver()
            .drive(loading)
            .disposed(by: rx_disposeBag)
    }

    private func loadReplacements(_ page: Int) -> Observable<ReplacementData> {
        guard page > 0 else {
            return Observable.empty()
        }
        
        currentPage = page
        return self.provider
            .request(.listReplacement(filters: filter.value, query: query.value, page: page))
            .filterSuccessfulStatusCodes()
            .catchError({ error -> Observable<Response> in
                self.isError = true
                return Observable.empty()
            })
            .map(to: ReplacementData.self, fromKey: "data")
            .observeOn(MainScheduler.instance)
            .trackActivity(activityIndicator)
            .retry(3)
    }
}
