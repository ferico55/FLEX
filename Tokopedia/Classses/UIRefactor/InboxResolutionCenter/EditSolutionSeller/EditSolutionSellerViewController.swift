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
class EditSolutionSellerViewController: UIViewController {
    
    @IBOutlet var reasonCell: UITableViewCell!
    @IBOutlet var solutionCell: UITableViewCell!
    @IBOutlet var returnMoneyViewHeight: NSLayoutConstraint!
    
    @IBOutlet var buyerLabel: UILabel!
    @IBOutlet var invoiceLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var reasonTextView: UITextView!
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
    private var selectedSolution : EditSolution = EditSolution()
    private var selectedAssets : [DKAsset] = []
    var successAppeal : ((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool) -> Void)?

    private var firstResponderIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    
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
                                                         selector: #selector(EditSolutionSellerViewController.keyboardWillHide),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditSolutionSellerViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.requestDataForm()
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
            selectedSolution = solution
            selectedSolution.refund_amt = data.form.resolution_last.last_refund_amt.stringValue
            selectedSolution.refund_amt_idr = data.form.resolution_last.last_refund_amt_idr
            self.adjustUISolution(selectedSolution)
        }
    }
    
    private func setResolutionData(data:EditResolutionFormData){
        self.resolutionData = data
        self.setSelectedSolutionWithData(data)
        self .adjustUIForm(data.form)
    }
    private func adjustUIForm(form: EditResolutionForm) {
        invoiceLabel.text = form.resolution_order.order_invoice_ref_num
        buyerLabel.text = "Pembelian Oleh \(form.resolution_customer.customer_name)"
        solutionLabel.text = form.resolution_last.last_solution_string
    }
    
    private func adjustUISolution(solution: EditSolution){
        solutionLabel.text = solution.solution_text
        refundTextField.text = solution.refund_amt
        maxRefundLabel.text = solution.max_refund_idr
        maxRefundDescriptionLabel.text = solution.refund_text_desc
        
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
                                              selectedAssets: self.selectedAssets
        ) { [unowned self] (assets) in
            self.selectedAssets = assets
            self.adjustUISelectedImage()
        }
    }
    
    private func adjustUISelectedImage(){
        uploadImageButtons.forEach {
            $0.hidden = true
            $0.setBackgroundImage(UIImage.init(named: "icon_upload_image.png"), forState: .Normal)
        }
        
        deleteImageButtons.forEach{ $0.hidden = true }
        
        for (index,asset) in selectedAssets.enumerate() {
            uploadImageButtons[index].hidden = false
            deleteImageButtons[index].hidden = false
            uploadImageButtons[index].setBackgroundImage(asset.thumbnailImage, forState: .Normal)
        }
        
        if (selectedAssets.count<uploadImageButtons.count) {
            let uploadedButton = uploadImageButtons[selectedAssets.count]
            uploadedButton.hidden = false
            
            uploadScrollView.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, 0);

        }
    }
    
    @objc private func onTapSubmit(){
        if type == Type.Edit {
            
        } else {
            self.requestSubmitAppeal()
        }
    }
    
    func didSuccessAppeal(success:((solutionLast: ResolutionLast, conversationLast: ResolutionConversation, replyEnable: Bool)->Void)){
        self.successAppeal = success
    }
    
    private func requestSubmitAppeal() {
        let progressHUDView : ProgressHUDView = ProgressHUDView.init(text: "Processing... ")
        self.view.addSubview(progressHUDView)

        RequestResolutionAction .fetchAppealResolutionID(resolutionID,
                                                         solution: selectedSolution.solution_id,
                                                         refundAmount: refundTextField.text,
                                                         message: reasonTextView.text,
                                                         imageObjects: selectedAssets,
                                                         success: { (data) in
            self.successAppeal!(solutionLast: data.solution_last, conversationLast: data.conversation_last[0] as! ResolutionConversation, replyEnable: true)
            progressHUDView.removeFromSuperview()
            self.navigationController?.popViewControllerAnimated(true)
                                                            
        }) { (error) in
                
            progressHUDView.removeFromSuperview()
                
        }
    }
    
    @IBAction func onTapChooseSolution(sender: AnyObject) {
        let controller : GeneralTableViewController = GeneralTableViewController()
        controller.objects = self.resolutionData.form.resolution_solution_list.map{$0.solution_text}
        controller.delegate = self
        controller.title = "Ubah Solusi"
        controller.selectedObject = selectedSolution.solution_text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onTapImageButton(sender: AnyObject) {
        self.navigateToPhotoPicker()
    }
    
    @IBAction func onTapCancelButton(sender: UIButton) {
        selectedAssets.removeAtIndex(sender.tag)
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
        UIView.animateWithDuration(0.3) {
            if self.firstResponderIndexPath != nil {
                self.tableView.contentInset = UIEdgeInsetsZero
            }
        }
    }
}

extension EditSolutionSellerViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    func didSelectObject(object: AnyObject!) {
        for solution in resolutionData.form.resolution_solution_list where solution.solution_text == object as! String {
            selectedSolution = solution
            self.adjustUISolution(selectedSolution)
            tableView.reloadData()
        }

    }
}

extension EditSolutionSellerViewController : UITextViewDelegate {
    //MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.firstResponderIndexPath = NSIndexPath.init(forRow: 0, inSection: 3)
        return true
    }
}

extension EditSolutionSellerViewController : UITextFieldDelegate{
    //MARK: UITextFieldDelegate
    
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

