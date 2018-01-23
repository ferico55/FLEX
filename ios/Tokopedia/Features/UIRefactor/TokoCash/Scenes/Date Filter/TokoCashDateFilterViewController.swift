//
//  TokoCashDateFilterViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HMSegmentedControl

class TokoCashDateFilterViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var segmentControl: HMSegmentedControl!
    @IBOutlet weak var resetBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    
    @IBOutlet weak var applyButton: UIButton!
    
    private let fromPicker = UIDatePicker()
    private let toPicker = UIDatePicker()
    private let isDateRange = Variable(true)
    
    // view model
    var viewModel: TokoCashDateFilterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSection()
        configureTableView()
        configureStartPicker()
        configureToPicker()
        
        bindViewModel()
    }
    
    func configureSection() {
        segmentControl?.sectionTitles = ["Pilih Rentang Waktu", "Pilih Tanggal"]
        segmentControl?.segmentWidthStyle = .fixed
        segmentControl?.selectionIndicatorBoxOpacity = 0
        segmentControl?.selectionStyle = .box;
        segmentControl?.selectedSegmentIndex = HMSegmentedControlNoSegment;
        segmentControl?.type = .text
        segmentControl?.selectionIndicatorLocation = .down;
        segmentControl?.selectionIndicatorHeight = 3
        segmentControl?.selectedSegmentIndex = 0
        segmentControl?.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.tpGreen(), NSFontAttributeName : UIFont.systemFont(ofSize: 14)]
        segmentControl?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0, green: 0, blue: 0, alpha: 0.38)
            , NSFontAttributeName : UIFont.systemFont(ofSize: 14)]
        segmentControl?.selectionIndicatorColor = UIColor.tpGreen()
        
        let viewWidth = view.frame.width
        weak var weakSelf = self
        segmentControl.indexChangeBlock = { index in
            weakSelf?.scrollView.scrollRectToVisible(CGRect(x: viewWidth * CGFloat(index), y: 0, width: viewWidth, height: 200), animated: true)
            self.isDateRange.value = index == 0 ? true : false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width;
        let page = scrollView.contentOffset.x / pageWidth;
        segmentControl.setSelectedSegmentIndex(UInt(page), animated: true)
        self.isDateRange.value = page == 0 ? true : false
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
    }
    
    func configureStartPicker() {
        fromPicker.datePickerMode = .date
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(TokoCashDateFilterViewController.dismissPicker))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        fromDateTextField.inputAccessoryView = toolBar
        fromDateTextField.inputView = fromPicker
    }
    
    func configureToPicker() {
        toPicker.datePickerMode = .date
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(TokoCashDateFilterViewController.dismissPicker))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        toDateTextField.inputAccessoryView = toolBar
        toDateTextField.inputView = toPicker
    }
    
    func dismissPicker() {
        view.endEditing(true)
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashDateFilterViewModel.Input(trigger: viewWillAppear,
                                                      resetTrigger: resetBarButtonItem.rx.tap.asDriver(),
                                                      selectedItem: tableView.rx.itemSelected.asDriver(),
                                                      applyTrigger: applyButton.rx.tap.asDriver(),
                                                      fromDate: fromPicker.rx.date.asDriver(),
                                                      toDate: toPicker.rx.date.asDriver(),
                                                      isDateRange: isDateRange.asDriver())
        let output = viewModel.transform(input: input)
        
        output.items.drive(tableView.rx.items(cellIdentifier: TokoCashDateRangeItemTableViewCell.reuseID, cellType: TokoCashDateRangeItemTableViewCell.self)) { tv, viewModel, cell in
            cell.bind(viewModel)
            }.addDisposableTo(rx_disposeBag)
        
        output.fromDate
            .drive(onNext: { (date) in
                self.fromPicker.date = date
            }).addDisposableTo(rx_disposeBag)
        
        output.fromDateMax
            .drive(onNext: { (date) in
                self.fromPicker.maximumDate = date
            }).addDisposableTo(rx_disposeBag)
        
        output.fromDateString
            .drive(fromDateTextField.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.toDate
            .drive(onNext: { (date) in
                self.toPicker.date = date
            }).addDisposableTo(rx_disposeBag)
        
        output.toDateMax
            .drive(onNext: { (date) in
                self.toPicker.maximumDate = date
            }).addDisposableTo(rx_disposeBag)
        
        output.toDateString
            .drive(toDateTextField.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.apply
            .drive()
            .addDisposableTo(rx_disposeBag)
    }
}
