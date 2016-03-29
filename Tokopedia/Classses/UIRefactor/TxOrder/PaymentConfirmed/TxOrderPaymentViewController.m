//
//  TxOrderPaymentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderObjectMapping.h"
#import "TxOrderPaymentEdit.h"
#import "AlertListBankView.h"
#import "TxOrderPaymentViewController.h"
#import "TxOrderConfirmPaymentForm.h"
#import "TxOrderConfirmationList.h"
#import "string_tx_order.h"
#import "AlertPickerView.h"
#import "AlertDatePickerView.h"
#import "SettingBankAccountViewController.h"
#import "SettingBankNameViewController.h"

#import "GeneralTableViewController.h"
#import "AlertInfoPaymentConfirmationView.h"
#import "TransactionAction.h"

#import "TxOrderPaymentConfirmationSuccessViewController.h"
#import "StickyAlertView.h"

#import "TokopediaNetworkManager.h"

#import "DBManager.h"

#import "TKPDPhotoPicker.h"
#import "camera.h"

#import "RequestPayment.h"
#import "AlertInfoView.h"

#import "ListRekeningBank.h"

@interface TxOrderPaymentViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate,SettingBankAccountViewControllerDelegate, GeneralTableViewControllerDelegate, SettingBankNameViewControllerDelegate,UITextFieldDelegate,UITextViewDelegate, UIScrollViewDelegate, SuccessPaymentConfirmationDelegate, TokopediaNetworkManagerDelegate, TKPDPhotoPickerDelegate, RequestPaymentDelegate>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isNewRekening;
    
    TxOrderObjectMapping *_mapping;
    
    TokopediaNetworkManager *_networkManager;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSOperationQueue *_operationQueue;
    
    BOOL _isFinishRequestForm;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    NSArray *_bankAccount;
    
    TKPDPhotoPicker *_photoPicker;
    UIAlertView *_loadingAlertView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *uploadPaymentCell;
@property (strong, nonatomic) IBOutlet UIView *upLoadPaymentView;
@property (weak, nonatomic) IBOutlet UIButton *uploadPaymentButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadPaymentInfo;
@property (strong, nonatomic) IBOutlet UITableViewCell *addRekBankCell;
@property (weak, nonatomic) IBOutlet UIImageView *proofImageView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *sectionNewRekeningCells;
@property (weak, nonatomic) IBOutlet UILabel *NewBankNameLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *lastInfoCell;

@property (weak, nonatomic) IBOutlet UILabel *infoNominalLabel;
@property (strong, nonatomic) IBOutlet UIView *section2FooterView;
@property (strong, nonatomic) IBOutlet UIView *section3FooterView;
@property (weak, nonatomic) IBOutlet UILabel *infoConfirmation;
@property (strong, nonatomic) IBOutlet UIView *addNewRekeningFooterView;
@property (weak, nonatomic) IBOutlet UIButton *addNewRekeningButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *markCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *infoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordTokopediaCell;
@property (strong, nonatomic) IBOutlet UIView *passwordFooterView;
@property (weak, nonatomic) IBOutlet UILabel *branchViewLabel;
@property (strong, nonatomic) IBOutlet UIView *branchFooterView;
@property (strong, nonatomic) IBOutlet UIView *addNewRekeningHeaderView;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *rekeningNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *branchTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalPaymentTextField;
@property (weak, nonatomic) IBOutlet UITextField *depositorTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3CashCells;
@property (weak, nonatomic) IBOutlet UITextView *markTextView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UITableViewCell *RekInfoCell;

@end

#define TAG_REQUEST_FORM 10

@implementation TxOrderPaymentViewController

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [TxOrderObjectMapping new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.tagRequest = TAG_REQUEST_FORM;
    _networkManager.delegate = self;
    
    _sectionNewRekeningCells = [NSArray sortViewsWithTagInArray:_sectionNewRekeningCells];
    _section2Cell = [NSArray sortViewsWithTagInArray:_section2Cell];
    _section3CashCells = [NSArray sortViewsWithTagInArray:_section3CashCells];
    _section1Cell = [NSArray sortViewsWithTagInArray:_section1Cell];
    
    self.title = _isConfirmed?TITLE_PAYMENT_EDIT_CONFIRMATION_FORM:TITLE_PAYMENT_CONFIRMATION_FORM;
    
    [_infoNominalLabel setCustomAttributedText:_infoNominalLabel.text];
    [_infoConfirmation setCustomAttributedText:_infoConfirmation.text];

    NSString *string = @"Untuk Bank selain BCA diharuskan mengisi Kantor Cabang beserta kota tempat Bank berada. \nContoh: Pondok Indah - Jakarta Selatan";
    [_branchViewLabel setCustomAttributedText:string];
    [_infoConfirmation setCustomAttributedText:_infoConfirmation.text];

    _addNewRekeningButton.layer.cornerRadius = 2;

    [_dataInput addEntriesFromDictionary:_data];
    
    [_networkManager doRequest];
    
    _isNewRekening = NO;
    
    [_dataInput setObject:[NSDate date] forKey:DATA_PAYMENT_DATE_KEY];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _networkManager.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (_isConfirmed) {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [backBarButtonItem setTintColor:[UIColor whiteColor]];
        backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
        self.navigationItem.backBarButtonItem = backBarButtonItem;
        
        backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [backBarButtonItem setTintColor:[UIColor whiteColor]];
        backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
        self.navigationItem.rightBarButtonItem = backBarButtonItem;
    }
    else
    {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tidak" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [backBarButtonItem setTintColor:[UIColor whiteColor]];
        backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ya" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [backBarButtonItem setTintColor:[UIColor whiteColor]];
        backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
        self.navigationItem.rightBarButtonItem = backBarButtonItem;
    } 
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tapUploadProof:(id)sender {
    _photoPicker = [self photoPicker];
}

- (IBAction)tapUploadProofInfo:(id)sender {
    AlertInfoView *alert = [AlertInfoView new];
    alert.delegate = self;
    [alert setText:@"Info"];
    [alert setDetailText:@"Umumnya verifikasi pembayaran memakan waktu maksimal 1x24 jam.\n\nApabila pembayaran Anda belum juga diverifikasi, kami sarankan untuk mengupload bukti bayar Anda, sehingga dapat membantu mempercepat proses verifikasi pembayaran"];
    [alert show];
}

- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    NSArray *selectedOrder = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == TAG_BAR_BUTTON_TRANSACTION_DONE) {
            if ([self isValidInput]) {
                [self doConfirmPayment];
            }
        }
        else
        {
            [_delegate failedOrCancelConfirmPayment:selectedOrder];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        _isNewRekening = !(_isNewRekening);
        if (_isNewRekening) {
            BankAccountFormList *bankAccount = [BankAccountFormList new];
            [_dataInput setObject:bankAccount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
        }
        else
        {
            BankAccountFormList *bankAccount = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_DEFAULT_KEY]?:[BankAccountFormList new];
            [_dataInput setObject:bankAccount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
        }
        [_tableView reloadData];
    }
}
- (IBAction)tapRekeningInfo:(id)sender {
    AlertListBankView *popUp = [AlertListBankView newview];
    ListRekeningBank *listBank = [ListRekeningBank new];
    popUp.list = [listBank getRekeningBankList];
    [popUp show];
}

-(void)showLoadingView
{
    [self initLoadingView];
    [_loadingAlertView show];
}

-(void)dismissLoadingView
{
    [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)initLoadingView
{
    _loadingAlertView = [[UIAlertView alloc] initWithTitle:@"Uploading" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    
    [_loadingAlertView setValue:indicator forKey:@"accessoryView"];
}

-(TKPDPhotoPicker *)photoPicker
{
    _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                                  pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
    _photoPicker.delegate = self;
    return _photoPicker;
}

-(void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo
{
    NSDictionary* photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    UIImage* imagePhoto = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    _proofImageView.image = imagePhoto;
    
    [_dataInput setObject:userInfo forKey:@"data_image_object"];
}

-(NSDictionary *)getImageObject
{
    return [_dataInput objectForKey:@"data_image_object"][@"photo"]?:@{};
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isFinishRequestForm)
    {
        NSInteger sectionCount = 10;
        return sectionCount;
    }
    else
        return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0;
    switch (section) {
        case 0: return _section0Cell.count;
            break;
        case 1: return _section1Cell.count;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return _sectionNewRekeningCells.count;
            break;
        case 5:
            return _section2Cell.count;
            break;
        case 6:
            return 1;
            break;
        case 7:
            return 1;
            break;
        case 8:
            return 1;
            break;
        case 9:
            return 1;
            break;
        default:
            break;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    switch (indexPath.section) {
        case 0: cell = _section0Cell[indexPath.row];
            break;
        case 1: cell = _section1Cell[indexPath.row];
            break;
        case 2:
            cell = _infoCell;
            break;
        case 3:
            cell = _addRekBankCell;
            break;
        case 4:
            cell = _sectionNewRekeningCells[indexPath.row];
            break;
        case 5:
            cell = _section2Cell[indexPath.row];
            break;
        case 6:
            cell = _uploadPaymentCell;
            break;
        case 7:
            cell = _markCell;
            break;
        case 8:
            cell = _passwordTokopediaCell;
            break;
        case 9:
            cell = _lastInfoCell;
            break;
        default:
            break;
    }
    [self adjustDetailTextLabelCell:cell atIndextPath:indexPath];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width,1)];
    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
    [cell.contentView addSubview:lineView];
    cell.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellAccessoryNone;    
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isPaymentTypeTransfer] && (section == 3 || section == 4)) {
        return 1;
    }
    if ([self isPaymentTypeBank] && (section == 2 || section == 3 || section == 4 || section == 5)) {
        return 1;
    }
    if ([self isPaymentTypeSaldoTokopedia] && (section == 2 || section == 3 || section == 4 || section == 5 || section == 6)) {
        return 1;
    }
    if (section == 9) {
        return 1;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            CGFloat height = [_section0Cell[indexPath.row] frame].size.height;
            if (indexPath.row == 0)
            {
                UILabel *invoiceLabel = [_section0Cell[indexPath.row] detailTextLabel];
                invoiceLabel.numberOfLines = 0;
                NSString *textString = invoiceLabel.text;
                [invoiceLabel setCustomAttributedText:textString];
                
                //Calculate the expected size based on the font and linebreak mode of your label
                CGSize maximumLabelSize = CGSizeMake(190,9999);
                
                CGSize expectedLabelSize = [textString sizeWithFont:invoiceLabel.font
                                                  constrainedToSize:maximumLabelSize
                                                      lineBreakMode:invoiceLabel.lineBreakMode];
                
                //adjust the label the the new height.
                CGRect newFrame = invoiceLabel.frame;
                newFrame.size.height = expectedLabelSize.height + 26;
                return newFrame.size.height;
            }
            else return height;
        }
            break;
        case 1:
        {
            BankAccountFormList *selectedBank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
            if (([self isPaymentTypeTransfer] || [self isPaymentTypeSaldoTokopedia] || _isNewRekening || [selectedBank.bank_account_id integerValue] == 0 ) && indexPath.row == 2) {
                return 0;
            }
            if(indexPath.row == 3)
            {
                if ([self isPaymentTypeSaldoTokopedia])
                    return 0;
                else
                    return 54;
            }
        }
            break;
        case 2:
            if (![self isPaymentTypeTransfer]) {
                return 0;
            }
            break;
        case 3:
            if ([self isPaymentTypeSaldoTokopedia]) {
                return 0;
            }
            if (_isNewRekening) {
                return 0;
            }
            if ([self isPaymentTypeTransfer]) {
                return 0;
            }
            break;
        case 4:
            if ([self isPaymentTypeSaldoTokopedia]) {
                return 0;
            }
            if ([self isPaymentTypeTransfer]) {
                return 0;
            }
            else if (!_isNewRekening) {
                return 0;
            }
            else
            {
                if (indexPath.row == 0)
                    return 85;
                else if (indexPath.row == 3)
                    return 125;
            }
            break;
        case 5:
            if (![self isPaymentTypeTransfer] && indexPath.row == 0) {
                return 0;
            }
            if ([self isPaymentTypeSaldoTokopedia]) {
                return 0;
            }
            break;
        case 6:
            if ([self isPaymentTypeSaldoTokopedia] || _isConfirmed) {
                return 0;
            }
            return 106;
            break;
        case 7:
            return _markCell.frame.size.height;
            break;
        case 8:
            if (![self isPaymentTypeSaldoTokopedia]) {
                return 0;
            }
            return 82;
            break;
        case 9:
            return _lastInfoCell.frame.size.height;
            break;
        default:
            break;
    }
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self isPaymentTypeTransfer] && (section == 3 || section == 4)) {
        return 1;
    }
    if ([self isPaymentTypeBank] && _isNewRekening && (section == 2 || section == 3 || section == 4 )) {
        return 1;
    }
    if ([self isPaymentTypeSaldoTokopedia] && (section == 2 || section == 3 || section == 4 || section == 5 || section == 6)) {
        return 1;
    }
    if (section == 8) {
        return 1;
    }
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == _section2Cell[0]) {
        [_depositorTextField becomeFirstResponder];
    }
    if (cell == _section2Cell[1]) {
        [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SYSTEM_BANK_KEY];
        [self pushToGeneralViewControllerAtIndextPath:indexPath];
    }
    if (cell == _section2Cell[2]) {
        [_totalPaymentTextField becomeFirstResponder];
    }
    
    if (cell == _section1Cell[0]) {
        AlertDatePickerView *paymentDate = [AlertDatePickerView newview];
        paymentDate.delegate = self;
        NSDate *date = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY];
        paymentDate.currentdate = date;
        paymentDate.tag = 11;
        paymentDate.isSetMinimumDate = NO;
        [paymentDate show];
    }
    if (cell == _section1Cell[1]) {
        [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_PAYMENT_METHOD_KEY];
        [self pushToGeneralViewControllerAtIndextPath:indexPath];
    }
    if (cell == _section1Cell[2]) {
        [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_BANK_ACCOUNT_KEY];
        [self pushToGeneralViewControllerAtIndextPath:indexPath];
    }
    
    
    if (cell == _sectionNewRekeningCells[0]) {
        BankAccountFormList *bank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
        SettingBankNameViewController *vc = [SettingBankNameViewController new];
        vc.data = @{API_BANK_ID_KEY : @(bank.bank_id)};
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (cell == _sectionNewRekeningCells[1]) {
        [_accountNameTextField becomeFirstResponder];
    }
    if (cell == _sectionNewRekeningCells[2]) {
        [_rekeningNumberTextField becomeFirstResponder];
    }    if (cell == _sectionNewRekeningCells[3]) {
        [_branchTextField becomeFirstResponder];
    }
    
    if (cell == _infoCell) {
        AlertInfoPaymentConfirmationView *alertInfo = [AlertInfoPaymentConfirmationView newview];
        alertInfo.delegate = self;
        [alertInfo show];
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_activeTextView resignFirstResponder];
    [_activeTextField resignFirstResponder];
}

#pragma mark - Request Get Transaction Order Payment Confirmation
-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_FORM) {
        return _isConfirmed?[self objectManagerConfirmed]: [self objectManagerConfirmation];
    }
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_FORM) {
        NSArray *selectedOrders = [_data objectForKey:DATA_SELECTED_ORDER_KEY];
        NSMutableArray *confirmationIDs = [NSMutableArray new];
        for (TxOrderConfirmationList *order in selectedOrders) {
            [confirmationIDs addObject:order.confirmation.confirmation_id];
        }
        
        NSString * confirmationID = (_isConfirmed)?_paymentID:[[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"];
        NSString *action = (_isConfirmed)?ACTION_GET_EDIT_PAYMENT_FORM:ACTION_GET_CONFIRM_PAYMENT_FORM;
        NSString *confirmationKey = (_isConfirmed)?API_ORDER_PAYMENT_ID_KEY:API_CONFIRMATION_CONFIRMATION_ID_KEY;
        
        NSDictionary* param = @{API_ACTION_KEY : action,
                                confirmationKey:confirmationID};
        return param;
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_FORM) {
        return API_PATH_TX_ORDER;
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_FORM) {
        _tableView.tableFooterView = _footerView;
        [_act startAnimating];
        _isFinishRequestForm = NO;
    }
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    if (tag == TAG_REQUEST_FORM) {
        if (_isConfirmed) {
            TxOrderPaymentEdit *form = stat;
            return form.status;
        }
        else
        {
            TxOrderConfirmPaymentForm *form = stat;
            return form.status;
        }
    }
    
    return nil;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_FORM) {
        [self requestSuccess:successResult withOperation:operation];
        [_act stopAnimating];
        _tableView.tableFooterView = nil;
    }
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    [self actionAfterFailRequestMaxTries:tag];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_FORM) {
        [_act stopAnimating];
        _tableView.tableFooterView = nil;
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    id form;
    BOOL status;
    if(_isConfirmed){
        form = (TxOrderPaymentEdit*)stat;
        status = [[form status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    }
    else {
        form = (TxOrderConfirmPaymentForm*)stat;
        status = [[form status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    }
    
    if (status) {
        if([form message_error])
        {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:[form message_error] delegate:self];
            [alert show];
        }
        else{
            if (_isConfirmed)
                [self setDefaultDataConfirmed:((TxOrderPaymentEdit*)form).result.form];
            else
                [self setDefaultDataConfirmation:((TxOrderConfirmPaymentForm*)form).result.form];
            
            _isFinishRequestForm = YES;
            [_tableView reloadData];
        }
    }
}

#pragma mark - Request Confirm Payment
-(void)doConfirmPayment{
    [self showLoadingView];
    
    NSArray *selectedOrder = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    SystemBankAcount *systemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    BankAccountFormList *bank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY]?:[NSDate date];
    NSString *totalPayment = [_totalPaymentTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *bankAccountID = _isNewRekening?@"0":bank.bank_account_id?:@"";
    
    [RequestPayment fetchSubmitWithImageObject:[self getImageObject]
                                   isConfirmed:_isConfirmed
                                         token:form.token
                                 selectedOrder:selectedOrder
                                        method:method
                                  systemBankID:systemBank.sysbank_id
                                   bankAccount:bank
                                     paymentID:_paymentID?:@""
                                   paymentDate:paymentDate
                                  totalPayment:totalPayment
                                          note:_markTextView.text?:@""
                                      password:_passwordTextField.text?:@""
                               bankAccountName:_accountNameTextField.text?:@""
                             bankAccountBranch:_branchTextField.text?:@""
                             bankAccountNumber:_rekeningNumberTextField.text?:@""
                                 bankAccountID:bankAccountID
                                     depositor:_depositorTextField.text?:@""
                                       success:^(TransactionAction *data) {
                                           
                                           [self actionAfterRequest];
                                           [self requestSuccessConfirmPayment:data];
                                           
                                       } failed:^(NSError *error) {
                                           [self actionAfterRequest];
                                       }];
}

-(void)requestSuccessConfirmPayment:(TransactionAction*)action
{
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME object:nil userInfo:nil];
    if (_isConfirmed) {
        NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:@"Anda telah berhasil mengubah konfirmasi pembayaran", nil];
        StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:array delegate:self];
        [alert show];
        [_delegate refreshRequest];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSInteger paymentAmount = [[_dataInput objectForKey:DATA_TOTAL_PAYMENT_KEY] integerValue];
        MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
        NSMutableArray *viewControllers = [NSMutableArray new];
        [viewControllers addObjectsFromArray:self.navigationController.viewControllers];
        
        TxOrderPaymentConfirmationSuccessViewController *vc = [TxOrderPaymentConfirmationSuccessViewController new];
        vc.confirmationPayment = method.method_name;
        vc.delegate = self;
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setGroupingSeparator:@"."];
        [formatter setGroupingSize:3];
        [formatter setUsesGroupingSeparator:YES];
        [formatter setSecondaryGroupingSize:3];
        NSString *price = (paymentAmount>0)?[formatter stringFromNumber:@(paymentAmount)]:@"0";
        TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
        vc.totalPaymentValue = [self isPaymentTypeSaldoTokopedia]?form.order.order_left_amount_idr:[NSString stringWithFormat:@"Rp %@,-",price];
        vc.methodName = method.method_name;
        [viewControllers replaceObjectAtIndex:viewControllers.count-1 withObject:vc];
        self.navigationController.viewControllers = viewControllers;
        [_delegate refreshRequest];
        NSArray *selectedOrder = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
        [_delegate successConfirmPayment:selectedOrder];
        //[self.navigationController pushViewController:vc animated:YES];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil];
    }
}

-(void)actionAfterRequest
{
    [self dismissLoadingView];
}

#pragma mark - Methods
-(BOOL)isPaymentTypeBank
{
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    NSInteger paymentType = [method.method_id integerValue];
    return (paymentType == TYPE_PAYMENT_TRANSFER_ATM||
             paymentType == TYPE_PAYMENT_MOBILE_BANKING||
             paymentType == TYPE_PAYMENT_INTERNET_BANKING);
}

-(BOOL)isPaymentTypeTransfer
{
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    NSInteger paymentType = [method.method_id integerValue];
    return (paymentType == TYPE_PAYMENT_CASH_TRANSFER);
}

-(BOOL)isPaymentTypeSaldoTokopedia
{
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    NSInteger paymentType = [method.method_id integerValue];
    return (paymentType == TYPE_PAYMENT_SALDO_TOKOPEDIA);
}

-(void)adjustDetailTextLabelCell:(UITableViewCell*)cell atIndextPath:(NSIndexPath*)indexPath
{
    NSString *textString;
    
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    SystemBankAcount *selectedSystemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY]?:[SystemBankAcount new];
    MethodList *selectedMethod = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY]?:[MethodList new];
    BankAccountFormList *selectedBank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY]?:[BankAccountFormList new];
    
    NSString *systemBankString = (!selectedSystemBank.sysbank_name)?@"Pilih Rekening Tujuan":[NSString stringWithFormat:@"%@",selectedSystemBank.sysbank_name];
    
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    NSString *paymentDateString = [formatter stringFromDate:paymentDate];
    
    NSArray *invoices =(_isConfirmed)?formIsConfirmed.order.order_invoice:[form.order.order_invoice componentsSeparatedByString:@","];
    NSString *invoice = [[invoices valueForKey:@"description"] componentsJoinedByString:@",\n"];

    NSString *bankAccountString = selectedBank.bank_account_name?:@"Pilih Akun Bank";
    
    if (cell == _section0Cell[0]) {
        UILabel *invoiceLabel = [_section0Cell[indexPath.row] detailTextLabel];
        textString = invoice;
        [invoiceLabel setCustomAttributedText:invoice];
    }
    if (cell == _section0Cell[1]) {
        textString = (_isConfirmed)?formIsConfirmed.payment.order_left_amount_idr:form.order.order_left_amount_idr;
    }
    
    if (cell == _section1Cell[0]) {
        textString = paymentDateString;
    }
    if (cell == _section1Cell[1]) {
        textString = selectedMethod.method_name;
    }
    if (cell == _section1Cell[2]) {
        textString = bankAccountString;
    }
    if (cell == _section2Cell[1]) {
        textString = systemBankString;
    }
    if (cell == _sectionNewRekeningCells[0]) {
        _NewBankNameLabel.text = selectedBank.bank_name?:@"Pilih Nama Bank";
    }
    
    [cell.detailTextLabel setText:textString animated:YES];
}

-(void)pushToGeneralViewControllerAtIndextPath:(NSIndexPath*)indexPath
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];

    NSIndexPath *indexPathSystemBank = [_dataInput objectForKey:DATA_INDEXPATH_SYSTEM_BANK_KEY];
    NSIndexPath *indexPathPaymentMethod = [_dataInput objectForKey:DATA_INDEXPATH_PAYMENT_METHOD_KEY];
    NSIndexPath *indexPathBankAccount = [_dataInput objectForKey:DATA_INDEXPATH_BANK_ACCOUNT_KEY];
    
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    SystemBankAcount *selectedSystemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    MethodList *selectedMethod = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    BankAccountFormList *bankAccount = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    
    GeneralTableViewController *controller = [GeneralTableViewController new];
    controller.delegate = self;
    controller.senderIndexPath = indexPath;
    NSMutableArray *controllerObjects = [NSMutableArray new];
    
    NSArray *listSystemBank = (_isConfirmed)?formIsConfirmed.sysbank_account.sysbank_list:form.sysbank_account;
    NSArray *listBankAccount = (_isConfirmed)?formIsConfirmed.bank_account.bank_account_list:form.bank_account;
    NSArray *listMethod = (_isConfirmed)?formIsConfirmed.method.method_list:form.method;
    
    if (indexPath == indexPathSystemBank) {
        controller.title = @"Pilih Rekening Tujuan";
        [controllerObjects removeAllObjects];
        
        for (SystemBankAcount *systemBank in listSystemBank) {
            if (![controllerObjects containsObject:[NSString stringWithFormat:@"%@",systemBank.sysbank_name]]) {
                [controllerObjects addObject:[NSString stringWithFormat:@"%@",systemBank.sysbank_name]];
            }
        }
        
        controller.selectedObject = [NSString stringWithFormat:@"%@",selectedSystemBank.sysbank_name];
    }
    else if (indexPath == indexPathPaymentMethod)
    {
        controller.title = @"Pilih Cara Pembayaran";
        [controllerObjects removeAllObjects];
        
        for (MethodList *method in listMethod) {
            [controllerObjects addObject:method.method_name];
        }
        
        controller.selectedObject = selectedMethod.method_name;
    }
    else if (indexPath == indexPathBankAccount)
    {
        controller.title = @"Dari Rekening";
        [controllerObjects removeAllObjects];
        for (BankAccountFormList *bankAccount in listBankAccount) {
            [controllerObjects addObject:[NSString stringWithFormat:@"%@\n%@\na/n %@",bankAccount.bank_name,bankAccount.bank_account_number, bankAccount.bank_account_name]];
        }
        controller.selectedObject = [NSString stringWithFormat:@"%@\n%@\na/n %@",bankAccount.bank_name,bankAccount.bank_account_number, bankAccount.bank_account_name];
    }
    controller.objects = [controllerObjects copy];
    
    CGPoint scrollPosition = _tableView.contentOffset;
    [self.navigationController pushViewController:controller animated:YES];
    _tableView.contentOffset = scrollPosition;
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    SystemBankAcount *systemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    BankAccountFormList *bank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    NSString *password = [_dataInput objectForKey:DATA_PASSWORD_KEY];
    NSString *depositor = [_dataInput objectForKey:DATA_DEPOSITOR_KEY];
    
    if ([self isPaymentTypeBank] && _isNewRekening) {
        if (!bank.bank_account_name) {
            [errorMessage addObject:ERRORMESSAGE_NILL_BANK_ACCOUNT_NAME];
            isValid = NO;
        }
        if (!bank.bank_account_number) {
            [errorMessage addObject:ERRORMESSAGE_NILL_BANK_ACCOUNT_NUMBER];
            isValid = NO;
        }
        if (!bank.bank_name) {
            [errorMessage addObject:ERRORMESSAGE_NILL_BANK_NAME];
            isValid = NO;
        }
        if (!systemBank.sysbank_id) {
            [errorMessage addObject:ERRORMESSAGE_NILL_SYSTEM_BANK];
            isValid = NO;
        }
    }
    else if ([self isPaymentTypeBank]) {
        if (!systemBank.sysbank_id || [systemBank.sysbank_id isEqualToString:@""]) {
            [errorMessage addObject:ERRORMESSAGE_NILL_SYSTEM_BANK];
            isValid = NO;
        }
        if (!bank.bank_id) {
            [errorMessage addObject:ERRORMESSAGE_NILL_BANK_ACCOUNT];
            isValid = NO;
        }
    }
    else if ([self isPaymentTypeSaldoTokopedia])
    {
        if (!password || [password isEqualToString:@""]) {
            [errorMessage addObject:ERRORMESSAGE_NILL_PASSWORD_TOKOPEDIA];
            isValid = NO;
        }
    }
    else if ([self isPaymentTypeTransfer]) {
        if (!depositor || [depositor isEqualToString:@""]) {
            [errorMessage addObject:ERRORMESSAGE_NILL_DEPOSITOR];
            isValid = NO;
        }
        if (!systemBank.sysbank_id) {
            [errorMessage addObject:ERRORMESSAGE_NILL_SYSTEM_BANK];
            isValid = NO;
        }
    }
    NSString *paymentAmount = [_dataInput objectForKey:DATA_TOTAL_PAYMENT_KEY]?:@"";
    
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    NSInteger paymentOrderLeft = (_isConfirmed)?
    ([formIsConfirmed.payment.order_left_amount integerValue] - [formIsConfirmed.payment.order_confirmation_code integerValue]):
    ([form.order.order_left_amount integerValue] - [form.order.order_confirmation_code integerValue]);
    
    if (![self isPaymentTypeSaldoTokopedia] && [paymentAmount integerValue]<paymentOrderLeft) {
        [errorMessage addObject:[NSString stringWithFormat:ERRORMESSAGE_INVALID_PAYMENT_AMOUNT,paymentOrderLeft]];
        isValid = NO;
    }

    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isValid;
}

-(void)setDefaultDataConfirmed:(TxOrderPaymentEditForm*)form
{
     MethodList *selectedMethod =[MethodList new];
    for (MethodList *method in form.method.method_list) {
        if ([method.method_id isEqualToString:form.method.method_id_chosen]) {
            selectedMethod.method_id = method.method_id;
            selectedMethod.method_name = method.method_name;
        }
    }
    
    NSArray *bankAccountList = form.bank_account.bank_account_list;
    _bankAccount = bankAccountList;
    BankAccountFormList *selectedBank;
    for (BankAccountFormList *bank in bankAccountList) {
        if ([form.bank_account.bank_account_id_chosen integerValue] == [bank.bank_account_id integerValue]) {
            selectedBank = bank;
        }
    }
    
    SystemBankAcount *selectedSystemBank;
    NSArray *systemBankList = form.sysbank_account.sysbank_list;
    for (SystemBankAcount *systemBank in systemBankList) {
        if ([form.sysbank_account.sysbank_id_chosen isEqual:systemBank.sysbank_id]) {
            selectedSystemBank = systemBank;
        }
    }
    
    [_dataInput setObject:selectedMethod?:[MethodList new] forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    [_dataInput setObject:selectedBank?:[BankAccountFormList new] forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    [_dataInput setObject:selectedBank?:[BankAccountFormList new] forKey:DATA_SELECTED_BANK_ACCOUNT_DEFAULT_KEY];
    [_dataInput setObject:selectedSystemBank?:[SystemBankAcount new] forKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    
    [_dataInput setObject:form forKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    [_dataInput setObject:form.payment.order_payment_amount forKey:DATA_TOTAL_PAYMENT_KEY];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@"."];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setSecondaryGroupingSize:3];
    NSString *num = form.payment.order_payment_amount ;
    num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
    _totalPaymentTextField.text = str;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d M yyyy"];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@ %@",form.payment.order_payment_day,form.payment.order_payment_month,form.payment.order_payment_year];
    NSDate *paymentDate = [dateFormatter dateFromString:dateString]?:[NSDate date];
    [_dataInput setObject:paymentDate forKey:DATA_PAYMENT_DATE_KEY];
}

-(void)setDefaultDataConfirmation:(TxOrderConfirmPaymentFormForm*)form
{
    MethodList *selectedMethod =[MethodList new];
    selectedMethod.method_id = [form.method[3] method_id];
    selectedMethod.method_name = [form.method[3] method_name];
    
    NSArray *bankAccountList = form.bank_account;
    _bankAccount = bankAccountList;
    if(bankAccountList.count>0)
    {
        BankAccountFormList *selectedBank = bankAccountList[0];
        [_dataInput setObject:selectedBank forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
        [_dataInput setObject:selectedBank?:[BankAccountFormList new] forKey:DATA_SELECTED_BANK_ACCOUNT_DEFAULT_KEY];
    }
    
    if ([self isPaymentTypeSaldoTokopedia]) {
        
        NSString *leftAmount = form.order.order_left_amount;
        [_dataInput setObject:leftAmount forKey:DATA_TOTAL_PAYMENT_KEY];
    }
    [_dataInput setObject:selectedMethod forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    [_dataInput setObject:form forKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
}

#pragma mark - General View Controller
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    NSIndexPath *paymentMethodIndexPath = [_dataInput objectForKey:DATA_INDEXPATH_PAYMENT_METHOD_KEY];
    NSIndexPath *bankAccountIndexPath = [_dataInput objectForKey:DATA_INDEXPATH_BANK_ACCOUNT_KEY];
    NSIndexPath *systemBankIndexPath = [_dataInput objectForKey:DATA_INDEXPATH_SYSTEM_BANK_KEY];
    
    NSArray *systemBankList =(_isConfirmed)?formIsConfirmed.sysbank_account.sysbank_list:form.sysbank_account;
     NSArray *methodList =(_isConfirmed)?formIsConfirmed.method.method_list:form.method;
    NSArray *bankAccountList = (_isConfirmed)?formIsConfirmed.bank_account.bank_account_list:form.bank_account;
    
    if ([indexPath isEqual:systemBankIndexPath]) {
        for (SystemBankAcount *systemBank in systemBankList) {
            if ([[NSString stringWithFormat:@"%@",systemBank.sysbank_name] isEqualToString:(NSString*)object]) {
                [_dataInput setObject:systemBank forKey:DATA_SELECTED_SYSTEM_BANK_KEY];
            }
        }
    }
    if ([indexPath isEqual:paymentMethodIndexPath]) {
        for (MethodList *method in methodList) {
            if ([method.method_name isEqualToString:(NSString*)object]) {
                [_dataInput setObject:method forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
            }
        }
    }
    
    if ([indexPath isEqual:bankAccountIndexPath]) {
        for (BankAccountFormList *bankAccount in bankAccountList) {
            if ([[NSString stringWithFormat:@"%@\n%@\na/n %@",bankAccount.bank_name,bankAccount.bank_account_number, bankAccount.bank_account_name] isEqualToString:(NSString*)object]) {
                [_dataInput setObject:bankAccount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
            }
        }
    }
    [_tableView reloadData];
}

#pragma mark - Bank Account Delegate
-(void)SettingBankNameViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    BankAccountFormList *bankAccount = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY]?:[BankAccountFormList new];
    NSString *name;
    NSInteger bankid;
    name = [data objectForKey:API_BANK_NAME_KEY];
    bankid = [[data objectForKey:API_BANK_ID_KEY] integerValue];
    bankAccount.bank_id = bankid;
    bankAccount.bank_name = name;
    [_dataInput setObject:bankAccount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    [_tableView reloadData];
}

-(void)selectedObject:(id)object
{
    if (object) {
        [_dataInput setObject:object forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
        [_tableView reloadData];
    }
}

-(void)shouldPopViewController
{
    [_delegate shouldPopViewController];
    //[self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Alert Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    NSArray *methods = (_isConfirmed)?formIsConfirmed.method.method_list:form.method;

    if (alertView.tag == 10) {
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
        MethodList *method = methods[index];
        [_dataInput setObject:method forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
        [_tableView reloadData];
    }
    else if (alertView.tag == 11)
    {
        NSDictionary *data = alertView.data;
        NSDate *date = [data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
        [_dataInput setObject:date forKey:DATA_PAYMENT_DATE_KEY];
        [_tableView reloadData];
    }
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [_activeTextView resignFirstResponder];
    _activeTextView = nil;
    _activeTextField = textField;
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BankAccountFormList *bankAcount = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY]?:[BankAccountFormList new];
    if (textField == _accountNameTextField) {
        bankAcount.bank_account_name = textField.text;
        [_dataInput setObject:bankAcount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    }
    if (textField == _rekeningNumberTextField) {
        bankAcount.bank_account_number = textField.text;
        [_dataInput setObject:bankAcount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    }
    if (textField == _branchTextField) {
        bankAcount.bank_branch = textField.text;
        [_dataInput setObject:bankAcount forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    }
    
    if (textField == _totalPaymentTextField)
    {
        NSString *totalPayment = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        [_dataInput setObject:totalPayment forKey:DATA_TOTAL_PAYMENT_KEY];
    }
    
    if (textField == _passwordTextField) {
        [_dataInput setObject:textField.text forKey:DATA_PASSWORD_KEY];
    }
    
    if (textField == _depositorTextField) {
        [_dataInput setObject:textField.text forKey:DATA_DEPOSITOR_KEY];
    }
    _activeTextField = nil;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _totalPaymentTextField) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0)
        {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        }
        else {
            [formatter setGroupingSeparator:@"."];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""])
            {
                num = [num stringByReplacingOccurrencesOfString:@"." withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
            }
            return YES;
        }
    }
    return YES;
}

#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [_activeTextField resignFirstResponder];
    _activeTextField = nil;
    _activeTextView = textView;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _markTextView) {
        [_dataInput setObject:textView.text forKey:DATA_MARK_KEY];
    }
    _activeTextView = nil;
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _passwordTextField) {
        if ([self isPaymentTypeSaldoTokopedia]){
            //[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _passwordTokopediaCell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    if (_activeTextField == _accountNameTextField) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _sectionNewRekeningCells[1]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _rekeningNumberTextField) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _sectionNewRekeningCells[2]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _branchTextField) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _sectionNewRekeningCells[3]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _depositorTextField) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _section2Cell[0]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _totalPaymentTextField) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _section2Cell[2]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextView == _markTextView) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _markCell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableView.contentInset = contentInsets;
                         _tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Object Manager

-(RKObjectManager*)objectManagerConfirmation
{
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmPaymentForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmPaymentFormResult class]];
    
    RKObjectMapping *formMapping = [RKObjectMapping mappingForClass:[TxOrderConfirmPaymentFormForm class]];
    [formMapping addAttributeMappingsFromArray:@[API_TOKEN_KEY]];
    
    RKObjectMapping *listBankMapping = [_mapping bankAccountListMapping];
    RKObjectMapping *listSystemBankMapping = [_mapping systemBankListMapping];
    RKObjectMapping *listMethodMapping = [_mapping methodListMapping];
    RKObjectMapping *orderMapping = [_mapping confirmedOrderDetailMapping];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *formRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_FORM_KEY
                                                                                toKeyPath:API_FORM_KEY
                                                                              withMapping:formMapping];
    
    RKRelationshipMapping *orderRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_FORM_KEY
                                                                                 toKeyPath:API_ORDER_FORM_KEY
                                                                               withMapping:orderMapping];
    
    RKRelationshipMapping *listBankAccountRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_BANK_ACCOUNT_KEY
                                                                                           toKeyPath:API_BANK_ACCOUNT_KEY
                                                                                         withMapping:listBankMapping];
    
    RKRelationshipMapping *listBankRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY
                                                                                    toKeyPath:API_SYSTEM_BANK_KEY
                                                                                  withMapping:listSystemBankMapping];
    
    RKRelationshipMapping *listMethodRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_METHOD_KEY
                                                                                       toKeyPath:API_METHOD_KEY
                                                                                     withMapping:listMethodMapping];
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:formRel];
    [formMapping addPropertyMapping:listBankAccountRel];
    [formMapping addPropertyMapping:listBankRel];
    [formMapping addPropertyMapping:listMethodRel];
    [formMapping addPropertyMapping:orderRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

-(RKObjectManager*)objectManagerConfirmed
{
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEdit class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEditResult class]];
    RKObjectMapping *formMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEditForm class]];
    RKObjectMapping *methodMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEditMethod class]];
    [methodMapping addAttributeMappingsFromArray:@[API_METHOD_ID_CHOOSEN_KEY]];
    
    RKObjectMapping *bankMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEditBankAccount class]];
    [bankMapping addAttributeMappingsFromArray:@[API_BANK_ACCOUNT_ID_CHOOSEN_KEY]];
    
    RKObjectMapping *systemBankMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEditSystemBank class]];
    [systemBankMapping addAttributeMappingsFromArray:@[API_SYSTEM_BANK_ID_CHOOSEN_KEY]];
    
    RKObjectMapping *orderMapping = [RKObjectMapping mappingForClass:[TxOrderPaymentEditOrder class]];
    [orderMapping addAttributeMappingsFromArray:@[API_INVOICE_STRING_KEY,
                                                  API_INVOICE_LIST_KEY
                                                  ]];
    
    RKObjectMapping *listBankMapping = [_mapping bankAccountListMapping];
    RKObjectMapping *listSystemBankMapping = [_mapping systemBankListMapping];
    RKObjectMapping *listMethodMapping = [_mapping methodListMapping];
    RKObjectMapping *paymentMapping = [_mapping confirmedOrderDetailMapping];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *formRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_FORM_KEY
                                                                                toKeyPath:API_FORM_KEY
                                                                              withMapping:formMapping];
    
    RKRelationshipMapping *paymentRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_FORM_PAYMENT_KEY
                                                                                   toKeyPath:API_ORDER_FORM_PAYMENT_KEY
                                                                                 withMapping:paymentMapping];
    
    RKRelationshipMapping *orderRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_ORDER_FORM_KEY
                                                                                 toKeyPath:API_ORDER_FORM_KEY
                                                                               withMapping:orderMapping];
    
    RKRelationshipMapping *bankAccountRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_BANK_ACCOUNT_KEY
                                                                                       toKeyPath:API_BANK_ACCOUNT_KEY
                                                                                     withMapping:bankMapping];
    RKRelationshipMapping *listBankAccountRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_BANK_ACCOUNT_LIST_KEY
                                                                                           toKeyPath:API_BANK_ACCOUNT_LIST_KEY
                                                                                         withMapping:listBankMapping];
    
    RKRelationshipMapping *systemBankRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_KEY
                                                                                      toKeyPath:API_SYSTEM_BANK_KEY
                                                                                    withMapping:systemBankMapping];
    RKRelationshipMapping *listSystemBankRel =[RKRelationshipMapping relationshipMappingFromKeyPath:API_SYSTEM_BANK_LIST_KEY
                                                                                          toKeyPath:API_SYSTEM_BANK_LIST_KEY
                                                                                        withMapping:listSystemBankMapping];
    
    RKRelationshipMapping *methodRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_METHOD_KEY
                                                                                   toKeyPath:API_METHOD_KEY
                                                                                 withMapping:methodMapping];
    RKRelationshipMapping *listMethodRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_METHOD_LIST_KEY
                                                                                       toKeyPath:API_METHOD_LIST_KEY
                                                                                     withMapping:listMethodMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:formRel];
    
    [formMapping addPropertyMapping:bankAccountRel];
    [bankMapping addPropertyMapping:listBankAccountRel];
    
    [formMapping addPropertyMapping:systemBankRel];
    [systemBankMapping addPropertyMapping:listSystemBankRel];
    
    [formMapping addPropertyMapping:methodRel];
    [methodMapping addPropertyMapping:listMethodRel];
    
    [formMapping addPropertyMapping:paymentRel];
    [formMapping addPropertyMapping:orderRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}

@end
