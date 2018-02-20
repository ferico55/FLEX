//
//  TokoCashHelpViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TokoCashHelpViewController: UIViewController {
    
    @IBOutlet weak private var categoryTextField: UITextField!
    @IBOutlet weak private var detailsTextField: UITextField!
    @IBOutlet weak private var helpButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private let doneButton = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(TokoCashHelpViewController.dismissKeyboard))
    private let categoryPicker = UIPickerView()
    
    private var selectedIndex = Variable<(row: Int, component: Int)>(row: 0, component:0)
    
    // view model
    public var viewModel: TokoCashHelpViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bantuan"
        
        configureCategoryPicker()
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashHelpViewModel.Input(trigger: viewWillAppear,
                                                selectedCategory: Driver.merge(categoryPicker.rx.itemSelected.asDriver(), selectedIndex.asDriver()),
                                                details: detailsTextField.rx.text.orEmpty.asDriver(),
                                                helpTrigger: helpButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.helpCategories.drive(categoryPicker.rx.itemTitles) { _, item in
            return item
        }.addDisposableTo(rx_disposeBag)
        
        output.selectedCategory
            .drive()
            .addDisposableTo(rx_disposeBag)
        
        output.selectedTranslation
            .drive(categoryTextField.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.disableButton
            .drive(helpButton.rx.isEnabled)
            .addDisposableTo(rx_disposeBag)
        
        output.backgroundButtonColor
            .drive(onNext: { color in
                self.helpButton.backgroundColor = color
            }).addDisposableTo(rx_disposeBag)
        
        output.requestActivity
            .drive(activityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.help
            .drive()
            .addDisposableTo(rx_disposeBag)
        
        output.successMessage.drive(onNext: { message in
            StickyAlertView.showSuccessMessage([message])
        }).addDisposableTo(rx_disposeBag)
        
        output.errorMessage.drive(onNext: { message in
            StickyAlertView.showErrorMessage([message])
        }).addDisposableTo(rx_disposeBag)
    }
    
    private func configureCategoryPicker() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        categoryTextField.inputAccessoryView = toolBar
        categoryTextField.inputView = categoryPicker
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        selectedIndex.value = (row:categoryPicker.selectedRow(inComponent: 0), component: 0)
    }
}
