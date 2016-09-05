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
    @IBOutlet weak var invoiceLabel: UILabel!
    
    @IBOutlet var sellerLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var deleteButtons: [UIButton]!
    @IBOutlet var imageButtons: [UIButton]!
    @IBOutlet weak var reasonTextView: TKPDTextView!
    private var firstResponderIndexPath : NSIndexPath?
    
    @IBOutlet var reasonCell: UITableViewCell!
    private var refreshControl: UIRefreshControl!
    private var alertProgress : UIAlertView = UIAlertView()
    
    var postObject : ReplayConversationPostData = ReplayConversationPostData()
    var resolutionData : EditResolutionFormData = EditResolutionFormData()
    private var successEdit : ((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Komplain"
        
        let button : UIBarButtonItem = UIBarButtonItem(title: "Selesai", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(EditResolutionBuyerDetailViewController.submit))
        self.navigationItem.rightBarButtonItem = button
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditResolutionBuyerDetailViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(EditResolutionBuyerDetailViewController.keyboardWillHide),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
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
        
        deleteButtons = NSArray.sortViewsWithTagInArray(deleteButtons) as! [UIButton]
        imageButtons = NSArray.sortViewsWithTagInArray(imageButtons) as! [UIButton]

        self.adjustAlertProgressAppearance()

        reasonTextView.placeholder = "Alasan mengubah komplain"
    }
    
    @objc private func refresh() {
    
    }
    
    @IBAction func onTapDeleteImageButton(sender: UIButton) {
        postObject.selectedAssets.removeAtIndex(sender.tag)
        self.adjustUISelectedImage()
    }
    
    @IBAction func onTapUploadImageButton(sender: AnyObject) {
        self.navigateToPhotoPicker()
    }
    
    private func adjustUIForm(form: EditResolutionForm) {
        invoiceLabel.text = form.resolution_order.order_invoice_ref_num
        sellerLabel.text = "Pembelian dari \(form.resolution_order.order_shop_name)"
        solutionLabel.text = form.resolution_last.last_solution_string
    }
    
    private func adjustUISolution(solution: EditSolution){
        solutionLabel.text = solution.solution_text
        refundTextField.text = solution.refund_amt
        maxRefundLabel.text = solution.max_refund_idr
        maxInvoicedescriptionLabel.text = solution.refund_text_desc
        
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
        
            self.successEdit!(solutionLast: data.solution_last, conversationLast: data.conversation_last[0] , replyEnable: true)
            self.navigationController?.popViewControllerAnimated(false)
            self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
            
        }) {
            
            self.alertProgress.dismissWithClickedButtonIndex(0, animated: true)
        }
    }
    
    private func postObjectEditSolution()->ReplayConversationPostData{
        postObject.refundAmount = refundTextField.text!
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
            product.quantity = $0.pt_show_input_quantity
            product.order_dtl_id = $0.pt_order_dtl_id
            product.remark = $0.pt_solution_remark
            object.product_list.addObject(product)
            postObject.postObjectProducts.append(product)
        }
        return object
    }
    
    private func fetchPossibleSolutions(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData .fetchPossibleSolutionWithPossibleTroubleObject(self.postObjectPossibleSolution(), troubleId: postObject.troubleType, success: { (data) in
            
                self.isFinishRequest(true)
                
                self.resolutionData.form.resolution_solution_list = data
                data.forEach{
                    if Int($0.solution_id) == Int(self.resolutionData.form.resolution_last.last_solution) {
                        self.postObject.selectedSolution = $0
                        self .adjustUISolution($0)
                    }
                }
                self.tableView.reloadData()
            
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
        UIView.animateWithDuration(0.3) {
            if self.firstResponderIndexPath != nil {
                self.tableView.contentInset = UIEdgeInsetsZero
            }
        }
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 1)
        return true
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
