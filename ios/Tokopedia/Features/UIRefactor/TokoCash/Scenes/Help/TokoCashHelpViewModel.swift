//
//  TokoCashHelpViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 13/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashHelpViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let selectedCategory: Driver<(row: Int, component: Int)>
        let details: Driver<String>
        let helpTrigger: Driver<Void>
    }
    
    struct Output {
        let helpCategories: Driver<[String]>
        let selectedCategory: Driver<TokoCashHelpCategory>
        let selectedTranslation: Driver<String>
        let disableButton: Driver<Bool>
        let backgroundButtonColor: Driver<UIColor>
        let requestActivity: Driver<Bool>
        let help: Driver<TokoCashResponse>
        let successMessage: Driver<String>
        let errorMessage: Driver<String>
    }
    
    private let categoryItems: [TokoCashHelpCategory] = {
        var arr: [TokoCashHelpCategory] = []
        arr.append(TokoCashHelpCategory(categoryId: "Tx_Issue", translation: "Kendala Transaksi"))
        arr.append(TokoCashHelpCategory(categoryId: "TopUp_Issue", translation: "Kendala Top Up"))
        arr.append(TokoCashHelpCategory(categoryId: "Receipt_Issue", translation: "Kendala Penerimaan Dana"))
        arr.append(TokoCashHelpCategory(categoryId: "Refund_Issue", translation: "Kendala Pengembalian Dana"))
        arr.append(TokoCashHelpCategory(categoryId: "Cashback_Issue", translation: "Kendala Cashback"))
        return arr
    }()
    
    private let transactionId: String
    private let navigator: TokoCashHelpNavigator
    
    init(_ transactionId: String, navigator: TokoCashHelpNavigator) {
        self.transactionId = transactionId
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
        let transactionId = Driver.of(self.transactionId)
        let categoryItems = Driver.of(self.categoryItems)
        
        let helpCategories = input.trigger.flatMapLatest {
            return categoryItems.map { $0.map { $0.translation } }
        }
        
        let selectedCategory = input.selectedCategory
            .withLatestFrom(categoryItems) { (pick, items) -> TokoCashHelpCategory in
                return items[pick.row]
        }
        
        let selectedTranslation = selectedCategory.map { (helpCategory) -> String in
            return helpCategory.translation
        }
        
        let complaint = Driver.combineLatest(transactionId, selectedCategory, input.details)
        
        let isValid = complaint.map { _, selectedCategory, details -> Bool in
            guard !selectedCategory.categoryId.isEmpty, details.trimmingCharacters(in: .whitespacesAndNewlines).count >= 30 else { return false }
            return true
            }.startWith(false)
        
        let requestActivity = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let help = input.helpTrigger.withLatestFrom(complaint)
            .flatMapLatest { transactionId, helpCategory, details -> SharedSequence<DriverSharingStrategy, TokoCashResponse> in
                TokoCashUseCase.requestHelp(message: details, category: helpCategory.translation, transactionId: transactionId)
                    .trackActivity(requestActivity)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
        }
        
        let successMessage = help.filter { response -> Bool in
            guard let code = response.code, code == "200000" else { return false }
            return true
            }.map { response -> String in
                return response.message ?? ""
            }.do(onNext: { _ in
                self.navigator.toPreviousPage()
            })
        
        let errorMessage = errorTracker.withLatestFrom(help)
            .map { response -> String in
                return response.message ?? ""
        }
        
        let disableButton = Driver.combineLatest(isValid, requestActivity) {
            return $0 && !$1
        }
        
        let backgroundButtonColor = disableButton.map { disableButton -> UIColor in
            guard disableButton else { return UIColor(red: 224.0 / 255.0, green: 224.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0) }
            return UIColor.tpGreen()
        }
        
        return Output(helpCategories: helpCategories,
                      selectedCategory: selectedCategory,
                      selectedTranslation: selectedTranslation,
                      disableButton: disableButton,
                      backgroundButtonColor: backgroundButtonColor,
                      requestActivity: requestActivity.asDriver(),
                      help: help,
                      successMessage: successMessage,
                      errorMessage: errorMessage)
    }
}
