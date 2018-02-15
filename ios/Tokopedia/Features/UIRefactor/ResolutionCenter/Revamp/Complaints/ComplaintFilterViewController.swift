//
//  ComplaintsFilterViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 06/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import CFAlertViewController
import UIKit

internal protocol ComplaintFilterViewDelegate: class {
    func complaintFilterViewController(_ complaintFilterViewController: ComplaintFilterViewController, didApplyFilter filter: [ComplaintQuickFilterData], withDateFilter startTime: Date?, endTime: Date?)
}

internal class ComplaintFilterViewController: UIViewController {
    // MARK: outlets
    @IBOutlet internal weak var tableView: UITableView!
    @IBOutlet internal weak var viewBtnDone: UIView!
    
    // MARK: variables
    internal weak var delegate: ComplaintFilterViewDelegate?
    internal var data: [ComplaintQuickFilterData] = []
    internal var showDatePicker = false
    internal var startTime: Date?
    internal var endTime: Date?
    
    fileprivate let cellReuseIdentifier = "ComplaintFilterTableViewCell"
    fileprivate let dateCellReuseIdentifier = "ComplaintFilterDateTableViewCell"
    
    fileprivate let datePicker = UIDatePicker(frame: .zero)

    internal override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close_grey"), style: .done, target: self, action: #selector(btnCloseDidTapped(_:))), animated: false)
        
        self.navigationItem.title = "Filter"
        
        let btnReset = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        btnReset.tintColor = .tpGreen()
        btnReset.setTitleTextAttributes([NSFontAttributeName : UIFont.mediumSystemFont(ofSize: 14)], for: .normal)
        btnReset.setTitleTextAttributes([NSFontAttributeName : UIFont.mediumSystemFont(ofSize: 14)], for: .highlighted)
        self.navigationItem.rightBarButtonItem = btnReset
        
        tableView.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(UINib(nibName: dateCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: dateCellReuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        viewBtnDone.layer.shadowColor = UIColor.tpBorder().cgColor
        viewBtnDone.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        viewBtnDone.layer.shadowRadius = 2.0
        viewBtnDone.layer.shadowOpacity = 1.0
        viewBtnDone.layer.masksToBounds = false
        
        datePicker.datePickerMode = .date
    }

    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func reset() {
        for i in 0 ..< data.count {
            data[i].isSelected = false
        }
        startTime = nil
        endTime = nil
        
        tableView.reloadData()
    }
    
    // MARK: actions
    @IBAction private func btnCloseDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func btnDoneDidTapped(_ sender: Any) {
        self.delegate?.complaintFilterViewController(self, didApplyFilter: data, withDateFilter: startTime, endTime: endTime)
        dismiss(animated: true, completion: nil)
    }
}

extension ComplaintFilterViewController: UITableViewDelegate {
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count + (showDatePicker ? 2 : 0)
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < data.count {
            data[indexPath.row].isSelected = !data[indexPath.row].isSelected
            tableView.reloadData()
        }
        else {
            datePicker.minimumDate = nil
            if indexPath.row == data.count {
                // start date
                datePicker.date = startTime ?? Date()
            }
            else {
                // end date
                if let startTime = startTime {
                    datePicker.minimumDate = startTime
                }
                datePicker.date = endTime ?? Date()
            }
            
            let alert = CFAlertViewController(title: nil, titleColor: nil, message: nil, messageColor: nil, textAlignment: .justified, preferredStyle: .alert, headerView: datePicker, footerView: nil, didDismissAlertHandler: nil)
            let doneAction = CFAlertAction(title: "Pilih", style: .Default, alignment: .justified, backgroundColor: nil, textColor: nil, handler: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                if indexPath.row == self.data.count {
                    self.startTime = self.datePicker.date
                    if self.endTime == nil {
                        self.endTime = Date()
                    }
                    else if self.endTime! < self.startTime! {
                        self.endTime = self.startTime
                    }
                }
                else {
                    self.endTime = self.datePicker.date
                    if self.startTime == nil {
                        self.startTime = self.endTime
                    }
                }
                
                self.tableView.reloadData()
            })
            alert.addAction(doneAction)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ComplaintFilterViewController: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row < data.count {
            let cell = tableView.dequeueReusableCellOrDie(withIdentifier: cellReuseIdentifier, for: indexPath) as ComplaintFilterTableViewCell
            
            cell.lblTitle.text = data[row].fullTitle
            cell.isSelected = data[row].isSelected
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellOrDie(withIdentifier: dateCellReuseIdentifier, for: indexPath) as ComplaintFilterDateTableViewCell
            
            if row == data.count {
                // start date
                cell.lblDateIdentifier.text = "Tanggal Awal"
                if let startTime = startTime {
                    cell.lblDate.text = startTime.string("dd/MM/yyyy")
                }
                else {
                    cell.lblDate.text = "-"
                }
            }
            else {
                // end date
                cell.lblDateIdentifier.text = "Tanggal Akhir"
                if let endTime = endTime {
                    cell.lblDate.text = endTime.string("dd/MM/yyyy")
                }
                else {
                    cell.lblDate.text = "-"
                }
            }
            
            return cell
        }
    }
}
