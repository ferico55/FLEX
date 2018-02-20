//
//  TokoCashPendingTransactionViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashPendingTransactionViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let selection: Driver<IndexPath>
    }
    
    public struct Output {
        public let items: Driver<[TokoCashHistoryListItemViewModel]>
        public let selectedItem: Driver<TokoCashHistoryItems>
    }
    
    private let pendingItems: [TokoCashHistoryItems]
    private let navigator: TokoCashPendingTransactionNavigator
    
    public init(pendingItems: [TokoCashHistoryItems], navigator: TokoCashPendingTransactionNavigator) {
        self.pendingItems = pendingItems
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
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
