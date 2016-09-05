//
//  EditSolutionBuyerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@IBDesignable
@objc(EditSolutionBuyerViewController) class EditSolutionBuyerViewController: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var detailProblemPicker: UIDownPicker!
    var detailProblemDownPicker : DownPicker!
    @IBOutlet weak var invoiceLabel: UILabel!

    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet var detailProblemCell: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    @IBOutlet weak var problemLabel: UILabel!
    
    private var resolutionData : EditResolutionFormData = EditResolutionFormData()
    private var postObject : ReplayConversationPostData = ReplayConversationPostData()
    private var allProducts : [ProductTrouble] = []
    private var firstResponderIndexPath : NSIndexPath?
    private var alertProgress : UIAlertView = UIAlertView()
    @IBOutlet var problemCell: UITableViewCell!

    
    var resolutionID : String = ""
    var isGetProduct : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Komplain"
        
        let button : UIBarButtonItem = UIBarButtonItem(title: "Lanjut", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditSolutionBuyerViewController.nextPage))
        self.navigationItem.rightBarButtonItem = button
        
        self.tableView.registerNib(UINib.init(nibName: "EditProductTroubleCell", bundle: nil), forCellReuseIdentifier: "EditProductTroubleCellIdentifier")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ProblemCellIdentifier")

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditSolutionBuyerViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.tableHeaderView = headerView
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        tableView.allowsMultipleSelection = true
        tableView.allowsSelectionDuringEditing = true
        
        detailProblemDownPicker = DownPicker.init(textField: detailProblemPicker)
        detailProblemDownPicker.shouldDisplayCancelButton = false
        
        self.requestFormEdit()
    }
    
    @objc private func nextPage(){
        
        postObject.selectedProducts.removeAll()
        allProducts.forEach{
            if $0.pt_selected == true {
                postObject.selectedProducts.append($0)
            }
        }
        
        let validation : ResolutionValidation = ResolutionValidation()
        if !validation.isValidInputProblem(postObject) {
            return;
        }
        let controller : EditResolutionBuyerDetailViewController = EditResolutionBuyerDetailViewController()
        controller.postObject = postObject
        controller.resolutionData = resolutionData
        
        self.navigationController!.pushViewController(controller, animated: true)
    }

    @objc private func refresh(){
        self.requestFormEdit()
    }
    
    private func requestFormEdit(){
        self.isFinishRequest(false)
        RequestResolutionData .fetchformEditResolutionID(resolutionID, isGetProduct: isGetProduct, onSuccess: { (data) in
            
            self.adjustResolutionData(data)
            self.fetchAllProducts()
            
            self.isFinishRequest(true)
            
            }) { (error) in
            
            self.isFinishRequest(true)
        }
    }
    
    private func adjustResolutionData(data: EditResolutionFormData){
        self.resolutionData = data
        self.adjustPostObject()
        self.adjustTroubleList()
        self.tableView.reloadData()

    }
    
    private func adjustPostObject(){
        self.postObject.troubleType = resolutionData.form.resolution_last.last_trouble_type
        self.postObject.replyMessage = resolutionData.form.resolution_last.last_category_trouble_string
        self.postObject.troubleName = resolutionData.form.resolution_last.last_category_trouble_string
        self.postObject.selectedProducts = resolutionData.form.resolution_last.last_product_trouble
        self.postObject.category_trouble_id = resolutionData.form.resolution_last.last_category_trouble_type
        self.postObject.category_trouble_text = resolutionData.form.resolution_last.last_category_trouble_string
        self.postObject.resolutionID = resolutionData.form.resolution_last.last_resolution_id.stringValue
        self.postObject.flagReceived = resolutionData.form.resolution_last.last_flag_received.stringValue
        self.postObject.troubleName = resolutionData.form.resolution_last.last_trouble_string
    }
    
    private func adjustTroubleList(){
        var listTrouble : [ResolutionCenterCreateTroubleList] = []
        resolutionData.list_ts.forEach { (listTroubleSolution) in
            if Int(listTroubleSolution.category_trouble_id) == Int(postObject.category_trouble_id){
                listTrouble.appendContentsOf(listTroubleSolution.trouble_list)
            }
        }
        self.resolutionData.form.resolution_trouble_list = listTrouble
        self.allProducts.forEach{ $0.pt_trouble_list = listTrouble}
        detailProblemDownPicker.setData(listTrouble.map{$0.trouble_text})
    }
    
    private func setHeaderAppearanceData(data: EditResolutionFormData){
        invoiceLabel.text = data.form.resolution_order.order_invoice_ref_num
        sellerLabel.text = "Pembelian dari \(data.form.resolution_order.order_shop_name)"
    }
    
    private func isFinishRequest(isFinishRequest: Bool){
        if isFinishRequest{
            self.tableView.setContentOffset(CGPointZero, animated: true)
            self.refreshControl.endRefreshing()
        } else {
            tableView.setContentOffset(CGPoint.init(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
        }
    }
    
    private func fetchAllProducts(){
        self.isFinishRequest(false)

        RequestResolutionData.fetchAllProductsInTransactionWithOrderId(resolutionData.form.resolution_order.order_id, success: { (list) in
            
            self.allProducts = list
            self.isFinishRequest(true)
            self.adjustAppearance()
            self.tableView.reloadData()
            
            }) { (error) in
                
            self.isFinishRequest(true)
        }
    }
    
    private func adjustAppearance(){
        self.setHeaderAppearanceData(resolutionData)
        
        detailProblemDownPicker.addTarget(self, action: #selector(EditSolutionBuyerViewController.troublePickerValueChanged(_:)), forControlEvents: .ValueChanged)
        
        resolutionData.form.resolution_last.last_product_trouble.forEach { (productTrouble) in
            self.allProducts.forEach({ (product) in
                if Int(product.pt_product_id) == Int(productTrouble.pt_product_id){
                    product.pt_selected = true
                    self.updateProduct(product, productTrouble: productTrouble)
                }
            })
        }
    }
    
    private func updateProduct(product: ProductTrouble, productTrouble: ProductTrouble){
        product.pt_solution_remark = productTrouble.pt_solution_remark
        product.pt_show_input_quantity = productTrouble.pt_show_input_quantity
        product.pt_trouble_id = productTrouble.pt_trouble_id
        product.pt_trouble_name = productTrouble.pt_trouble_name
    }
    
    @objc private func troublePickerValueChanged(sender: DownPicker){
        postObject.troubleType = resolutionData.form.resolution_trouble_list[sender.selectedIndex].trouble_id
    }
}

extension EditSolutionBuyerViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    func didSelectObject(object: AnyObject!) {
        for trouble in resolutionData.list_ts where trouble.category_trouble_text == object as! String {
            postObject.category_trouble_id = trouble.category_trouble_id
            postObject.category_trouble_text = trouble.category_trouble_text
            if postObject.category_trouble_id == "1" {
                // remove trouble type (product related category trouble)
                self.postObject.troubleType = ""
                self.postObject.troubleName = ""
            }else {
                // remove selected products (non product related category trouble)
                self.postObject.selectedProducts = []
            }
            self.adjustTroubleList()
            tableView.reloadData()
        }
    }
}

extension EditSolutionBuyerViewController : UITextViewDelegate {
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 2)
        return true
    }
}

extension EditSolutionBuyerViewController : UITextFieldDelegate{
    //MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 1)
        return true
    }
}

extension EditSolutionBuyerViewController : UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && Int(postObject.category_trouble_id) == 1 {
            if allProducts[indexPath.row].pt_selected {
                return 217.0
            } else {
                return 64.0
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let controller : GeneralTableViewController = GeneralTableViewController()
            controller.objects = resolutionData.list_ts.map{$0.category_trouble_text}
            controller.delegate = self
            controller.selectedObject = postObject.category_trouble_text
            self.navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 1 {
            allProducts[indexPath.row].pt_selected = !allProducts[indexPath.row].pt_selected
            tableView.reloadData()
        }
    }
    
}

extension EditSolutionBuyerViewController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            if Int(postObject.category_trouble_id) == 1 {
                return allProducts.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            problemLabel.text = postObject.category_trouble_text
            return self.problemCell
        default:
            if Int(postObject.category_trouble_id) == 1 {
            
                let cell:EditProductTroubleCell = tableView.dequeueReusableCellWithIdentifier("EditProductTroubleCellIdentifier")! as! EditProductTroubleCell
                cell.setViewModel(allProducts[indexPath.row].buyerEditViewModel, product: allProducts[indexPath.row])
                cell.contentView.backgroundColor = UIColor.clearColor()
                return cell
                
            } else {
                detailProblemPicker.text = postObject.troubleName
                return detailProblemCell
            
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Kategori Masalah yang diterima"
        case 1:
            if Int(postObject.category_trouble_id) == 1 {
                return "Pilih produk yang bermasalah"
            } else {
                return "Pilih Detail Masalah"
            }
        default:
            return ""
        }
    }
}
