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

#import "DBManager.h"

@interface TxOrderPaymentViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate,SettingBankAccountViewControllerDelegate, GeneralTableViewControllerDelegate, SettingBankNameViewControllerDelegate,UITextFieldDelegate,UITextViewDelegate, UIScrollViewDelegate, SuccessPaymentConfirmationDelegate>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isNewRekening;
    
    TxOrderObjectMapping *_mapping;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectManagerConfirmPayment;
    __weak RKManagedObjectRequestOperation *_requestConfirmPayment;
    
    NSOperationQueue *_operationQueue;
    
    BOOL _isFinishRequestForm;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
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

@implementation TxOrderPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [TxOrderObjectMapping new];
    
    _sectionNewRekeningCells = [NSArray sortViewsWithTagInArray:_sectionNewRekeningCells];
    _section3CashCells = [NSArray sortViewsWithTagInArray:_section3CashCells];
    
    self.title = TITLE_PAYMENT_CONFIRMATION_FORM;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tidak" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ya" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor blackColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = backBarButtonItem;
    
    [_infoNominalLabel multipleLineLabel:_infoNominalLabel];
    [_infoConfirmation multipleLineLabel:_infoConfirmation];

    NSString *string = @"Masukkan password login Tokopedia anda. \n\nProduct yang sudah dipesan dan dikonfirmasikan pembayarannya tidak dapat dibatalkan.";
    _passwordLabel.text = string;
    [_passwordLabel multipleLineLabel:_passwordLabel];

    string = @"Untuk Bank selain BCA diharuskan mengisi Kantor Cabang beserta kota tempat Bank berada. \nContoh: Pondok Indah - Jakarta Selatan";
    _branchViewLabel.text = string;
    [_branchViewLabel multipleLineLabel:_branchViewLabel];

    _addNewRekeningButton.layer.cornerRadius = 2;
    
    [_dataInput addEntriesFromDictionary:_data];
    
    if (_isConfirmed)[self configureRestKitIsConfirmed];else[self configureRestKit];
    [self request];
        
    _isNewRekening = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [_dataInput setObject:[NSDate date] forKey:DATA_PAYMENT_DATE_KEY];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        if (button.tag == TAG_BAR_BUTTON_TRANSACTION_DONE) {
            if ([self isValidInput]) {
                [self configureRestKitConfirmPayment];
                [self requestConfirmPayment:_dataInput];
            }
        }
        else [self.navigationController popViewControllerAnimated:YES];
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
            UILabel *invoiceLabel = [_section0Cell[indexPath.row] detailTextLabel];
            invoiceLabel.numberOfLines = 0;
            invoiceLabel.textAlignment = NSTextAlignmentRight;
            [invoiceLabel multipleLineLabel:invoiceLabel];
            CGFloat height = [_section0Cell[indexPath.row] frame].size.height;
            if (indexPath.row == 0) return (invoiceLabel.frame.size.height+30);
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
                paymentDate.currentdate = [NSDate date];
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
                [_dataInput setObject:indexPath forKey:DATA_INDEXPATH_BANK_ACCOUNT_KEY];
                [self pushToGeneralViewControllerAtIndextPath:indexPath];
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
                else if ([self isPaymentTypeSaldoTokopedia])
                    [_markTextView becomeFirstResponder];
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
                [_markTextView becomeFirstResponder];
        break;
        case 4:
            [_markTextView becomeFirstResponder];
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
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

-(void)configureRestKit
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
    
}

-(void)configureRestKitIsConfirmed
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
    
}

-(void)request
{
    if (_request.isExecuting) return;
    NSTimer *timer;
    
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
    
#if DEBUG
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:@"1176" forKey:@"user_id"];
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_TX_ORDER parameters:paramDictionary];
#else
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_TX_ORDER parameters:[param encrypt]];
#endif
    
    _tableView.tableFooterView = _footerView;
    [_act startAnimating];
    _isFinishRequestForm = NO;
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        [timer invalidate];
        [_act stopAnimating];
        _tableView.tableFooterView = nil;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailure:error];
        [timer invalidate];
        [_act stopAnimating];
        _tableView.tableFooterView = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    BOOL status;
    if(_isConfirmed){
        TxOrderPaymentEdit *form = stat;
        status = [form.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    }
    else {
        TxOrderConfirmPaymentForm *form = stat;
        status = [form.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    }
    if (status) {
        [self requestProcess:object];
    }
}

-(void)requestFailure:(id)object
{
    [self requestProcess:object];
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
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
                    [self request];
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
        else{
            [self cancel];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
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
    //    confirmation_id
    //    token
    //    method_id
    //    payment_amount
    //    payment_day
    //    payment_month
    //    payment_year
    //    comments
    //    file_name
    //    file_path
    //    server_id
    //    password
    //    sysbank_id
    //    bank_id
    //    bank_name
    //    bank_account_name
    //    bank_account_branch
    //    bank_account_number
    //    bank_account_id
    //    depositor
    //    password_deposit
    
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
    NSNumber *bankID = @(bank.bank_id?:-1);
    NSString *bankName = bank.bank_name?:@"";
    NSString *bankAccountName = bank.bank_account_name?:@"";
    NSString *bankAccountBranch = bank.bank_branch?:@"";
    NSString *bankAccountNumber = bank.bank_account_number?:@"";
    NSNumber *bankAccountID = @(bank.bank_account_id);
    NSString *depositor = [_dataInput objectForKey:DATA_DEPOSITOR_KEY]?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY : ACTION_CONFIRM_PAYMENT,
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
    
#if DEBUG
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:@"1176" forKey:@"user_id"];
    
    _requestConfirmPayment = [_objectManagerConfirmPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_TX_ORDER parameters:paramDictionary];
#else
    _requestConfirmPayment = [_objectManagerConfirmPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_TX_ORDER parameters:[param encrypt]];
#endif
    
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
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if(order.result.is_success == 1)
                {
                    NSInteger paymentAmount = [[_dataInput objectForKey:DATA_TOTAL_PAYMENT_KEY] integerValue];
                    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
                    TxOrderPaymentConfirmationSuccessViewController *vc = [TxOrderPaymentConfirmationSuccessViewController new];
                    vc.delegate = self;
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setGroupingSeparator:@"."];
                    [formatter setGroupingSize:3];
                    [formatter setUsesGroupingSeparator:YES];
                    [formatter setSecondaryGroupingSize:3];
                    NSString *price = (paymentAmount>0)?[formatter stringFromNumber:@(paymentAmount)]:@"0";
                    vc.totalPaymentValue = [NSString stringWithFormat:@"Rp %@,-",price];
                    vc.methodName = method.method_name;
                    [self.navigationController pushViewController:vc animated:YES];
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
    
    NSString *systemBankString = (!selectedSystemBank.sysbank_name)?@"Pilih Rekening Tujuan":[NSString stringWithFormat:@"%@ %@ a/n %@",selectedSystemBank.sysbank_name, selectedSystemBank.sysbank_account_number, selectedSystemBank.sysbank_account_name];
    
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    NSString *paymentDateString = [formatter stringFromDate:paymentDate];
    
    NSArray *invoices =(_isConfirmed)?formIsConfirmed.order.order_invoice:[form.order.order_invoice componentsSeparatedByString:@","];
    NSString *invoice = [[invoices valueForKey:@"description"] componentsJoinedByString:@",\n"];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) textString = invoice;
            else if (indexPath.row == 1) textString = (_isConfirmed)?formIsConfirmed.payment.order_left_amount_idr:form.order.order_left_amount_idr;
            break;
        case 1:
            if (indexPath.row == 0) textString = paymentDateString;
            else if (indexPath.row == 1)textString = selectedMethod.method_name;
            else if (indexPath.row == 2)textString = selectedBank.bank_account_name?:@"Belum memiliki akun Bank";
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
        [controllerObjects addObject:@"Pilih Rekening Tujuan"];
        
        for (SystemBankAcount *systemBank in listSystemBank) {
            [controllerObjects addObject:[NSString stringWithFormat:@"%@ %@ a/n %@",systemBank.sysbank_name, systemBank.sysbank_account_number, systemBank.sysbank_account_name]];
        }
        
        controller.selectedObject = ([selectedSystemBank.sysbank_id isEqualToString:@"-1"])?@"Pilih Rekening Tujuan":[NSString stringWithFormat:@"%@ %@ a/n %@",selectedSystemBank.sysbank_name, selectedSystemBank.sysbank_account_number, selectedSystemBank.sysbank_account_name];
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
    [self.navigationController pushViewController:controller animated:YES];
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
        if (!systemBank.sysbank_id) {
            [errorMessage addObject:ERRORMESSAGE_NILL_SYSTEM_BANK];
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

    if (!isValid) {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:errorMessage,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
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
    
    NSInteger indexBankAcount;
    NSArray *bankAccountList = form.bank_account.bank_account_list;
    indexBankAcount = [bankAccountList indexOfObject:form.bank_account.bank_account_id_chosen];
    if (indexBankAcount == NSNotFound) {
        indexBankAcount = 0;
    }
        
    BankAccountFormList *selectedBank = bankAccountList[indexBankAcount];
    
    [_dataInput setObject:selectedMethod?:[MethodList new] forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    [_dataInput setObject:selectedBank?:[BankAccountFormList new] forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    [_dataInput setObject:form forKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
}

-(void)setDefaultDataConfirmation:(TxOrderConfirmPaymentFormForm*)form
{
    MethodList *selectedMethod =[MethodList new];
    selectedMethod.method_id = [form.method[3] method_id];
    selectedMethod.method_name = [form.method[3] method_name];
    
    NSArray *bankAccountList = form.bank_account;
    BankAccountFormList *selectedBank = bankAccountList[0];
    
    if ([self isPaymentTypeSaldoTokopedia]) {
        
        NSString *leftAmount = form.order.order_left_amount;
        [_dataInput setObject:leftAmount forKey:DATA_TOTAL_PAYMENT_KEY];
    }
    
    [_dataInput setObject:selectedMethod forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    [_dataInput setObject:selectedBank forKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    [_dataInput setObject:form forKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
}

#pragma mark - General View Controller
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    TxOrderPaymentEditForm *formIsConfirmed = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY];
    
    NSIndexPath *paymentMethodIndexPath = [_dataInput objectForKey:DATA_INDEXPATH_PAYMENT_METHOD_KEY];
    NSIndexPath *bankAccountIndexPath = [_dataInput objectForKey:DATA_INDEXPATH_BANK_ACCOUNT_KEY];
    NSIndexPath *systemBankIndexPath = [self.tableView indexPathForCell: _section2Cell[0]];
    
    NSArray *systemBankList =(_isConfirmed)?formIsConfirmed.sysbank_account.sysbank_list:form.sysbank_account;
     NSArray *methodList =(_isConfirmed)?formIsConfirmed.method.method_list:form.method;
    NSArray *bankAccountList = (_isConfirmed)?formIsConfirmed.bank_account.bank_account_list:form.bank_account;
    
    if (indexPath == systemBankIndexPath) {
        for (SystemBankAcount *systemBank in systemBankList) {
            if ([[NSString stringWithFormat:@"%@ %@ a/n %@",systemBank.sysbank_name, systemBank.sysbank_account_number, systemBank.sysbank_account_name] isEqualToString:(NSString*)object]) {
                [_dataInput setObject:systemBank forKey:DATA_SELECTED_SYSTEM_BANK_KEY];
            }
        }
    }
    if (indexPath == paymentMethodIndexPath) {
        for (MethodList *method in methodList) {
            if ([method.method_name isEqualToString:(NSString*)object]) {
                [_dataInput setObject:method forKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
            }
        }
    }
    
    if (indexPath == bankAccountIndexPath) {
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
    [self.navigationController popViewControllerAnimated:NO];
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
        NSString *totalPayment = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        [_dataInput setObject:totalPayment forKey:DATA_TOTAL_PAYMENT_KEY];
    }
    
    if (textField == _passwordTextField) {
        [_dataInput setObject:textField.text forKey:DATA_PASSWORD_KEY];
    }
    
    if (textField == _depositorTextField) {
        [_dataInput setObject:textField.text forKey:DATA_DEPOSITOR_KEY];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _totalPaymentTextField) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        if([string length]==0)
        {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:4];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
            textField.text = str;
            return YES;
        }
        else {
            [formatter setGroupingSeparator:@","];
            [formatter setGroupingSize:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setSecondaryGroupingSize:3];
            NSString *num = textField.text ;
            if(![num isEqualToString:@""])
            {
                num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
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

@end
