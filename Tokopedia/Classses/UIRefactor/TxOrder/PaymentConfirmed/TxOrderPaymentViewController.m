//
//  TxOrderPaymentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

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

#import "RequestOrderData.h"
#import "AlertInfoView.h"

#import "ListRekeningBank.h"

#import "NSNumberFormatter+IDRFormater.h"

@interface TxOrderPaymentViewController ()<UITableViewDataSource, UITableViewDelegate, TKPDAlertViewDelegate,SettingBankAccountViewControllerDelegate, GeneralTableViewControllerDelegate, SettingBankNameViewControllerDelegate,UITextFieldDelegate,UITextViewDelegate, UIScrollViewDelegate, SuccessPaymentConfirmationDelegate, TokopediaNetworkManagerDelegate, TKPDPhotoPickerDelegate>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isNewRekening;
    BOOL _isFinishRequestForm;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    NSArray *_bankAccount;
    
    TKPDPhotoPicker *_photoPicker;
    UIAlertView *_loadingAlertView;
    
    UIRefreshControl *_refreshControl;
    NSString *_invoice;
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
    
    _sectionNewRekeningCells = [NSArray sortViewsWithTagInArray:_sectionNewRekeningCells];
    _section2Cell = [NSArray sortViewsWithTagInArray:_section2Cell];
    _section3CashCells = [NSArray sortViewsWithTagInArray:_section3CashCells];
    _section1Cell = [NSArray sortViewsWithTagInArray:_section1Cell];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    self.title = _isConfirmed?TITLE_PAYMENT_EDIT_CONFIRMATION_FORM:TITLE_PAYMENT_CONFIRMATION_FORM;
    
    [_infoNominalLabel setCustomAttributedText:_infoNominalLabel.text];
    [_infoConfirmation setCustomAttributedText:_infoConfirmation.text];

    NSString *string = @"Untuk Bank selain BCA diharuskan mengisi Kantor Cabang beserta kota tempat Bank berada. \nContoh: Pondok Indah - Jakarta Selatan";
    [_branchViewLabel setCustomAttributedText:string];
    [_infoConfirmation setCustomAttributedText:_infoConfirmation.text];

    _addNewRekeningButton.layer.cornerRadius = 2;

    _isNewRekening = NO;
    
    [_dataInput setObject:[NSDate date] forKey:DATA_PAYMENT_DATE_KEY];
    [self doRequestGetDataConfirmation];

}

-(void)refreshView{
    [self doRequestGetDataConfirmation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [backBarButtonItem setTintColor:[UIColor whiteColor]];
        backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [backBarButtonItem setTintColor:[UIColor whiteColor]];
        backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
        self.navigationItem.rightBarButtonItem = backBarButtonItem;
    } 
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    _photoPicker = [self photoPicker];
}

- (IBAction)tapUploadProofInfo:(id)sender {
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
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
                if (_isConfirmed) [self doEditPayment];
                else [self doConfirmPayment];
            }
        }
        else
        {
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
    NSInteger sectionCount = _isFinishRequestForm?10:0;
    return sectionCount;
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
    if (([self isPaymentTypeDefault]||[self isPaymentTypeSaldoTokopedia]) && (section == 2 || section == 3 || section == 4 || section == 5 || section == 6)) {
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
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 6.0;
                
                NSDictionary *attributes = @{
                                             NSFontAttributeName: FONT_GOTHAM_BOOK_16,
                                             NSParagraphStyleAttributeName: style,
                                             };
                
                NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_invoice?:@""
                                                                                     attributes:attributes];
                
                CGRect rect = [attributedText boundingRectWithSize:(CGSize){[UIScreen mainScreen].bounds.size.width - 60, CGFLOAT_MAX}
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil];
                return rect.size.height + 14;
            }
            else return height;
        }
            break;
        case 1:
        {
            if (([self isPaymentTypeTransfer] || [self isPaymentTypeSaldoTokopedia] || _isNewRekening || [self isPaymentTypeDefault]) && indexPath.row == 2) {
                return 0;
            }
            if(indexPath.row == 3)
            {
                if ([self isPaymentTypeSaldoTokopedia] || [self isPaymentTypeDefault])
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
            if ([self isPaymentTypeDefault]) {
                return 0;
            }
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
            if ([self isPaymentTypeDefault]) {
                return 0;
            }
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
            if ([self isPaymentTypeDefault]) {
                return 0;
            }
            if (![self isPaymentTypeTransfer] && indexPath.row == 0) {
                return 0;
            }
            if ([self isPaymentTypeSaldoTokopedia]) {
                return 0;
            }
            break;
        case 6:
            if ([self isPaymentTypeDefault]) {
                return 0;
            }
            if ([self isPaymentTypeSaldoTokopedia] || _isConfirmed) {
                return 0;
            }
            return 106;
            break;
        case 7:
            return _markCell.frame.size.height;
            break;
        case 8:
            if ([self isPaymentTypeDefault]) {
                return 0;
            }
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
    if (([self isPaymentTypeDefault]||[self isPaymentTypeSaldoTokopedia]) && (section == 2 || section == 3 || section == 4 || section == 5 || section == 6)) {
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

#pragma mark - Request Get Transaction Order Payment Confirmation
-(void)doRequestGetDataConfirmation{

    NSString * confirmationID = [[_paymentID valueForKey:@"description"] componentsJoinedByString:@"~"];
    
    if (_isConfirmed) {
        [self doRequestDataEditConfirmPaymentID:confirmationID];
    } else {
        [self doRequestDataConfirmPaymentID:confirmationID];
    }
}

-(void)doRequestDataEditConfirmPaymentID:(NSString*)paymentID{
    [self isLoading:YES];
    [RequestOrderData fetchDataEditConfirmationID:paymentID success:^(TxOrderPaymentEditForm *data) {
        [self isLoading:NO];
        [self setDefaultDataConfirmed:data];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [self isLoading:NO];
    }];
}

-(void)isLoading:(BOOL)isLoading{
    _isFinishRequestForm = !isLoading;
    
    if (isLoading) {
        [_tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
        [_refreshControl beginRefreshing];
    } else {
        _tableView.contentOffset = CGPointZero;
        [_refreshControl endRefreshing];
    }
}

-(void)doRequestDataConfirmPaymentID:(NSString*)paymentID{
    
    [self isLoading:YES];
    [RequestOrderData fetchDataConfirmConfirmationID:paymentID success:^(TxOrderConfirmPaymentFormForm *data) {
        [self isLoading:NO];
        [self setDefaultDataConfirmation:data];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [self isLoading:NO];
    }];
}

#pragma mark - Request Confirm Payment
-(void)doEditPayment{
    [self showLoadingView];
    
    NSString * paymentID = [[_paymentID valueForKey:@"description"] componentsJoinedByString:@"~"];
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    SystemBankAcount *systemBank = [self getSelectedSystemBank];
    BankAccountFormList *bank = [self getSelectedAccountBank];
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY]?:[NSDate date];
    NSString *totalPayment = [_totalPaymentTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *bankAccountID = _isNewRekening?@"0":bank.bank_account_id?:@"";
    
    [RequestOrderAction fetchEditPaymentWithMethod:method
                                              systemBankID:systemBank.sysbank_id?:@""
                                               bankAccount:bank
                                                 paymentID:paymentID?:@""
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

-(void)doConfirmPayment{
    [self showLoadingView];
    
    NSString * paymentID = [[_paymentID valueForKey:@"description"] componentsJoinedByString:@"~"];
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    TxOrderConfirmPaymentFormForm *form = [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY];
    SystemBankAcount *systemBank = [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY];
    BankAccountFormList *bank = [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY];
    NSDate *paymentDate = [_dataInput objectForKey:DATA_PAYMENT_DATE_KEY]?:[NSDate date];
    NSString *totalPayment = [_totalPaymentTextField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *bankAccountID = _isNewRekening?@"0":bank.bank_account_id?:@"";
    
    [RequestOrderAction fetchConfirmPaymentWithImageObject:[self getImageObject]
                                         token:form.token?:@""
                                        method:method
                                  systemBankID:systemBank.sysbank_id?:@""
                                   bankAccount:bank
                                     paymentID:paymentID?:@""
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
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSInteger paymentAmount = [self getPaymentOrder];
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
        vc.totalPaymentValue = [NSString stringWithFormat:@"Rp %@,-",price];
        vc.methodName = method.method_name;
        [viewControllers replaceObjectAtIndex:viewControllers.count-1 withObject:vc];
        self.navigationController.viewControllers = viewControllers;
        
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

-(BOOL)isPaymentTypeDefault
{
    MethodList *method = [_dataInput objectForKey:DATA_SELECTED_PAYMENT_METHOD_KEY];
    NSInteger paymentType = [method.method_id integerValue];
    return (paymentType == TYPE_PAYMENT_DEFAULT);
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

    NSString *bankAccountString = selectedBank.bank_account_name?:@"Pilih Akun Bank";
    
    if (cell == _section0Cell[0]) {
        UILabel *invoiceLabel = [_section0Cell[indexPath.row] detailTextLabel];
        textString = _invoice;
        [invoiceLabel setCustomAttributedText:_invoice];
    }
    if (cell == _section0Cell[1]) {
        if ([self isPaymentTypeSaldoTokopedia]) {
            double fixed_order_saldo_left_amount;
            if (!_isConfirmed) {
                fixed_order_saldo_left_amount = [form.order.order_left_amount doubleValue]  - [form.order.order_confirmation_code doubleValue];
            } else {
                fixed_order_saldo_left_amount = [formIsConfirmed.payment.order_left_amount doubleValue]  - [formIsConfirmed.payment.order_confirmation_code doubleValue];
            }
            NSString *fixed_order_saldo_left_amount_idr = [[NSNumberFormatter IDRFormarter] stringFromNumber:[NSNumber numberWithInteger:fixed_order_saldo_left_amount]];
            textString = fixed_order_saldo_left_amount_idr;
        } else {
            textString = (_isConfirmed)?formIsConfirmed.payment.order_left_amount_idr:form.order.order_left_amount_idr;
        }
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
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(SystemBankAcount*)getSelectedSystemBank{
    return [_dataInput objectForKey:DATA_SELECTED_SYSTEM_BANK_KEY]?:[SystemBankAcount new];
}

-(BankAccountFormList *)getSelectedAccountBank{
    return [_dataInput objectForKey:DATA_SELECTED_BANK_ACCOUNT_KEY]?:[BankAccountFormList new];
}

-(NSString*)getPassword{
    return [_dataInput objectForKey:DATA_PASSWORD_KEY]?:@"";
}

-(NSString*)getDepositorName{
    return [_dataInput objectForKey:DATA_DEPOSITOR_KEY]?:@"";
}

-(BOOL)isValidPaymentType{
    if ([self isPaymentTypeDefault]) {
        return NO;
    }
    return YES;
}

-(NSString *)errorNillBankAccountName{
    return @"Nama Pemilik Akun Bank harus diisi";
}

-(NSString *)errorNillBankAcountNumber{
     return @"Nomor Rekening harus diisi";
}

-(NSString *)errorNillBankName{
    return @"Nama Bank harus diisi";
}

-(NSString *)errorNilBankBranchName{
    return @"Nama Cabang Bank harus diisi";
}

-(NSString*)errorNillSystemBank{
    return @"Bank Tujuan belum dipilih";
}

-(NSString*)errorNillAccountBank{
    return @"Akun Bank belum dipilih";
}

-(NSString*)errorNillPasswordTokopedia{
    return @"Kata sandi harus diisi";
}

-(NSString*)errorNilDepositorName{
    return @"Nama Penyetor harus diisi";
}

-(NSString*)errorInvalidPaymentAmount{
    NSString *error = [NSString stringWithFormat:@"Jumlah pembayaran yang diinput tidak mencukupi. Total Pembayaran sebesar Rp %zd,-",[self getPaymentOrderLeft]];
    return error;
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if (![self isValidPaymentType]) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Pilih metode pembayaran"] delegate:self];
        [alert show];
        return NO;
    }
    
    if ([self isPaymentTypeBank] && _isNewRekening) {
        if (![self getSelectedAccountBank].bank_account_name || [[self getSelectedAccountBank].bank_account_name isEqualToString:@""]) {
            [errorMessage addObject:[self errorNillBankAccountName]];
            isValid = NO;
        }
        if (![self getSelectedAccountBank].bank_account_number || [[self getSelectedAccountBank].bank_account_number isEqualToString:@""]) {
            [errorMessage addObject:[self errorNillBankAcountNumber]];
            isValid = NO;
        }
        if (![self getSelectedAccountBank].bank_name) {
            [errorMessage addObject:[self errorNillBankName]];
            isValid = NO;
        }
        if (![self getSelectedAccountBank].bank_branch || [[self getSelectedAccountBank].bank_branch isEqualToString:@""]) {
            [errorMessage addObject:[self errorNilBankBranchName]];
            isValid = NO;
        }
        if (![self getSelectedSystemBank].sysbank_id) {
            [errorMessage addObject:[self errorNillSystemBank]];
            isValid = NO;
        }
    }
    else if ([self isPaymentTypeBank]) {
        if (![self getSelectedSystemBank].sysbank_id || [[self getSelectedSystemBank].sysbank_id isEqualToString:@""]) {
            [errorMessage addObject:[self errorNillSystemBank]];
            isValid = NO;
        }
        if (![self getSelectedAccountBank].bank_id) {
            [errorMessage addObject:[self errorNillAccountBank]];
            isValid = NO;
        }
    }
    else if ([self isPaymentTypeSaldoTokopedia])
    {
        if (![self getPassword] || [[self getPassword] isEqualToString:@""]) {
            [errorMessage addObject:[self errorNillPasswordTokopedia]];
            isValid = NO;
        }
    }
    else if ([self isPaymentTypeTransfer]) {
        if (![self getDepositorName] || [[self getDepositorName] isEqualToString:@""]) {
            [errorMessage addObject:[self errorNilDepositorName]];
            isValid = NO;
        }
        if (![self getSelectedSystemBank].sysbank_id) {
            [errorMessage addObject:[self errorNillSystemBank]];
            isValid = NO;
        }
    }
    
    if (![self isPaymentTypeSaldoTokopedia] && [[self getPaymentAmount] integerValue]<[self getPaymentOrderLeft]) {
        [errorMessage addObject:[self errorInvalidPaymentAmount]];
        isValid = NO;
    }

    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isValid;
}

-(NSInteger)getPaymentOrderLeft{
    NSInteger paymentOrderLeft = (_isConfirmed)?
    ([[self getPaymentEditForm].payment.order_left_amount integerValue] - [[self getPaymentEditForm].payment.order_confirmation_code integerValue]):
    ([[self getPaymentConfirmationForm].order.order_left_amount integerValue] - [[self getPaymentConfirmationForm].order.order_confirmation_code integerValue]);
    return paymentOrderLeft;
}

-(NSInteger)getPaymentOrder{
    NSInteger paymentOrderLeft = (_isConfirmed)?
    [[self getPaymentEditForm].payment.order_left_amount integerValue]:
    [[self getPaymentAmount] integerValue];
    return paymentOrderLeft;
}

-(TxOrderConfirmPaymentFormForm*)getPaymentConfirmationForm{
    return [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMATION_KEY]?:[TxOrderConfirmPaymentFormForm new];
}

-(TxOrderPaymentEditForm*)getPaymentEditForm{
    return [_dataInput objectForKey:DATA_DETAIL_ORDER_CONFIRMED_KEY]?:[TxOrderPaymentEditForm new];
}

-(NSString*)getPaymentAmount{
    NSString *amount = _totalPaymentTextField.text?:@"";
    amount = [amount stringByReplacingOccurrencesOfString:@"." withString:@""];
    return  amount;
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
    
    NSString *invoice = [[form.order.order_invoice valueForKey:@"description"] componentsJoinedByString:@",\n"];
    _invoice = invoice;
}

-(void)setDefaultDataConfirmation:(TxOrderConfirmPaymentFormForm*)form
{
    MethodList *selectedMethod =[MethodList new];
    selectedMethod.method_id = [form.method[0] method_id];
    selectedMethod.method_name = [form.method[0] method_name];
    
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
    
    NSString *invoice = [[[form.order.order_invoice componentsSeparatedByString:@","] valueForKey:@"description"] componentsJoinedByString:@",\n"];
    _invoice = invoice;
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
    else if (textField == _depositorTextField)
    {
        if (range.location == 0 && range.length == 0 && [string isEqualToString:@" "])
            return NO;
        else
            return YES;
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

@end
