//
//  TokoCashMoveToSaldoFailedViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashMoveToSaldoFailedViewModel: ViewModelType {
    public struct Input {
        public let retryTrigger: Driver<Void>
        public let homeTrigger: Driver<Void>
    }
    
    public struct Output {
        public let retry: Driver<Void>
        public let home: Driver<Void>
    }
    
    private let navigator: TokoCashMoveToSaldoFailedNavigator
    
    public init(navigator: TokoCashMoveToSaldoFailedNavigator) {
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let retry = input.retryTrigger.do(onNext: navigator.backToMoveToSaldo)
        
        let home = input.homeTrigger.do(onNext: navigator.backToTokoCash)
        
        return Output(retry: retry,
                      home: home)
    }
    
}
