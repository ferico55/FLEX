//
//  EditSolutionSellerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum Type :Int {
    case Edit, Appeal
}

@IBDesignable
@objc(EditSolutionSellerViewController) class EditSolutionSellerViewController: UIViewController {
    
    @IBOutlet var reasonCell: UITableViewCell!
    @IBOutlet var solutionCell: UITableViewCell!
    @IBOutlet var returnMoneyViewHeight: NSLayoutConstraint!
    
    @IBOutlet var buyerButton: UIButton!
    @IBOutlet var invoiceButton: UIButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var reasonTextView: TKPDTextView!
    @IBOutlet weak var refundTextField: UITextField!
    @IBOutlet weak var maxRefundLabel: UILabel!
    @IBOutlet weak var uploadImageContentView: UIView!
    @IBOutlet weak var maxRefundDescriptionLabel: UILabel!
    @IBOutlet var deleteImageButtons: [UIButton]!
    @IBOutlet weak var solutionLabel: UILabel!
    
    @IBOutlet weak var uploadScrollView: UIScrollView!
    @IBOutlet var uploadImageButtons: [UIButton]!
    private var refreshControl: UIRefreshControl!
    @IBOutlet var uploadImageCell: UITableViewCell!
    
    private var resolutionData : EditResolutionFormData = EditResolutionFormData()
    private var postObject : ReplayConversationPostData = ReplayConversationPostData()
    private var firstResponderIndexPath : NSIndexPath?
    private var alertProgress : UIAlertView = UIAlertView()

    
    var successEdit : ((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool) -> Void)?
    var resolutionID : String = ""
    var isGetProduct : Bool   = false
    var type         : Type   = Type.Edit
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.type == .Edit {
            self.title = "Ubah Solusi"
        } else {
            self.title = "Naik Banding"
        }
        
        deleteImageButtons = NSArray.sortViewsWithTagInArray(deleteImageButtons) as! [UIButton]
        uploadImageButtons = NSArray.sortViewsWithTagInArray(uploadImageButtons) as! [UIButton]
        
        let button : UIBarButtonItem = UIBarButtonItem(title: "Selesai", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditSolutionSellerViewController.onTapSubmit))
        self.navigationItem.rightBarButtonItem = button
        
        self.tableView.registerNib(UINib.init(nibName: "EditSolutionSellerCell", bundle: nil), forCellReuseIdentifier: "EditSolutionSellerCellIdentifier")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ReasonCellIdentifier")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SolutionCellIdentifier")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "uploadImageCellIdentifier")

        self.tableView.tableHeaderView = headerView

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        returnMoneyViewHeight.constant = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditSolutionSellerViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditSolutionSellerViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditSolutionSellerViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        reasonTextView.placeholder = "Tulis alasan anda disini"
        
        self.requestDataForm()
        self.adjsutAlertProgressAppearance()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func adjsutAlertProgressAppearance(){
        alertProgress = UIAlertView.init(title: nil, message: "Please wait...", delegate: nil, cancelButtonTitle: nil);
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        alertProgress.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        uploadScrollView.contentSize = uploadImageContentView.frame.size
    }
    
    @objc private func refresh() {
        self.requestDataForm()
    }
    
    private func requestDataForm(){
        if self.type == .Edit {
            self.requestDataFormEdit()
        } else {
            self.requestDataFormAppeal()
        }
    }
    
    private func requestDataFormEdit(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData.fetchformEditResolutionID(resolutionID, isGetProduct: isGetProduct, onSuccess: { (data) in
            
            self.setResolutionData(data)
            self.tableView.reloadData()
            
            self.isFinishRequest(true)
            
        }) { (error) in
            self.isFinishRequest(true)
        }
    }
    
    private func requestDataFormAppeal(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData.fetchformAppealResolutionID(resolutionID, onSuccess: { (data) in
            self.setResolutionData(data)
            self.tableView.reloadData()
            
            self.isFinishRequest(true)
            
        }) { (error) in
            self.isFinishRequest(true)
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
    
    private func setSelectedSolutionWithData(data:EditResolutionFormData){

        for solution in data.form.resolution_solution_list where Int(solution.solution_id) == Int(data.form.resolution_last.last_solution) {
            postObject.selectedSolution = solution
            postObject.selectedSolution.refund_amt = data.form.resolution_last.last_refund_amt.stringValue
            postObject.selectedSolution.refund_amt_idr = data.form.resolution_last.last_refund_amt_idr
            self.adjustUISolution(postObject.selectedSolution)
        }
    }
    
    private func setResolutionData(data:EditResolutionFormData){
        self.resolutionData = data
        self.setSelectedSolutionWithData(data)
        self .adjustUIForm(data.form)
    }
    private func adjustUIForm(form: EditResolutionForm) {
        invoiceButton.setTitle(form.resolution_order.order_invoice_ref_num, forState: .Normal)
        buyerButton.setTitle("Pembelian Oleh \(form.resolution_customer.customer_name)", forState: .Normal)
    }
    
    private func adjustUISolution(solution: EditSolution){
        solutionLabel.text = solution.solution_text
        maxRefundLabel.text = solution.max_refund_idr
        maxRefundDescriptionLabel.text = solution.refund_text_desc
        
        postObject.maxRefundAmount = solution.max_refund
        postObject.maxRefundAmountIDR = solution.max_refund_idr
        
        if solution.show_refund_box == "0"{
            returnMoneyViewHeight.constant = 0
        } else {
            returnMoneyViewHeight.constant = 128
        }
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
        uploadImageButtons.forEach {
            $0.hidden = true
            $0.setBackgroundImage(UIImage.init(named: "icon_upload_image.png"), forState: .Normal)
        }
        
        deleteImageButtons.forEach{ $0.hidden = true }
        
        for (index,asset) in postObject.selectedAssets.enumerate() {
            if index == uploadImageButtons.count {
                postObject.selectedAssets.removeLast()
                break
            }
            uploadImageButtons[index].hidden = false
            deleteImageButtons[index].hidden = false
            uploadImageButtons[index].setBackgroundImage(asset.thumbnailImage, forState: .Normal)
        }
        
        if (postObject.selectedAssets.count<uploadImageButtons.count) {
            let uploadedButton = uploadImageButtons[postObject.selectedAssets.count]
            uploadedButton.hidden = false
            
            uploadScrollView.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, 0);

        }
    }
    
    @objc private func onTapSubmit(){
        self.adjustPostData()
        let validation : ResolutionValidation = ResolutionValidation()
        if !validation.isValidSubmitEditResolution(self.postObject) {
            return;
        }
        
        if type == Type.Edit {
            postObject.editSolution = "1"
            self.requestSubmitEdit()
        } else {
            postObject.editSolution = "0"
            self.requestSubmitAppeal()
        }
    }
    
    private func adjustPostData(){
        if isGetProduct {
            postObject.flagReceived = "1"
        } else {
            postObject.flagReceived = "0"
        }
        
        postObject.resolutionID = resolutionID
        postObject.refundAmount = (refundTextField.text?.stringByReplacingOccurrencesOfString(".", withString: ""))!
        postObject.replyMessage = reasonTextView.text
        if Int(resolutionData.form.resolution_by.by_customer) == 1 {
            postObject.actionBy     = "1"
        } else {
            postObject.actionBy     = "2"
        }
        postObject.category_trouble_id = resolutionData.form.resolution_last.last_category_trouble_type
        postObject.troubleType = resolutionData.form.resolution_last.last_trouble_type
    }
    
    func didSuccessEdit(success:((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool)->Void)){
        self.successEdit = success
    }
    
    @IBAction func onTapInvoiceButton(sender: UIButton) {
            NavigateViewController.navigateToInvoiceFromViewController(self, withInvoiceURL: resolutionData.form.resolution_order.order_pdf_url)
    }
    
    @IBAction func onTapBuyerButton(sender: UIButton) {
    
    }
    
    private func requestSubmitEdit() {
        
        alertProgress.show()
        
        RequestResolution.fetchReplayConversation(postObject, onSuccess: { (data) in
                self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
                self.successEdit?(solutionLast: data.solution_last, conversationLast: data.conversation_last[0] , replyEnable: true)
            
            }) {
                self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
        }
    }
    
    private func requestSubmitAppeal() {
        
        alertProgress.show()
        
        RequestResolutionAction .fetchAppealResolutionID(resolutionID,
                                                         solution: postObject.selectedSolution.solution_id,
                                                         refundAmount: refundTextField.text,
                                                         message: reasonTextView.text,
                                                         imageObjects: postObject.selectedAssets,
                                                         success: { (data) in
            self.successEdit?(solutionLast: data.solution_last, conversationLast: data.conversation_last[0] , replyEnable: true)
            self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
                                                            
        }) { (error) in
            self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
        }
    }
    
    @IBAction func onTapChooseSolution(sender: AnyObject) {
        let controller : GeneralTableViewController = GeneralTableViewController()
        controller.objects = self.resolutionData.form.resolution_solution_list.map{$0.solution_text}
        controller.delegate = self
        controller.title = "Ubah Solusi"
        controller.selectedObject = postObject.selectedSolution.solution_text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onTapImageButton(sender: AnyObject) {
        self.navigateToPhotoPicker()
    }
    
    @IBAction func onTapCancelButton(sender: UIButton) {
        postObject.selectedAssets.removeAtIndex(sender.tag)
        self.adjustUISelectedImage()
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

extension EditSolutionSellerViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    func didSelectObject(object: AnyObject!) {
        for solution in resolutionData.form.resolution_solution_list where solution.solution_text == object as! String {
            postObject.selectedSolution = solution
            self.adjustUISolution(postObject.selectedSolution)
            tableView.reloadData()
        }

    }
}

extension EditSolutionSellerViewController : UITextViewDelegate {
    //MARK: UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        reasonTextView.placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 3)
        return true
    }
}

extension EditSolutionSellerViewController : UITextFieldDelegate{
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

extension EditSolutionSellerViewController : UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    
}

extension EditSolutionSellerViewController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return resolutionData.form.resolution_last.last_product_trouble.count
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            solutionCell.contentView.backgroundColor = UIColor.clearColor()
            return self.solutionCell
        case 2:
            return self.uploadImageCell
        case 3:
            reasonCell.contentView.backgroundColor = UIColor.clearColor()
            return self.reasonCell
        default:
            let cell:EditSolutionSellerCell = tableView.dequeueReusableCellWithIdentifier("EditSolutionSellerCellIdentifier")! as! EditSolutionSellerCell
            cell.setViewModel(resolutionData.form.resolution_last.last_product_trouble[indexPath.row].sellerEditViewModel)
            cell.contentView.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Solusi yang diinginkan"
        case 2:
            return "Lampirkan Foto Bukti"
        case 3:
            return "Alasan ubah solusi"
        default:
            return ""
        }
    }
}

