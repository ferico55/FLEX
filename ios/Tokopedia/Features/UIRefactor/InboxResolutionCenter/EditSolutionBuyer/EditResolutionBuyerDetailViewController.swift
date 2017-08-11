//
//  EditResolutionBuyerDetailViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@IBDesignable
@objc(EditResolutionBuyerDetailViewController) class EditResolutionBuyerDetailViewController: UIViewController {
    @IBOutlet weak var maxRefundLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var uploadScrollView: UIScrollView!

    @IBOutlet weak var refundTextField: UITextField!
    @IBOutlet weak var maxInvoicedescriptionLabel: UILabel!
    @IBOutlet weak var solutionLabel: UILabel!
    @IBOutlet var uploadImageCell: UITableViewCell!
    @IBOutlet var solutionCell: UITableViewCell!
    @IBOutlet var refundViewHeight: NSLayoutConstraint!
    @IBOutlet weak var invoiceButton: UIButton!
    
    @IBOutlet var sellerButton: UIButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet var deleteButtons: [UIButton]!
    @IBOutlet var imageButtons: [UIButton]!
    @IBOutlet weak var reasonTextView: TKPDTextView!
    fileprivate var firstResponderIndexPath : IndexPath?
    
    @IBOutlet weak var uploadImageContentView: UIView!
    @IBOutlet var reasonCell: UITableViewCell!
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var alertProgress : UIAlertView = UIAlertView()
    fileprivate var doneButton : UIBarButtonItem = UIBarButtonItem()
    fileprivate var loadingView : LoadingView = LoadingView()
    
    var postObject : ReplayConversationPostData = ReplayConversationPostData()
    var resolutionData : EditResolutionFormData = EditResolutionFormData()
    fileprivate var successEdit : ((_ solutionLast: ResolutionLast, _ conversationLast: ResolutionConversation, _ replyEnable: Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Komplain"
        
        doneButton = UIBarButtonItem(title: "Selesai", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditResolutionBuyerDetailViewController.submit))
        self.navigationItem.rightBarButtonItem = doneButton
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditResolutionBuyerDetailViewController.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditResolutionBuyerDetailViewController.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
        
        deleteButtons = NSArray.sortViewsWithTag(in: deleteButtons) as! [UIButton]
        imageButtons = NSArray.sortViewsWithTag(in: imageButtons) as! [UIButton]
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UploadImageCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SolutionCellIdentifier")
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditResolutionBuyerDetailViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.tableHeaderView = headerView
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        self .adjustUIForm(resolutionData.form)
        self.fetchPossibleSolutions()
        
        self.adjustAlertProgressAppearance()
        self.setAppearanceLoadingView()

        reasonTextView.placeholder = "Tulis alasan Anda disini"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsManager.trackScreenName("Resolution Center Buyer Edit Solution Page")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func setAppearanceLoadingView(){
        loadingView.delegate = self
        self.view .addSubview(loadingView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        uploadScrollView.contentSize = uploadImageContentView.frame.size
    }
    
    @objc fileprivate func refresh() {
        self.fetchPossibleSolutions()
    }
    
    @IBAction func onTapDeleteImageButton(_ sender: UIButton) {
        postObject.selectedAssets.remove(at: sender.tag)
        self.adjustUISelectedImage()
    }
    
    @IBAction func onTapUploadImageButton(_ sender: AnyObject) {
        self.navigateToPhotoPicker()
    }
    
    @IBAction func onTapInvoiceButton(_ sender: UIButton) {
        NavigateViewController.navigateToInvoice(from: self, withInvoiceURL: resolutionData.form.resolution_order.order_pdf_url)

    }
    
    @IBAction func onTapSellerButton(_ sender: UIButton) {
//        NavigateViewController.navigateToShopFromViewController(self, withShopID: resolutionData.form.resolution_order.sh)
    }
    
    fileprivate func adjustUIForm(_ form: EditResolutionForm) {
        invoiceButton.setTitle(form.resolution_order.order_invoice_ref_num, for: .normal)
        sellerButton.setTitle("Pembelian dari \(form.resolution_order.order_shop_name)", for: .normal)
        adjustUISelectedImage()
    }
    
    fileprivate func adjustUISolution(_ solution: EditSolution){
        solutionLabel.text = solution.solution_text
        maxRefundLabel.text = solution.max_refund_idr
        maxInvoicedescriptionLabel.text = solution.refund_text_desc
        self.postObject.maxRefundAmountIDR = solution.max_refund_idr
        self.postObject.maxRefundAmount = solution.max_refund
        
        if solution.show_refund_box == "0"{
            refundViewHeight.constant = 0
        } else {
            refundViewHeight.constant = 128
        }
    }
    
    func didSuccessEdit(_ success:@escaping ((_ solutionLast: ResolutionLast, _ conversationLast: ResolutionConversation, _ replyEnable: Bool)->Void)){
        self.successEdit = success
    }
    
    @objc fileprivate func submit(){
        
        let validation : ResolutionValidation = ResolutionValidation()
        if !validation.isValidSubmitEditResolution(self.postObjectEditSolution()) {
            return;
        }
        
        alertProgress.show()
        RequestResolution.fetchReplayConversation(self.postObjectEditSolution(), onSuccess: { (data) in
            StickyAlertView.showSuccessMessage(["Anda berhasil mengubah solusi."])
            self.alertProgress.dismiss(withClickedButtonIndex: 0, animated: true)
            self.successEdit?(data.solution_last, data.conversation_last[0] , true)
            
        }) {
            
            self.alertProgress.dismiss(withClickedButtonIndex: 0, animated: true)
        }
    }
    
    fileprivate func postObjectEditSolution()->ReplayConversationPostData{
        postObject.refundAmount = refundTextField.text!.replacingOccurrences(of: ".", with: "")
        postObject.editSolution = "1"
        postObject.replyMessage = reasonTextView.text
        return postObject
    }
    
    fileprivate func adjustAlertProgressAppearance(){
        alertProgress = UIAlertView(title: nil, message: "Please wait...", delegate: nil, cancelButtonTitle: nil);
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alertProgress.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
    }
    
    
    fileprivate func navigateToPhotoPicker(){
        
        TKPImagePickerController.showImagePicker(self,
                                              assetType: .allPhotos,
                                              allowMultipleSelect: true,
                                              showCancel: true,
                                              showCamera: true,
                                              maxSelected: 5,
                                              selectedAssets: self.postObject.selectedAssets as NSArray?
        ) { [unowned self] (assets) in
            self.postObject.selectedAssets = assets
            self.adjustUISelectedImage()
        }
    }
    
    fileprivate func adjustUISelectedImage(){
        imageButtons.forEach {
            $0.isHidden = true
            $0.setBackgroundImage(UIImage(named: "icon_upload_image.png"), for: UIControlState())
        }
        
        deleteButtons.forEach{ $0.isHidden = true }
        
        for (index,asset) in postObject.selectedAssets.enumerated() {
            if index == imageButtons.count {
                postObject.selectedAssets.removeLast()
                break
            }
            imageButtons[index].isHidden = false
            deleteButtons[index].isHidden = false
            
            asset.fetchImageWithSize(self.imageButtons[index].frame.size.toPixel(), completeBlock: { [weak self] (image, info) in
                guard let `self` = self else {return}
                self.imageButtons[index].setBackgroundImage(image, for: .normal)
            })
        }
        
        if (postObject.selectedAssets.count<imageButtons.count) {
            let uploadedButton = imageButtons[postObject.selectedAssets.count]
            uploadedButton.isHidden = false
            
            uploadScrollView.contentSize = CGSize(width: uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, height: 0);
            
        }
    }
    @IBAction func onTapSolution(_ sender: AnyObject) {
        let controller : GeneralTableViewController = GeneralTableViewController()
        controller.objects = resolutionData.form.resolution_solution_list.map{$0.solution_text}
        controller.selectedObject = postObject.selectedSolution.solution_text
        controller.delegate = self
        controller.title = "Pilih Solusi"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func postObjectPossibleSolution() ->ResolutionCenterCreatePOSTRequest{
        let object : ResolutionCenterCreatePOSTRequest = ResolutionCenterCreatePOSTRequest()
        object.category_trouble_id = postObject.category_trouble_id
        object.order_id = resolutionData.form.resolution_order.order_id
        
        postObject.postObjectProducts.removeAll()
        postObject.selectedProducts.forEach {
            let product :ResolutionCenterCreatePOSTProduct = ResolutionCenterCreatePOSTProduct()
            product.product_id = $0.pt_product_id
            product.trouble_id = $0.pt_trouble_id
            product.quantity = $0.pt_last_selected_quantity
            product.order_dtl_id = $0.pt_order_dtl_id
            product.remark = $0.pt_solution_remark
            object.product_list.add(product)
            postObject.postObjectProducts.append(product)
        }
        return object
    }
    
    fileprivate func fetchPossibleSolutions(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData .fetchPossibleSolution(withPossibleTroubleObject: self.postObjectPossibleSolution(), troubleId: postObject.troubleType, success: { (listSolutions) in
            
            self.isFinishRequest(true)
            
            self.resolutionData.form.resolution_solution_list = listSolutions ?? []
            
            if self.resolutionData.form.resolution_solution_list.count > 0 {
                self.adjustSelectedSolution()
            }
        
            self.tableView.tableFooterView = nil
            self.doneButton.isEnabled = true

            self.tableView.reloadData()
        
            
            }) { (error) in
                
                self.doneButton.isEnabled = false
                self.tableView.tableFooterView = self.loadingView.view
                self.isFinishRequest(true)
        }
    }
    
    fileprivate func adjustSelectedSolution(){
        if Int(self.postObject.selectedSolution.solution_id) == 0 || self.postObject.selectedSolution.solution_id == "" {
            self.postObject.selectedSolution = self.resolutionData.form.resolution_solution_list.first!
            self .adjustUISolution(self.postObject.selectedSolution)
        } else {
            self.resolutionData.form.resolution_solution_list.forEach{
                if  Int($0.solution_id) == Int(self.resolutionData.form.resolution_last.last_solution) {
                    self.postObject.selectedSolution = $0
                    self .adjustUISolution($0)
                }
            }
        }
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

extension EditResolutionBuyerDetailViewController : LoadingViewDelegate{
    //MARK: LoadingViewDelegate
    
    func pressRetryButton() {
        self.refresh()
    }
}

extension EditResolutionBuyerDetailViewController : UITextViewDelegate {
    //MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        reasonTextView.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.firstResponderIndexPath = IndexPath(row: 0, section: 2)
        return true
    }
}

extension EditResolutionBuyerDetailViewController : UITextFieldDelegate{
    //MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        NumberFormatter.setTextFieldFormatterString(textField, string: string)
        return true
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.firstResponderIndexPath = IndexPath(row: 0, section: 1)
        return true
    }
}

extension NumberFormatter {
    class func setTextFieldFormatterString(_ textField: UITextField, string: String){
        let formatter : NumberFormatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.secondaryGroupingSize = 3
        
        if string.characters.count == 0 {
            formatter.groupingSeparator = "."
            formatter.groupingSize = 4
            let numString = textField.text!.replacingOccurrences(of: ".", with: "")
            let numDouble = Double(numString) ?? 0.0
            let str = formatter.string(from: NSNumber(value: numDouble as Double))
            textField.text = str
        } else {
            formatter.groupingSeparator = "."
            formatter.groupingSize = 2
            formatter.usesGroupingSeparator = true
            if textField.text != "" {
                let numString = textField.text!.replacingOccurrences(of: ".", with: "")
                let numDouble = Double(numString) ?? 0.0
                let str = formatter.string(from: NSNumber(value: numDouble as Double))
                textField.text = str
            }
        }
    }
}

extension EditResolutionBuyerDetailViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    @nonobjc func didSelectObject(_ object: AnyObject!) {
        for solution in resolutionData.form.resolution_solution_list where solution.solution_text == object as! String {
            postObject.selectedSolution = solution
            self.adjustUISolution(solution)
            tableView.reloadData()
        }
    }
    
}


extension EditResolutionBuyerDetailViewController : UITableViewDelegate {
    //MARK: UITableViewDelegate
}


extension EditResolutionBuyerDetailViewController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.resolutionData.form.resolution_solution_list.count == 0 {
            return 0
        }
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            return self.solutionCell
        case 2:
            return self.reasonCell
        default:
            return self.uploadImageCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Lampirkan Foto Bukti"
        case 1:
            return "Solusi Yang diinginkan"
        case 2:
            return "Alasan ubah komplain"
        default:
            return ""
        }
    }
}
