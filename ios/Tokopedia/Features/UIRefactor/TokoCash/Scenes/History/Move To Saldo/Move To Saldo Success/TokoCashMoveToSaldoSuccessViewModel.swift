//
//  TokoCashMoveToSaldoStatusViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 06/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashMoveToSaldoSuccessViewModel: ViewModelType {
    public struct Input {
        public let trigger: Driver<Void>
        public let homeTrigger: Driver<Void>
    }
    
    public struct Output {
        public let desc: Driver<NSAttributedString>
        public let home: Driver<Void>
    }
    
    private let status: TokoCashMoveToSaldoResponse
    private let navigator: TokoCashMoveToSaldoSuccessNavigator
    
    public init(status: TokoCashMoveToSaldoResponse, navigator: TokoCashMoveToSaldoSuccessNavigator) {
        self.status = status
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        let status = input.trigger.flatMapLatest {
            return Driver.of(self.status)
        }
        
        let desc = status.map { (response) -> NSAttributedString in
        
            guard let amount = response.data?.amount, let amountInString = NumberFormatter.idr().string(from: NSNumber(value: amount)) else { return NSAttributedString() }
            
            let regularAttributes: [String: Any] = [NSFontAttributeName: UIFont.largeTheme()]
            let boldAttributes: [String: Any] = [NSFontAttributeName: UIFont.largeThemeSemibold()]
            
            let partOne = NSMutableAttributedString(string: "Anda berhasil memindahkan ", attributes: regularAttributes)
            let partTwo = NSMutableAttributedString(string: amountInString, attributes: boldAttributes)
            let partThree = NSMutableAttributedString(string: " ke Saldo Tokopedia", attributes: regularAttributes)
            
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            combination.append(partThree)
            
            let attributeString = NSAttributedString(attributedString: combination)
            return attributeString
        }
        
        let home = input.homeTrigger.do(onNext: navigator.backToTokoCash)
        
        return Output(desc: desc,
                      home: home)
    }
    
}
