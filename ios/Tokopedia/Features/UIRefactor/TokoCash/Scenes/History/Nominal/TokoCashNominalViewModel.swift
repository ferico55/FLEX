//
//  TokoCashNominalViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashNominalViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let selectedItem: Driver<IndexPath>
    }
    
    struct Output {
        let items: Driver<[TokoCashNominalItemViewModel]>
        let selectedItem: Driver<DigitalProduct>
    }
    
    private let items: [DigitalProduct]
    
    init(items: [DigitalProduct]) {
        self.items = items
    }
    
    func transform(input: Input) -> Output {
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
