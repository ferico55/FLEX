//
//  EditSolutionBuyerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import DownPicker

@IBDesignable
@objc(EditSolutionBuyerViewController) class EditSolutionBuyerViewController: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var detailProblemPicker: UIDownPicker!
    var detailProblemDownPicker : DownPicker!
    @IBOutlet weak var invoiceButton: UIButton!

    @IBOutlet weak var sellerButton: UIButton!
    @IBOutlet var detailProblemCell: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    fileprivate var refreshControl: UIRefreshControl!
    @IBOutlet weak var problemLabel: UILabel!
    
    fileprivate var resolutionData : EditResolutionFormData = EditResolutionFormData()
    fileprivate var postObject : ReplayConversationPostData = ReplayConversationPostData()
    fileprivate var allProducts : [ProductTrouble] = []
    fileprivate var firstResponderIndexPath : IndexPath?
    fileprivate var alertProgress : UIAlertView = UIAlertView()
    fileprivate var loadingView : LoadingView = LoadingView()
    fileprivate var nextButton : UIBarButtonItem = UIBarButtonItem()
    @IBOutlet var problemCell: UITableViewCell!
    
    fileprivate var successEdit : ((_ solutionLast: ResolutionLast, _ conversationLast: ResolutionConversation, _ replyEnable: Bool) -> Void)?
    
    var resolutionID : String = ""
    var isGetProduct : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Komplain"
        
        nextButton = UIBarButtonItem(title: "Lanjut", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditSolutionBuyerViewController.nextPage))
        self.navigationItem.rightBarButtonItem = nextButton
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditSolutionBuyerViewController.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditSolutionBuyerViewController.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
        
        self.tableView.register(UINib(nibName: "EditProductTroubleCell", bundle: nil), forCellReuseIdentifier: "EditProductTroubleCellIdentifier")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProblemCellIdentifier")

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditSolutionBuyerViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        tableView.allowsMultipleSelection = true
        tableView.allowsSelectionDuringEditing = true
        
        detailProblemDownPicker = DownPicker(textField: detailProblemPicker)
        detailProblemDownPicker.shouldDisplayCancelButton = false
        
        self.requestFormEdit()
        
        self .setAppearanceLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Resolution Center Buyer Edit Problem Page")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setAppearanceLoadingView(){
        loadingView.delegate = self
        self.view .addSubview(loadingView)
    }
    
    @IBAction func onTapInvoiceButton(_ sender: UIButton) {
        NavigateViewController.navigateToInvoice(from: self, withInvoiceURL: resolutionData.form.resolution_order.order_pdf_url)
        
    }
    
    @IBAction func onTapSellerButton(_ sender: UIButton) {
        //        NavigateViewController.navigateToShopFromViewController(self, withShopID: resolutionData.form.resolution_order.sh)
    }
    
    @objc fileprivate func nextPage(){
        
        view.endEditing(true)
        
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
        controller.didSuccessEdit { [weak self](solutionLast, conversationLast, replyEnable) in
            self?.successEdit?(solutionLast, conversationLast , replyEnable)
        }
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    func didSuccessEdit(_ success:@escaping ((_ solutionLast: ResolutionLast, _ conversationLast: ResolutionConversation, _ replyEnable: Bool)->Void)){
        self.successEdit = success
    }

    @objc fileprivate func refresh(){
        self.requestFormEdit()
    }
    
    fileprivate func requestFormEdit(){
        self.isFinishRequest(false)
        RequestResolutionData .fetchformEditResolutionID(resolutionID, isGetProduct: isGetProduct, onSuccess: { (data) in
            
            self.adjustResolutionData(data!)
            self.fetchAllProducts()
            self.tableView.tableFooterView = nil
            self.nextButton.isEnabled = true
            self.isFinishRequest(true)
            
            }) { (error) in
                
            self.nextButton.isEnabled = false
            self.tableView.tableFooterView = self.loadingView.view
            self.isFinishRequest(true)
        }
    }
    
    fileprivate func adjustResolutionData(_ data: EditResolutionFormData){
        self.resolutionData = data
        self.tableView.tableHeaderView = headerView
        self.adjustPostObject()
        self.adjustTroubleList()
        self.setHeaderAppearanceData(resolutionData)
        self.tableView.reloadData()

    }
    
    fileprivate func adjustPostObject(){
        if resolutionData.form.resolution_last.last_flag_received.boolValue == isGetProduct {
            self.postObject.troubleType = resolutionData.form.resolution_last.last_trouble_type
            self.postObject.replyMessage = resolutionData.form.resolution_last.last_category_trouble_string
            self.postObject.troubleName = resolutionData.form.resolution_last.last_category_trouble_string
            self.postObject.selectedProducts = resolutionData.form.resolution_last.last_product_trouble
            self.postObject.category_trouble_id = resolutionData.form.resolution_last.last_category_trouble_type
            self.postObject.category_trouble_text = resolutionData.form.resolution_last.last_category_trouble_string
            self.postObject.troubleName = resolutionData.form.resolution_last.last_trouble_string
        }
        
        self.postObject.resolutionID = resolutionData.form.resolution_last.last_resolution_id.stringValue
        if isGetProduct {
            self.postObject.flagReceived = "1"
        } else {
            self.postObject.flagReceived = "0"
        }
    }
    
    fileprivate func adjustTroubleList(){
        var listTrouble : [ResolutionCenterCreateTroubleList] = []
        resolutionData.list_ts.forEach { (listTroubleSolution) in
            if Int(listTroubleSolution.category_trouble_id) == Int(postObject.category_trouble_id){
                listTrouble.append(contentsOf: listTroubleSolution.trouble_list)
            }
        }
        self.resolutionData.form.resolution_trouble_list = listTrouble
        self.allProducts.forEach{ $0.pt_trouble_list = listTrouble}
        detailProblemDownPicker.setData(listTrouble.map{$0.trouble_text})
    }
    
    fileprivate func setHeaderAppearanceData(_ data: EditResolutionFormData){
        invoiceButton.setTitle(data.form.resolution_order.order_invoice_ref_num, for: .normal)
        sellerButton.setTitle("Pembelian dari \(data.form.resolution_order.order_shop_name)", for: .normal)
    }
    
    fileprivate func isFinishRequest(_ isFinishRequest: Bool){
        if isFinishRequest{
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
            self.refreshControl.endRefreshing()
        } else {
            tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
        }
    }
    
    fileprivate func fetchAllProducts(){
        self.isFinishRequest(false)

        RequestResolutionData.fetchAllProductsInTransaction(withOrderId: resolutionData.form.resolution_order.order_id, success: { (list) in
            
            self.allProducts = list!
            self.isFinishRequest(true)
            self.adjustAppearance()
            self.tableView.reloadData()
            
            }) { (error) in
            self.isFinishRequest(true)
        }
    }
    
    fileprivate func adjustAppearance(){
        detailProblemDownPicker.addTarget(self, action: #selector(EditSolutionBuyerViewController.troublePickerValueChanged(_:)), for: .valueChanged)
        
        resolutionData.form.resolution_last.last_product_trouble.forEach { (productTrouble) in
            self.allProducts.forEach({ (product) in
                if Int(product.pt_product_id) == Int(productTrouble.pt_product_id){
                    product.pt_selected = true
                    self.updateProduct(product, productTrouble: productTrouble)
                }
            })
        }
        self.adjustTroubleList()
    }
    
    fileprivate func updateProduct(_ product: ProductTrouble, productTrouble: ProductTrouble){
        product.pt_solution_remark = productTrouble.pt_solution_remark
        product.pt_show_input_quantity = productTrouble.pt_show_input_quantity
        product.pt_trouble_id = productTrouble.pt_trouble_id
        product.pt_trouble_name = productTrouble.pt_trouble_name
        product.pt_last_selected_quantity = productTrouble.pt_quantity
    }
    
    @objc fileprivate func troublePickerValueChanged(_ sender: DownPicker){
        postObject.troubleType = resolutionData.form.resolution_trouble_list[sender.selectedIndex].trouble_id
        postObject.troubleName = resolutionData.form.resolution_trouble_list[sender.selectedIndex].trouble_text
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification){
        
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            tableView.contentInset = contentInset
        }
        
        if firstResponderIndexPath != nil {
            tableView.scrollToRow(at: firstResponderIndexPath!, at: .bottom, animated: true)
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification){
        UIView.animate(withDuration: 0.3, animations: { [weak self] _ in
            if self?.firstResponderIndexPath != nil {
                self?.tableView.contentInset = UIEdgeInsets.zero
            }
        }) 
    }
}

extension EditSolutionBuyerViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    private func didSelectObject(_ object: AnyObject!) {
        for trouble in resolutionData.list_ts where trouble.category_trouble_text == object as! String {
            postObject.category_trouble_id = trouble.category_trouble_id
            postObject.category_trouble_text = trouble.category_trouble_text
            if postObject.category_trouble_id == "1" {
                // remove trouble type (product related category trouble)
                self.postObject.troubleType = ""
                self.postObject.troubleName = ""
                self.postObject.solution = ""
                self.postObject.selectedSolution = EditSolution()
            }else {
                // remove selected products (non product related category trouble)
                self.postObject.selectedProducts = []
                self.postObject.postObjectProducts = []
                allProducts.forEach{$0.pt_selected = false}
                self.postObject.solution = ""
                self.postObject.selectedSolution = EditSolution()
            }
            self.adjustTroubleList()
            tableView.reloadData()
        }
    }
}

extension EditSolutionBuyerViewController : UITextViewDelegate {
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.firstResponderIndexPath = IndexPath(row: 0, section: 2)
        return true
    }
}

extension EditSolutionBuyerViewController : UITextFieldDelegate{
    //MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.firstResponderIndexPath = IndexPath(row: 0, section: 1)
        return true
    }
}

extension EditSolutionBuyerViewController : LoadingViewDelegate{
    //MARK: LoadingViewDelegate
    
    func pressRetryButton() {
        self.refresh()
    }
}

extension EditSolutionBuyerViewController : UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && Int(postObject.category_trouble_id) == 1 {
            if allProducts[indexPath.row].pt_selected {
                return 217.0
            } else {
                return 64.0
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let controller : GeneralTableViewController = GeneralTableViewController()
            controller.objects = resolutionData.list_ts.map{$0.category_trouble_text}
            controller.delegate = self
            controller.selectedObject = postObject.category_trouble_text
            controller.title = "Pilih Masalah"
            self.navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.section == 1 {
            allProducts[indexPath.row].pt_selected = !allProducts[indexPath.row].pt_selected
            //set last selected quantity to max product count
            allProducts[indexPath.row].pt_last_selected_quantity = allProducts[indexPath.row].pt_quantity
            tableView.reloadData()
        }
    }
    
}

extension EditSolutionBuyerViewController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.resolutionData.form.resolution_last.last_resolution_id == nil {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            if Int(postObject.category_trouble_id) == 1 {
                return allProducts.count
            } else if Int(postObject.category_trouble_id) == 2 {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if postObject.category_trouble_text == "" {
                problemLabel.text = "Pilih"
            } else {
                problemLabel.text = postObject.category_trouble_text
            }
            return self.problemCell
        default:
            if Int(postObject.category_trouble_id) == 1 {
            
                let cell:EditProductTroubleCell = tableView.dequeueReusableCell(withIdentifier: "EditProductTroubleCellIdentifier")! as! EditProductTroubleCell
                cell.setViewModel(allProducts[indexPath.row].buyerEditViewModel, product: allProducts[indexPath.row])
                cell.contentView.backgroundColor = UIColor.clear
                cell.startEditTextView({ [weak self] _ in
                    self!.firstResponderIndexPath = indexPath
                })
                return cell
                
            } else {
                detailProblemPicker.text = postObject.troubleName
                return detailProblemCell
            
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Kategori Masalah yang diterima"
        case 1:
            if Int(postObject.category_trouble_id) == 1 {
                return "Pilih produk yang bermasalah"
            } else if Int(postObject.category_trouble_id) == 2 {
                return "Pilih Detail Masalah"
            } else {
                return ""
            }
        default:
            return ""
        }
    }
}
