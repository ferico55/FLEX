//
//  TokoCashMoveToSaldoFailedViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashMoveToSaldoFailedViewModel: ViewModelType {
    struct Input {
        let retryTrigger: Driver<Void>
        let homeTrigger: Driver<Void>
    }
    
    struct Output {
        let retry: Driver<Void>
        let home: Driver<Void>
    }
    
    private let navigator: TokoCashMoveToSaldoFailedNavigator
    
    init(navigator: TokoCashMoveToSaldoFailedNavigator) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let retry = input.retryTrigger.do(onNext: navigator.backToMoveToSaldo)
        
        let home = input.homeTrigger.do(onNext: navigator.backToTokoCash)
        
        return Output(retry: retry,
                      home: home)
    }
    
}
