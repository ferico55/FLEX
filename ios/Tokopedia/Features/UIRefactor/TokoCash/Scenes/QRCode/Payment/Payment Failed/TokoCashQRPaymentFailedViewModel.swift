//
//  TokoCashQRPaymentFailedViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashQRPaymentFailedViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let retryTrigger: Driver<Void>
    }
    
    public struct Output {
        public let retry: Driver<Void>
    }
    
    private let navigator: TokoCashQRPaymentFailedNavigator
    
    public init(navigator: TokoCashQRPaymentFailedNavigator) {
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let retry = input.retryTrigger.do(onNext: navigator.toQRPage)
        
        return Output(retry: retry)
    }
}
