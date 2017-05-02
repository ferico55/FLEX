//
//  EditSolutionSellerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum Type :Int {
    case edit, appeal
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
    fileprivate var refreshControl: UIRefreshControl!
    @IBOutlet var uploadImageCell: UITableViewCell!
    
    fileprivate var resolutionData : EditResolutionFormData = EditResolutionFormData()
    fileprivate var postObject : ReplayConversationPostData = ReplayConversationPostData()
    fileprivate var firstResponderIndexPath : IndexPath?
    fileprivate var alertProgress : UIAlertView = UIAlertView()
    
    
    var successEdit : ((_ solutionLast: ResolutionLast, _ conversationLast: ResolutionConversation, _ replyEnable: Bool) -> Void)?
    var resolutionID : String = ""
    var isGetProduct : Bool   = false
    var type         : Type   = Type.edit
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.type == .edit {
            self.title = "Ubah Solusi"
        } else {
            self.title = "Naik Banding"
        }
        
        deleteImageButtons = NSArray.sortViewsWithTag(in: deleteImageButtons) as! [UIButton]
        uploadImageButtons = NSArray.sortViewsWithTag(in: uploadImageButtons) as! [UIButton]
        
        let button : UIBarButtonItem = UIBarButtonItem(title: "Selesai", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditSolutionSellerViewController.onTapSubmit))
        self.navigationItem.rightBarButtonItem = button
        
        self.tableView.register(UINib(nibName: "EditSolutionSellerCell", bundle: nil), forCellReuseIdentifier: "EditSolutionSellerCellIdentifier")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReasonCellIdentifier")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SolutionCellIdentifier")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "uploadImageCellIdentifier")
        
        self.tableView.tableHeaderView = headerView
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        returnMoneyViewHeight.constant = 0
        
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditSolutionSellerViewController.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(EditSolutionSellerViewController.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(EditSolutionSellerViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        reasonTextView.placeholder = "Tulis alasan Anda disini"
        
        self.requestDataForm()
        self.adjustAlertProgressAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type == .edit {
            AnalyticsManager.trackScreenName("Resolution Center Seller Edit Page")
        } else {
            AnalyticsManager.trackScreenName("Resolution Center Appeal Page")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        uploadScrollView.contentSize = uploadImageContentView.frame.size
    }
    
    @objc fileprivate func refresh() {
        self.requestDataForm()
    }
    
    fileprivate func requestDataForm(){
        if self.type == .edit {
            self.requestDataFormEdit()
        } else {
            self.requestDataFormAppeal()
        }
    }
    
    fileprivate func requestDataFormEdit(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData.fetchformEditResolutionID(resolutionID, isGetProduct: isGetProduct, onSuccess: { (data) in
            
            self.setResolutionData(data!)
            self.tableView.reloadData()
            
            self.isFinishRequest(true)
            
        }) { (error) in
            self.isFinishRequest(true)
        }
    }
    
    fileprivate func requestDataFormAppeal(){
        
        self.isFinishRequest(false)
        
        RequestResolutionData.fetchformAppealResolutionID(resolutionID, onSuccess: { (data) in
            self.setResolutionData(data!)
            self.tableView.reloadData()
            
            self.isFinishRequest(true)
            
        }) { (error) in
            self.isFinishRequest(true)
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
    
    fileprivate func setSelectedSolutionWithData(_ data:EditResolutionFormData){
        
        for solution in data.form.resolution_solution_list where Int(solution.solution_id) == Int(data.form.resolution_last.last_solution) {
            postObject.selectedSolution = solution
            postObject.selectedSolution.refund_amt = data.form.resolution_last.last_refund_amt.stringValue
            postObject.selectedSolution.refund_amt_idr = data.form.resolution_last.last_refund_amt_idr
            self.adjustUISolution(postObject.selectedSolution)
        }
    }
    
    fileprivate func setResolutionData(_ data:EditResolutionFormData){
        self.resolutionData = data
        self.setSelectedSolutionWithData(data)
        self .adjustUIForm(data.form)
    }
    fileprivate func adjustUIForm(_ form: EditResolutionForm) {
        invoiceButton.setTitle(form.resolution_order.order_invoice_ref_num, for: .normal)
        buyerButton.setTitle("Pembelian Oleh \(form.resolution_customer.customer_name)", for: .normal)
    }
    
    fileprivate func adjustUISolution(_ solution: EditSolution){
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
    
    fileprivate func navigateToPhotoPicker(){
        
        TKPImagePickerController.showImagePicker(self,
                                              assetType: .allPhotos,
                                              allowMultipleSelect: true,
                                              showCancel: true,
                                              showCamera: true,
                                              maxSelected: 5,
                                              selectedAssets: self.postObject.selectedAssets as NSArray
        ) { [unowned self] (assets) in
            self.postObject.selectedAssets = assets
            self.adjustUISelectedImage()
        }
    }
    
    fileprivate func adjustUISelectedImage(){
        uploadImageButtons.forEach {
            $0.isHidden = true
            $0.setBackgroundImage(UIImage(named: "icon_upload_image.png"), for: UIControlState())
        }
        
        deleteImageButtons.forEach{ $0.isHidden = true }
        
        for (index,asset) in postObject.selectedAssets.enumerated() {
            if index == uploadImageButtons.count {
                postObject.selectedAssets.removeLast()
                break
            }
            uploadImageButtons[index].isHidden = false
            deleteImageButtons[index].isHidden = false
            
            asset.fetchImageWithSize(self.uploadImageButtons[index].frame.size.toPixel(), completeBlock: { [weak self](image, info) in
                guard let `self` = self else { return }
                self.uploadImageButtons[index].setBackgroundImage(image, for: .normal)
            })
        }
        
        if (postObject.selectedAssets.count<uploadImageButtons.count) {
            let uploadedButton = uploadImageButtons[postObject.selectedAssets.count]
            uploadedButton.isHidden = false
            
            uploadScrollView.contentSize = CGSize(width: uploadedButton.frame.origin.x+uploadedButton.frame.size.width+30, height: 0);
            
        }
    }
    
    @objc fileprivate func onTapSubmit(){
        self.adjustPostData()
        let validation : ResolutionValidation = ResolutionValidation()
        if !validation.isValidSubmitEditResolution(self.postObject) {
            return;
        }
        
        if type == Type.edit {
            postObject.editSolution = "1"
            self.requestSubmitEdit()
        } else {
            postObject.editSolution = "0"
            self.requestSubmitAppeal()
        }
    }
    
    fileprivate func adjustPostData(){
        if isGetProduct {
            postObject.flagReceived = "1"
        } else {
            postObject.flagReceived = "0"
        }
        
        postObject.resolutionID = resolutionID
        postObject.refundAmount = (refundTextField.text?.replacingOccurrences(of: ".", with: ""))!
        postObject.replyMessage = reasonTextView.text
        if Int(resolutionData.form.resolution_by.by_customer) == 1 {
            postObject.actionBy     = "1"
        } else {
            postObject.actionBy     = "2"
        }
        postObject.category_trouble_id = resolutionData.form.resolution_last.last_category_trouble_type
        postObject.troubleType = resolutionData.form.resolution_last.last_trouble_type
    }
    
    func didSuccessEdit(_ success:@escaping ((_ solutionLast: ResolutionLast, _ conversationLast: ResolutionConversation, _ replyEnable: Bool)->Void)){
        self.successEdit = success
    }
    
    @IBAction func onTapInvoiceButton(_ sender: UIButton) {
        NavigateViewController.navigateToInvoice(from: self, withInvoiceURL: resolutionData.form.resolution_order.order_pdf_url)
    }
    
    @IBAction func onTapBuyerButton(_ sender: UIButton) {
        
    }
    
    fileprivate func requestSubmitEdit() {
        
        alertProgress.show()
        
        RequestResolution.fetchReplayConversation(postObject, onSuccess: { (data) in
            StickyAlertView.showSuccessMessage(["Anda berhasil mengubah solusi."])
            self.alertProgress.dismiss(withClickedButtonIndex: 0, animated: true)
            self.successEdit?(data.solution_last, data.conversation_last[0] , true)
            
        }) {
            self.alertProgress.dismiss(withClickedButtonIndex: 0, animated: true)
        }
    }
    
    fileprivate func requestSubmitAppeal() {
        
        alertProgress.show()
        
        RequestResolutionAction.fetchAppealResolutionID(resolutionID,
                                                        solution: postObject.selectedSolution.solution_id,
                                                        refundAmount: refundTextField.text,
                                                        message: reasonTextView.text,
                                                        imageObjects: postObject.selectedAssets,
                                                        success: { (data) in
                                                            self.successEdit?((data?.solution_last)!, (data?.conversation_last[0])! , true)
                                                            self.alertProgress.dismiss(withClickedButtonIndex: 0, animated: true)
                                                            self.navigationController?.popViewController(animated: true)
                                                            
        }) { (error) in
            self.alertProgress.dismiss(withClickedButtonIndex: 0, animated: true)
        }
    }
    
    @IBAction func onTapChooseSolution(_ sender: AnyObject) {
        let controller : GeneralTableViewController = GeneralTableViewController()
        controller.objects = self.resolutionData.form.resolution_solution_list.map{$0.solution_text}
        controller.delegate = self
        controller.title = "Ubah Solusi"
        controller.selectedObject = postObject.selectedSolution.solution_text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onTapImageButton(_ sender: AnyObject) {
        self.navigateToPhotoPicker()
    }
    
    @IBAction func onTapCancelButton(_ sender: UIButton) {
        postObject.selectedAssets.remove(at: sender.tag)
        self.adjustUISelectedImage()
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

extension EditSolutionSellerViewController : GeneralTableViewControllerDelegate {
    //MARK: GeneralTableViewDelegate
    func didSelectObject(_ object: AnyObject!) {
        for solution in resolutionData.form.resolution_solution_list where solution.solution_text == object as! String {
            postObject.selectedSolution = solution
            self.adjustUISolution(postObject.selectedSolution)
            tableView.reloadData()
        }
        
    }
}

extension EditSolutionSellerViewController : UITextViewDelegate {
    //MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        reasonTextView.placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.firstResponderIndexPath = IndexPath(row: 0, section: 3)
        return true
    }
}

extension EditSolutionSellerViewController : UITextFieldDelegate{
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

extension EditSolutionSellerViewController : UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    
}

extension EditSolutionSellerViewController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            solutionCell.contentView.backgroundColor = UIColor.clear
            return self.solutionCell
        case 2:
            return self.uploadImageCell
        case 3:
            reasonCell.contentView.backgroundColor = UIColor.clear
            return self.reasonCell
        default:
            let cell:EditSolutionSellerCell = tableView.dequeueReusableCell(withIdentifier: "EditSolutionSellerCellIdentifier")! as! EditSolutionSellerCell
            cell.setViewModel(resolutionData.form.resolution_last.last_product_trouble[indexPath.row].sellerEditViewModel)
            cell.contentView.backgroundColor = UIColor.clear
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

