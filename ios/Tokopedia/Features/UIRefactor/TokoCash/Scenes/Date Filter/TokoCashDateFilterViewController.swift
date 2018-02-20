//
//  TokoCashDateFilterViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import HMSegmentedControl
import RxCocoa
import RxSwift
import UIKit

public class TokoCashDateFilterViewController: UIViewController {
    
    @IBOutlet weak fileprivate var segmentControl: HMSegmentedControl!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var fromDateTextField: UITextField!
    @IBOutlet weak private var toDateTextField: UITextField!
    @IBOutlet weak private var applyButton: UIButton!
    
    private let fromPicker = UIDatePicker()
    private let toPicker = UIDatePicker()
    fileprivate let isDateRange = Variable(true)

    private let resetBarButtonItem =  UIBarButtonItem(title: "Reset", style: .plain, target: self, action: nil)
    public let dateFilter = PublishSubject<DateFilter>()
    
    // view model
    public var viewModel: TokoCashDateFilterViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rentang Tanggal"
        
        resetBarButtonItem.tintColor = #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
        navigationItem.rightBarButtonItem = resetBarButtonItem
        
        configureSection()
        configureTableView()
        configureStartPicker()
        configureToPicker()
        
        bindViewModel()
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
        
        output.items.drive(tableView.rx.items(cellIdentifier: TokoCashDateRangeItemTableViewCell.reuseID, cellType: TokoCashDateRangeItemTableViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
            }.addDisposableTo(rx_disposeBag)
        
        output.fromDate
            .drive(onNext: { date in
                self.fromPicker.date = date
            }).addDisposableTo(rx_disposeBag)
        
        output.fromDateMax
            .drive(onNext: { date in
                self.fromPicker.maximumDate = date
            }).addDisposableTo(rx_disposeBag)
        
        output.fromDateString
            .drive(fromDateTextField.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.toDate
            .drive(onNext: { date in
                self.toPicker.date = date
            }).addDisposableTo(rx_disposeBag)
        
        output.toDateMax
            .drive(onNext: { date in
                self.toPicker.maximumDate = date
            }).addDisposableTo(rx_disposeBag)
        
        output.toDateString
            .drive(toDateTextField.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.apply
            .drive(onNext: { dateFilter in
                self.dateFilter.onNext(dateFilter)
            }).addDisposableTo(rx_disposeBag)
    }
    
    private func configureSection() {
        segmentControl?.sectionTitles = ["Pilih Rentang Waktu", "Pilih Tanggal"]
        segmentControl?.segmentWidthStyle = .fixed
        segmentControl?.selectionIndicatorBoxOpacity = 0
        segmentControl?.selectionStyle = .box
        segmentControl?.selectedSegmentIndex = HMSegmentedControlNoSegment
        segmentControl?.type = .text
        segmentControl?.selectionIndicatorLocation = .down
        segmentControl?.selectionIndicatorHeight = 3
        segmentControl?.selectedSegmentIndex = 0
        segmentControl?.selectedTitleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1), NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        segmentControl?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3799999952)
            , NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
        segmentControl?.selectionIndicatorColor = #colorLiteral(red: 0, green: 0.7217311263, blue: 0.2077963948, alpha: 1)
        
        let viewWidth = UIScreen.main.bounds.size.width
        weak var weakSelf = self
        segmentControl.indexChangeBlock = { index in
            weakSelf?.scrollView.scrollRectToVisible(CGRect(x: viewWidth * CGFloat(index), y: 0, width: viewWidth, height: 200), animated: true)
            self.isDateRange.value = index == 0 ? true : false
        }
    }
    
    private func configureTableView() {
        let nib = UINib(nibName: "TokoCashDateRangeItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TokoCashDateRangeItemTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    private func configureStartPicker() {
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
    
    private func configureToPicker() {
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
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
}

extension TokoCashDateFilterViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let page = scrollView.contentOffset.x / pageWidth
        segmentControl.setSelectedSegmentIndex(UInt(page), animated: true)
        isDateRange.value = page == 0 ? true : false
    }
}
