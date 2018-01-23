//
//  TokoCashQRPaymentFailedViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashQRPaymentFailedViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let retryTrigger: Driver<Void>
    }
    
    struct Output {
        let retry: Driver<Void>
    }
    
    private let navigator: TokoCashQRPaymentFailedNavigator
    
    init(navigator: TokoCashQRPaymentFailedNavigator) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let retry = input.retryTrigger.do(onNext: navigator.toQRPage)
        
        return Output(retry: retry)
    }
}
