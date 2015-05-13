//
//  TxOrderPaymentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderObjectMapping.h"
#import "TxOrderPaymentEdit.h"


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

@interface TxOrderPaymentViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate,SettingBankAccountViewControllerDelegate, GeneralTableViewControllerDelegate, SettingBankNameViewControllerDelegate,UITextFieldDelegate,UITextViewDelegate, UIScrollViewDelegate, SuccessPaymentConfirmationDelegate, TokopediaNetworkManagerDelegate>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isNewRekening;
    
    TxOrderObjectMapping *_mapping;
    
    TokopediaNetworkManager *_networkManager;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectManagerConfirmPayment;
    __weak RKManagedObjectRequestOperation *_requestConfirmPayment;
    
    NSOperationQueue *_operationQueue;
    
    BOOL _isFinishRequestForm;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    NSArray *_bankAccount;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *sectionNewRekeningCells;

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
    _section3CashCells = [NSArray sortViewsWithTagInArray:_section3CashCells];
    
    self.title = _isConfirmed?TITLE_PAYMENT_EDIT_CONFIRMATION_FORM:TITLE_PAYMENT_CONFIRMATION_FORM;
    

    
    [_infoNominalLabel setCustomAttributedText:_infoNominalLabel.text];
    [_infoConfirmation setCustomAttributedText:_infoConfirmation.text];

    NSString *string = @"Masukkan password login Tokopedia anda. \n\nProduk yang sudah dipesan dan dikonfirmasikan pembayarannya tidak dapat dibatalkan.";
    [_passwordLabel setCustomAttributedText:string];

    string = @"Untuk Bank selain BCA diharuskan mengisi Kantor Cabang beserta kota tempat Bank berada. \nContoh: Pondok Indah - Jakarta Selatan";
    [_branchViewLabel setCustomAttributedText:string];

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
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    NSArray *selectedOrder = [_dataInput objectForKey:DATA_SELECTED_ORDER_KEY];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == TAG_BAR_BUTTON_TRANSACTION_DONE) {
            if ([self isValidInput]) {
                [self configureRestKitConfirmPayment];
                [self requestConfirmPayment:_dataInput];
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
        [_tableView reloadData];
    }
}


#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isFinishRequestForm)
        return (([self isPaymentTypeBank]&&_isNewRekening) || [self isPaymentTypeTransfer])?5:4;
    else
        return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = 0;
    switch (section) {
        case 0:
            rowCount = _section0Cell.count;
            break;
        case 1:
            if ([self isPaymentTypeBank]&&_isNewRekening)
                rowCount = 2;
            else rowCount = ([self isPaymentTypeBank])?_section1Cell.count:2;
            break;
        case 2:
            if ([self isPaymentTypeBank]&&_isNewRekening)
                rowCount = _sectionNewRekeningCells.count;
            else if ([self isPaymentTypeBank])
                rowCount = _section2Cell.count;
            else rowCount = 1;
            break;
        case 3:
            if ([self isPaymentTypeBank]&&_isNewRekening)
                rowCount = _section2Cell.count;
            else if ([self isPaymentTypeTransfer])
                rowCount = _section3CashCells.count;
            else rowCount = 1;
            break;
        case 4:
            rowCount = 1;
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
            if ([self isPaymentTypeBank]&&_isNewRekening)
                cell = _sectionNewRekeningCells[indexPath.row];
            else if([self isPaymentTypeBank])
                cell = _section2Cell[indexPath.row];
            else if ([self isPaymentTypeTransfer])
                cell = _infoCell;
            else
                cell = _markCell;
            break;
        case 3:
            if ([self isPaymentTypeBank]&&_isNewRekening)
                cell = _section2Cell[indexPath.row];
            else if([self isPaymentTypeBank])
                cell = _markCell;
            else if ([self isPaymentTypeTransfer])
                cell = _section3CashCells[indexPath.row];
            else
                cell = _passwordTokopediaCell;
            break;
        case 4:
                cell = _markCell;
            break;
        default:
            break;
    }
    [self adjustDetailTextLabelCell:cell atIndextPath:indexPath];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table View Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isPaymentTypeBank] && _isNewRekening && section == 2)
        return _addNewRekeningHeaderView.frame.size.height;
    else return 10;
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
        case 2:
            if ([self isPaymentTypeBank]&&_isNewRekening)
                return [_sectionNewRekeningCells[indexPath.row] frame].size.height;
            else if([self isPaymentTypeBank])
                return [_section2Cell[indexPath.row] frame].size.height;
            else if ([self isPaymentTypeTransfer])
                return _infoCell.frame.size.height;
            else
                return _markCell.frame.size.height;
            break;
        case 3:
            if ([self isPaymentTypeBank]&&_isNewRekening)
                return [_section2Cell[indexPath.row] frame].size.height;
            else if([self isPaymentTypeBank])
                return _markCell.frame.size.height;
            else if ([self isPaymentTypeTransfer])
            return  [_section3CashCells[indexPath.row] frame].size.height;
            else
                return _passwordTokopediaCell.frame.size.height;
            break;
        case 4:
            return _markCell.frame.size.height;
            break;
        default:
            break;
    }
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3 && [self isPaymentTypeSaldoTokopedia]) {
        return _passwordFooterView.frame.size.height;
    }

    NSInteger sectionCount = (([self isPaymentTypeBank]&&_isNewRekening) || [self isPaymentTypeTransfer])?5:4;
    if (section == sectionCount-1) {
        return _section3FooterView.frame.size.height;
    }
    if (section == 2 && _isNewRekening) {
        return  _branchFooterView.frame.size.height;
    }
    else if (section == 2 && [self isPaymentTypeBank] && !_isNewRekening)
    {
        return _section2FooterView.frame.size.height;
    }
    if (section == 1) {
        if ([self isPaymentTypeBank] && !_isNewRekening) return _addNewRekeningFooterView.frame.size.height;
        else return 0;
    }

    return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self isPaymentTypeBank] && _isNewRekening && section == 2)
        return _addNewRekeningHeaderView;
    else return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3 && [self isPaymentTypeSaldoTokopedia]) {
        return _passwordFooterView;
    }
    NSInteger sectionCount = (([self isPaymentTypeBank]&&_isNewRekening) || [self isPaymentTypeTransfer])?5:4;
    if (section == sectionCount-1) {
        return _section3FooterView;
    }
    
    if (section == 2 && _isNewRekening) {
        return  _branchFooterView;
    }
    else if (section == 2 && [self isPaymentTypeBank] && !_isNewRekening)
    {
        return _section2FooterView;
    }
    
    if (section == 1) {
        if ([self isPaymentTypeBank] && !_isNewRekening) return _addNewRekeningFooterView;
        else return nil;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    
    switch (indexPath.section) {
        case 1:
        {
            if (indexPath.row == 0) {
                AlertDatePickerView *paymentDate = [AlertDatePickerView newview];
                paymentDate.delegate = self;
                NSDate *date = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY];
                paymentDate.currentdate = date;
                paymentDate.tag = 11;
                paymentDate.isSetMinimumDate = NO;
                [paymentDate show];
            }
            if(indexPath.row==1 &&_isFinishRequestForm) {
                [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_PAYMENT_METHOD_KEY];
                [self pushToGeneralViewControllerAtIndextPath:indexPath];
            }
            else if (indexPath.row == 2 && _isFinishRequestForm)
            {
                if (_bankAccount.count>0) {
                    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_BANK_ACCOUNT_KEY];
                    [self pushToGeneralViewControllerAtIndextPath:indexPath];
                }
            }
            break;
        }
        case 2:
        {
            if (indexPath.row==0)
            {
                if([self isPaymentTypeBank]&&_isNewRekening)
                {
                    BankAccountFormList *bank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
                    SettingBankNameViewController *vc = [SettingBankNameViewController new];
                    vc.data = @{API_BANK_ID_KEY : @(bank.bank_id)};
                    vc.delegate = self;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else if ([self isPaymentTypeBank]) {
                    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SYSTEM_BANK_KEY];
                    [self pushToGeneralViewControllerAtIndextPath:indexPath];
                }
                //else if ([self isPaymentTypeSaldoTokopedia])
                    //[_markTextView becomeFirstResponder];
                else if ([self isPaymentTypeTransfer]) {
                    AlertInfoPaymentConfirmationView *alertInfo = [AlertInfoPaymentConfirmationView newview];
                    alertInfo.delegate = self;
                    [alertInfo show];
                }
            }
            else if (indexPath.row == 1)
            {
                if([self isPaymentTypeBank]&&_isNewRekening)
                     [_accountNameTextField becomeFirstResponder];
                else if ([self isPaymentTypeBank])
                    [_totalPaymentTextField becomeFirstResponder];
            }
        }
        break;
        case 3:
            if ([self isPaymentTypeBank]&&_isNewRekening)
            {
                if (indexPath.row==0)
                {
                    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SYSTEM_BANK_KEY];
                    [self pushToGeneralViewControllerAtIndextPath:indexPath];
                }
                else if (indexPath.row == 1)
                    [_totalPaymentTextField becomeFirstResponder];
            }
            if ([self isPaymentTypeTransfer]) {
                if (indexPath.row == 0)
                    [_depositorTextField becomeFirstResponder];
                if (indexPath.row == 1)
                {
                    [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_SYSTEM_BANK_KEY];
                    [self pushToGeneralViewControllerAtIndextPath:indexPath];
                }
                if (indexPath.row == 2) {
                    [_totalPaymentTextField becomeFirstResponder];
                }
            }
            else if ([self isPaymentTypeSaldoTokopedia])
                 [_passwordTextField becomeFirstResponder];
            else
                //[_markTextView becomeFirstResponder];
        break;
        case 4:
            //[_markTextView becomeFirstResponder];
            break;
        default:
            break;
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
-(void)cancelConfirmPayment
{
    [_requestConfirmPayment cancel];
    _requestConfirmPayment = nil;
    [_objectManagerConfirmPayment.operationQueue cancelAllOperations];
    _objectManagerConfirmPayment = nil;
}

-(void)configureRestKitConfirmPayment
{
    _objectManagerConfirmPayment = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_TX_ORDER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerConfirmPayment addResponseDescriptor:responseDescriptor];
    
}

-(void)requestConfirmPayment:(id)object
{
    if (_requestConfirmPayment.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userInfo = (NSDictionary*)object;
    NSArray *selectedOrder = [userInfo objectForKey:DATA_SELECTED_ORDER_KEY];
    MethodList *method = [userInfo objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    SystemBankAcount *systemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    BankAccountFormList *bank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    
    NSMutableArray *confirmationIDs = [NSMutableArray new];
    for (TxOrderConfirmationList *detail in selectedOrder) {
        [confirmationIDs addObject:detail.confirmation.confirmation_id];
    }
    NSString * confirmationID = [[confirmationIDs valueForKey:@"description"] componentsJoinedByString:@"~"];
    NSString *paymentID = _paymentID?:@"";
    NSString *token = form.token?:@"";
    NSString *methodID = method.method_id?:@"";
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY];
    NSString *paymentAmount = [_dataInput objectForKey:DATA_TOTAL_PAYMENT_KEY]?:@"";
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:paymentDate];
    NSNumber *year = @([components year]);
    NSNumber *month = @([components month]);
    NSNumber *day = @([components day]);
    NSString *comment = [_dataInput objectForKey:DATA_MARK_KEY]?:@"";
    NSString *password = [_dataInput objectForKey:DATA_PASSWORD_KEY]?:@"";
    NSString *systemBankID = systemBank.sysbank_id?:@"";
    NSNumber *bankID = @(bank.bank_id);
    NSString *bankName = bank.bank_name?:@"";
    NSString *bankAccountName = bank.bank_account_name?:@"";
    NSString *bankAccountBranch = bank.bank_branch?:@"";
    NSString *bankAccountNumber = bank.bank_account_number?:@"";
    NSString *bankAccountID = _isNewRekening?@"0":bank.bank_account_id;
    NSString *depositor = [_dataInput objectForKey:DATA_DEPOSITOR_KEY]?:@"";
    NSString *action = _isConfirmed?ACTION_EDIT_PAYMENT:ACTION_CONFIRM_PAYMENT;
    
    //TODO:: File name & file path
    
    NSDictionary* param = @{API_ACTION_KEY : action,
                            API_PAYMENT_ID_KEY : paymentID,
                            API_CONFIRMATION_CONFIRMATION_ID_KEY : confirmationID,
                            API_TOKEN_KEY : token,
                            API_METHOD_ID_KEY : methodID,
                            API_ORDER_PAYMENT_AMOUNT_KEY : paymentAmount,
                            API_PAYMENT_DAY_KEY : day,
                            API_PAYMENT_MONTH_KEY: month,
                            API_PAYMENT_YEAR_KEY :year,
                            API_PAYMENT_COMMENT_KEY : comment,
                            API_PASSWORD_KEY : password,
                            API_PASSWORD_DEPOSIT_KEY :password,
                            API_DEPOSITOR_KEY : depositor,
                            API_BANK_ID_KEY : bankID,
                            API_BANK_NAME_KEY : bankName,
                            API_BANK_ACCOUNT_NAME_KEY : bankAccountName,
                            API_BANK_ACCOUNT_BRANCH_KEY : bankAccountBranch,
                            API_BANK_ACCOUNT_NUMBER_KEY : bankAccountNumber,
                            API_BANK_ACCOUNT_ID_KEY : bankAccountID,
                            API_SYSTEM_BANK_ID_KEY : systemBankID,
                            
                            };
    
//#if DEBUG
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
//    
//    _requestConfirmPayment = [_objectManagerConfirmPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_TX_ORDER parameters:paramDictionary];
//#else
    _requestConfirmPayment = [_objectManagerConfirmPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
//#endif
    
    [_requestConfirmPayment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessConfirmPayment:mappingResult withOperation:operation];
        [timer invalidate];
        _tableView.tableFooterView = nil;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureConfirmPayment:error];
        [timer invalidate];
        _tableView.tableFooterView = nil;
    }];
    
    [_operationQueue addOperation:_requestConfirmPayment];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutConfirmPayment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessConfirmPayment:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessConfirmPayment:object];
    }
}

-(void)requestFailureConfirmPayment:(id)object
{
    [self requestProcessConfirmPayment:object];
}

-(void)requestProcessConfirmPayment:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *order = stat;
            BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(order.message_error)
                {
                    NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                if(order.result.is_success == 1)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TX_ORDER_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                    if (_isConfirmed) {
                        NSArray *array = order.message_status?:[[NSArray alloc] initWithObjects:@"Anda telah berhasil mengubah konfirmasi pembayaran", nil];
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
            }
        }
        else{
            
            [self cancelConfirmPayment];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutConfirmPayment
{
    [self cancelConfirmPayment];
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
    
    SystemBankAcount *selectedSystemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    MethodList *selectedMethod = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    BankAccountFormList *selectedBank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    
    NSString *systemBankString = (!selectedSystemBank.sysbank_name)?@"Pilih Rekening Tujuan":[NSString stringWithFormat:@"%@",selectedSystemBank.sysbank_name];
    
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    NSString *paymentDateString = [formatter stringFromDate:paymentDate];
    
    NSArray *invoices =(_isConfirmed)?formIsConfirmed.order.order_invoice:[form.order.order_invoice componentsSeparatedByString:@","];
    NSString *invoice = [[invoices valueForKey:@"description"] componentsJoinedByString:@",\n"];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0)
            {
                UILabel *invoiceLabel = [_section0Cell[indexPath.row] detailTextLabel];
                invoiceLabel.numberOfLines = 0;
                textString = invoice;
                [invoiceLabel setCustomAttributedText:invoice];
                
                //Calculate the expected size based on the font and linebreak mode of your label
                CGSize maximumLabelSize = CGSizeMake(190,9999);
                
                CGSize expectedLabelSize = [textString sizeWithFont:invoiceLabel.font
                                                  constrainedToSize:maximumLabelSize
                                                      lineBreakMode:invoiceLabel.lineBreakMode];
                
                //adjust the label the the new height.
                CGRect newFrame = invoiceLabel.frame;
                newFrame.size.height = expectedLabelSize.height + 26;
                invoiceLabel.frame = newFrame;
            }
            else if (indexPath.row == 1) textString = (_isConfirmed)?formIsConfirmed.payment.order_left_amount_idr:form.order.order_left_amount_idr;
            break;
        case 1:
            if (indexPath.row == 0) textString = paymentDateString;
            else if (indexPath.row == 1)textString = selectedMethod.method_name;
            else if (indexPath.row == 2)
            {
                if (_bankAccount.count==0)
                {
                    textString = @"Belum Memiliki Akun Bank";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else
                {
                    textString = selectedBank.bank_account_name?:@"Pilih Akun Bank";
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:(0.f/255.f) green:122.f/255.f blue:255.f/255.f alpha:1];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            break;
        case 2:
            if (indexPath.row ==0)
            {
                if ([self isPaymentTypeBank]&&_isNewRekening)textString = selectedBank.bank_name?:@"Pilih Nama Bank";
                else if ([self isPaymentTypeBank]) textString = systemBankString;
            }
            break;
        case 3:
            if (indexPath.row == 0 && [self isPaymentTypeBank]&&_isNewRekening)
                textString = systemBankString;
            if ((indexPath.row == 1)&&[self isPaymentTypeTransfer])
                textString = systemBankString;
            break;
        case 4:
            
        default:
            break;
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
    else if ([self isPaymentTypeTransfer]) {}
    NSString *paymentAmount = [_dataInput objectForKey:DATA_TOTAL_PAYMENT_KEY]?:@"";
    
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    NSString *paymentOrderLeft = (_isConfirmed)?formIsConfirmed.payment.order_left_amount:form.order.order_left_amount;
    
    if (![self isPaymentTypeSaldoTokopedia] && [paymentAmount integerValue]<[paymentOrderLeft integerValue]) {
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
        if ([form.bank_account.bank_account_id_chosen integerValue] == bank.bank_account_id) {
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
    NSDate *paymentDate = [[NSDate alloc]init];
    paymentDate = [dateFormatter dateFromString:dateString]?:[NSDate date];
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
    BankAccountFormList *bankAccount = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    NSIndexPath *indexpath;
    NSString *name;
    NSInteger bankid;
    indexpath = [data objectForKey:API_BANK_ID_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
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
    BankAccountFormList *bankAcount = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
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
    if (_activeTextField == _totalPaymentTextField) {
        [_tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell: _section2Cell[1]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
