//
//  TokoCashNominalViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashNominalViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let selectedItem: Driver<IndexPath>
    }
    
    public struct Output {
        public let items: Driver<[TokoCashNominalItemViewModel]>
        public let selectedItem: Driver<DigitalProduct>
    }
    
    private let items: [DigitalProduct]
    
    public init(items: [DigitalProduct]) {
        self.items = items
    }
    
    public func transform(input: Input) -> Output {
        let items = input.trigger.flatMapLatest {
            return Driver.of(self.items)
                .map { $0.map { TokoCashNominalItemViewModel(with: $0) } }
        }
        
        let selectedItem = input.selectedItem
            .withLatestFrom(items) { (indexPath, items) -> DigitalProduct in
                return self.items[indexPath.row]
            }
        
        return Output(items: items,
                      selectedItem: selectedItem)
    }
}
