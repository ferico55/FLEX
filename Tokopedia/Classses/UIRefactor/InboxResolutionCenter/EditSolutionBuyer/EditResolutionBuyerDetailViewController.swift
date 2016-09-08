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
    private var firstResponderIndexPath : NSIndexPath?
    
    @IBOutlet weak var uploadImageContentView: UIView!
    @IBOutlet var reasonCell: UITableViewCell!
    private var refreshControl: UIRefreshControl!
    private var alertProgress : UIAlertView = UIAlertView()
    private var doneButton : UIBarButtonItem = UIBarButtonItem()
    private var loadingView : LoadingView = LoadingView()
    
    var postObject : ReplayConversationPostData = ReplayConversationPostData()
    var resolutionData : EditResolutionFormData = EditResolutionFormData()
    private var successEdit : ((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Komplain"
        
        doneButton = UIBarButtonItem(title: "Selesai", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditResolutionBuyerDetailViewController.submit))
        self.navigationItem.rightBarButtonItem = doneButton
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditResolutionBuyerDetailViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditResolutionBuyerDetailViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        deleteButtons = NSArray.sortViewsWithTagInArray(deleteButtons) as! [UIButton]
        imageButtons = NSArray.sortViewsWithTagInArray(imageButtons) as! [UIButton]
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "UploadImageCell")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SolutionCellIdentifier")
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditResolutionBuyerDetailViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.tableHeaderView = headerView
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44

        self .adjustUIForm(resolutionData.form)
        self.fetchPossibleSolutions()
        
        self.adjustAlertProgressAppearance()
        self.setAppearanceLoadingView()

        reasonTextView.placeholder = "Tulis alasan anda disini"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        TPAnalytics.trackScreenName("Resolution Center Buyer Edit Solution Page")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setAppearanceLoadingView(){
        loadingView.delegate = self
        self.view .addSubview(loadingView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        uploadScrollView.contentSize = uploadImageContentView.frame.size
    }
    
    @objc private func refresh() {
        self.fetchPossibleSolutions()
    }
    
    @IBAction func onTapDeleteImageButton(sender: UIButton) {
        postObject.selectedAssets.removeAtIndex(sender.tag)
        self.adjustUISelectedImage()
    }
    
    @IBAction func onTapUploadImageButton(sender: AnyObject) {
        self.navigateToPhotoPicker()
    }
    
    @IBAction func onTapInvoiceButton(sender: UIButton) {
        NavigateViewController.navigateToInvoiceFromViewController(self, withInvoiceURL: resolutionData.form.resolution_order.order_pdf_url)

    }
    
    @IBAction func onTapSellerButton(sender: UIButton) {
//        NavigateViewController.navigateToShopFromViewController(self, withShopID: resolutionData.form.resolution_order.sh)
    }
    
    private func adjustUIForm(form: EditResolutionForm) {
        invoiceButton .setTitle(form.resolution_order.order_invoice_ref_num, forState: .Normal)
        sellerButton.setTitle("Pembelian dari \(form.resolution_order.order_shop_name)", forState: .Normal)
        adjustUISelectedImage()
    }
    
    private func adjustUISolution(solution: EditSolution){
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
    
    func didSuccessEdit(success:((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool)->Void)){
        self.successEdit = success
    }
    
    @objc private func submit(){
        
        let validation : ResolutionValidation = ResolutionValidation()
        if !validation.isValidSubmitEditResolution(self.postObjectEditSolution()) {
            return;
        }
        
        alertProgress.show()
        RequestResolution.fetchReplayConversation(self.postObjectEditSolution(), onSuccess: { (data) in
            self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
            self.successEdit?(solutionLast: data.solution_last, conversationLast: data.conversation_last[0] , replyEnable: true)
            
        }) {
            
            self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
        }
    }
    
    private func postObjectEditSolution()->ReplayConversationPostData{
        postObject.refundAmount = refundTextField.text!.stringByReplacingOccurrencesOfString(".", withString: "")
        postObject.editSolution = "1"
        postObject.replyMessage = reasonTextView.text
        return postObject
    }
    
    private func adjustAlertProgressAppearance(){
        alertProgress = UIAlertView.init(title: nil, message: "Please wait...", delegate: nil, cancelButtonTitle: nil);
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        alertProgress.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
    }
    
    
    private func navigateToPhotoPicker(){
        
        ImagePickerController.showImagePicker(self,
                                              assetType: .allPhotos,
                                              allowMultipleSelect: true,
                                              showCancel: true,
                                              showCamera: true,
                                              maxSelected: 5,
                                              selectedAssets: self.postObject.selectedAssets
        ) { [unowned self] (assets) in
            self.postObject.selectedAssets = assets
            self.adjustUISelectedImage()
        }
    }
    
    private func adjustUISelectedImage(){
        imageButtons.forEach {
            $0.hidden = true
            $0.setBackgroundImage(UIImage.init(named: "icon_upload_image.png"), forState: .Normal)
        }
        
        deleteButtons.forEach{ $0.hidden = true }
        
        for (index,asset) in postObject.selectedAssets.enumerate() {
            if index == imageButtons.count {
                postObject.selectedAssets.removeLast()
                break
            }
            imageButtons[index].hidden = false
            deleteButtons[index].hidden = false
            imageButtons[index].setBackgroundImage(asset.thumbnailImage, forState: .Normal)
        }
        
        if (postObject.selectedAssets.count<imageButtons.count) {
            let uploadedButton = imageButtons[postObject.selectedAssets.count]
            uploadedButton.hidden = false
            
            uploadScrollView.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, 0);
            
        }
    }
    @IBAction func onTapSolution(sender: AnyObject) {
        let controller : GeneralTableViewController = GeneralTableViewController()
        controller.objects = resolutionData.form.resolution_solution_list.map{$0.solution_text}
        controller.selectedObject = postObject.selectedSolution.solution_text
        controller.delegate = self
        controller.title = "Pilih Solusi"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func postObjectPossibleSolution() ->ResolutionCenterCreatePOSTRequest{
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
            object.product_list.addObject(product)
            postObject.postObjectProducts.append(product)
        }
        return object
    }
    
    private func fetchPossibleSolutions(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData .fetchPossibleSolutionWithPossibleTroubleObject(self.postObjectPossibleSolution(), troubleId: postObject.troubleType, success: { (listSolutions) in
            
            self.isFinishRequest(true)
                
            self.resolutionData.form.resolution_solution_list = listSolutions
            
            if listSolutions.count > 0 {
                self.adjustSelectedSolution()
            }
            self.tableView.tableFooterView = nil
            self.doneButton.enabled = true

            self.tableView.reloadData()
            
            }) { (error) in
                
                self.doneButton.enabled = false
                self.tableView.tableFooterView = self.loadingView.view
                self.isFinishRequest(true)
        }
    }
    
    private func adjustSelectedSolution(){
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
    
    private func isFinishRequest(isFinishRequest: Bool){
        if isFinishRequest{
            self.tableView.setContentOffset(CGPointZero, animated: true)
            self.refreshControl.endRefreshing()
        } else {
            tableView.setContentOffset(CGPoint.init(x: 0, y: -self.refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInset = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            tableView.contentInset = contentInset
        }
        
        if firstResponderIndexPath != nil {
            tableView.scrollToRowAtIndexPath(firstResponderIndexPath!, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification){
        UIView.animateWithDuration(0.3) { [weak self] _ in
            if self?.firstResponderIndexPath != nil {
                self?.tableView.contentInset = UIEdgeInsetsZero
            }
        }
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
    func textViewDidChange(textView: UITextView) {
        reasonTextView.placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 2)
        return true
    }
}

extension EditResolutionBuyerDetailViewController : UITextFieldDelegate{
    //MARK: UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        NSNumberFormatter.setTextFieldFormatterString(textField, string: string)
        return true
    }

    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 1)
        return true
    }
}

extension NSNumberFormatter {
    class func setTextFieldFormatterString(textField: UITextField, string: String){
        let formatter : NSNumberFormatter = NSNumberFormatter.init()
        formatter.usesGroupingSeparator = true
        formatter.secondaryGroupingSize = 3
        
        if string.characters.count == 0 {
            formatter.groupingSeparator = "."
            formatter.groupingSize = 4
            let num : NSString = (textField.text! as NSString).stringByReplacingOccurrencesOfString(".", withString: "")
            let str = formatter.stringFromNumber(NSNumber.init(double: num.doubleValue))
            textField.text = str
        } else {
            formatter.groupingSeparator = "."
            formatter.groupingSize = 2
            formatter.usesGroupingSeparator = true
            var num : NSString = textField.text! as NSString
            if num != "" {
                num = (textField.text! as NSString).stringByReplacingOccurrencesOfString(".", withString: "")
                let str = formatter.stringFromNumber(NSNumber.init(double: num.doubleValue))
                textField.text = str
            }
        }
    }
}

extension EditResolutionBuyerDetailViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    func didSelectObject(object: AnyObject!) {
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if self.resolutionData.form.resolution_solution_list.count == 0 {
            return 0
        }
        
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            return self.solutionCell
        case 2:
            return self.reasonCell
        default:
            return self.uploadImageCell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
