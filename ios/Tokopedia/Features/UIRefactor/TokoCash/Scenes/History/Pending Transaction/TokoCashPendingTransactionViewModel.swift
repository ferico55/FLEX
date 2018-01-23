//
//  TokoCashPendingTransactionViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashPendingTransactionViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let selection: Driver<IndexPath>
    }
    
    struct Output {
        let items: Driver<[TokoCashHistoryListItemViewModel]>
        let selectedItem: Driver<TokoCashHistoryItems>
    }
    
    private let pendingItems: [TokoCashHistoryItems]
    private let navigator: TokoCashPendingTransactionNavigator
    
    init(pendingItems: [TokoCashHistoryItems], navigator: TokoCashPendingTransactionNavigator) {
        self.pendingItems = pendingItems
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let items = Driver.of(self.pendingItems)
        
        let itemsViewModel = items.map { $0.map { TokoCashHistoryListItemViewModel(with: $0) } }
        
        let selectedItem = input.selection
            .withLatestFrom(itemsViewModel) { (indexPath, itemsViewModel) -> TokoCashHistoryItems in
                return itemsViewModel[indexPath.row].historyItem
            }.do(onNext: navigator.toDetailPage)
        
        return Output(items: itemsViewModel,
                      selectedItem: selectedItem)
    }
    
}
