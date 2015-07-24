//
//  TransactionCCDetailViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCCDetailViewController.h"
#import "AlertPickerView.h"
#import "RequestCart.h"
#import "string_transaction.h"
#import "TransactionAction.h"
#import "TransactionCartWebViewViewController.h"
#import "AlertInfoView.h"
#import "TransactionCC.h"

#import "VTConfig.h"
#import "VTDirect.h"
#import "VTCardDetails.h"


@interface TransactionCCDetailViewController ()
<
    TKPDAlertViewDelegate,
    RequestCartDelegate,
    TransactionCartWebViewViewControllerDelegate,
    UITextFieldDelegate,
    UIWebViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewCells;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *CCNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *expDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *CVVTextField;

@end

@implementation TransactionCCDetailViewController
{
    NSMutableArray *_years;
    NSMutableArray *_months;
    NSString *_selectedMonth;
    NSString *_selectedYear;
    
    NSDictionary *_alertPickerData;
    
    RequestCart *_requestCart;
    UIAlertView *_alertLoading;
    
    UIActivityIndicatorView *_act;
    
    DataCredit *_dataCC;
    VTToken *_token;
    
    UITextField *_activeTextField;
    BOOL _isFailMaxRequest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableViewCells = [NSArray sortViewsWithTagInArray:_tableViewCells];
    
    self.title = @"Informasi Tagihan";
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Bayar" style:UIBarButtonItemStylePlain target:self action:@selector(nextButton:)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    _months = [NSMutableArray new];
    for (int i = 1; i<=12; i++) {
        NSString *month = [NSString stringWithFormat:@"%02d",i];
        [_months addObject:@{DATA_NAME_KEY:month}];
    }
    
    //Get Current Year into i2
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy"];
    int i2  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    _years = [NSMutableArray new];
    for (int i=i2; i<=i2+11; i++) {
        [_years addObject:@{DATA_NAME_KEY:[NSString stringWithFormat:@"%d",i]}];
    }
    
    _requestCart = [RequestCart new];
    _requestCart.viewController = self;
    _requestCart.delegate = self;
    
    _alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _act = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(screenRect.size.width/2, screenRect.size.height/2,50,50)];
    _act.hidesWhenStopped = YES;
    
    _isFailMaxRequest = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableViewCells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = _tableViewCells[indexPath.row];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width,1)];
    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
    [cell.contentView addSubview:lineView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UITableViewCell*)_tableViewCells[indexPath.row]).frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_activeTextField resignFirstResponder];
    _activeTextField = nil;

    switch (indexPath.row) {
        case 0:
            [_nameTextField becomeFirstResponder];
            break;
        case 1:
            [_CCNumberTextField becomeFirstResponder];
            break;
        case 2:
        {
            AlertPickerView *picker = [AlertPickerView newview];
            picker.delegate = self;
            picker.pickerCount = 2;
            picker.data = _alertPickerData;
            picker.pickerData = [_months copy];
            picker.secondPickerData = [_years copy];
            [picker show];
        }
            break;
        case 3:
            [_CVVTextField becomeFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *alertData = alertView.data;
    _selectedMonth = _months[[[alertData objectForKey:DATA_INDEX_KEY] integerValue] ][DATA_NAME_KEY];
    _selectedYear = _years[[[alertData objectForKey:DATA_INDEX_SECOND_KEY] integerValue]][DATA_NAME_KEY];
    _expDateLabel.text = [NSString stringWithFormat:@"%@/%@",_selectedMonth,_selectedYear];
    _selectedMonth = [NSString stringWithFormat:@"%zd",[[alertData objectForKey:DATA_INDEX_KEY] integerValue]+1];
    _alertPickerData = alertView.data;
}

#pragma mark - Request Delegate
-(void)actionBeforeRequest:(int)tag
{
    if(!_alertLoading.visible && !_isFailMaxRequest)
        [_alertLoading show];
    
    if (_isFailMaxRequest) {
        _isFailMaxRequest = NO;
    }
}

-(void)requestSuccessCC:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    
    TransactionCC *step1 = stat;
    _dataCC = step1.result.data_credit;
    
    if ([_dataCC.cc_agent integerValue] == 1) {
        [self shouldDoRequestCCVeritrans];
    }
    else if ([_dataCC.cc_agent integerValue] == 2) {
        [self shouldDoRequestCCSprintAsia];
    }
}

-(void)refreshCartAfterCancelPayment
{
    
}

-(void)shouldDoRequestCCVeritrans
{
    [VTConfig setCLIENT_KEY:@"a2ce64ee-ecc5-4cff-894d-c789ff2ab003"];
    [VTConfig setVT_IsProduction:NO];
    
    VTDirect *vtDirect = [VTDirect new];
    VTCardDetails *cardDetails = [VTCardDetails new];
    
    cardDetails.card_number = [self CCNumber]?:@"";
    cardDetails.card_cvv = _CVVTextField.text?:@"";
    cardDetails.card_exp_month = [_selectedMonth integerValue]?:0;
    cardDetails.card_exp_year = [_selectedYear integerValue]?:0;
    cardDetails.secure = YES;
    cardDetails.gross_amount = _cartSummary.payment_left;
    
    vtDirect.card_details = cardDetails;
    
    [vtDirect getToken:^(VTToken *token, NSException *exception) {
        if (exception == nil) {
            _token = token;
            if (token.redirect_url != nil) {
                [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
                TransactionCartWebViewViewController *vc = [TransactionCartWebViewViewController new];
                vc.gateway = @(TYPE_GATEWAY_CC);
                vc.token = _cartSummary.token;
                vc.URLString = token.redirect_url?:@"";
                vc.cartDetail = _cartSummary;
                vc.delegate = self;
                vc.isVeritrans = YES;
                UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
                navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
                navigationController.navigationBar.translucent = NO;
                navigationController.navigationBar.tintColor = [UIColor whiteColor];
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
            else
            {
                [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
                StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[_token.status_message] delegate:self];
                [alert show];
            }
        }
    }];
}

-(void)shouldDoRequestCCSprintAsia
{
    [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@/tx-payment-sprintasia.pl",kTraktBaseURLString];
    
    NSString *CCFirstName=[_data objectForKey:API_CC_FIRST_NAME_KEY]?:@"";
    NSString *CCLastName =[_data objectForKey:API_CC_LAST_NAME_KEY]?:@"";
    NSString *CCCity =[_data objectForKey:API_CC_CITY_KEY]?:@"";
    NSString *CCPostalCode =[_data objectForKey:API_CC_POSTAL_CODE_KEY]?:@"";
    NSString *CCAddress =[_data objectForKey:API_CC_ADDRESS_KEY]?:@"";
    NSString *CCPhone =[_data objectForKey:API_CC_PHONE_KEY]?:@"";
    NSString *CCState =[_data objectForKey:API_CC_STATE_KEY]?:@"";
    NSString *CCOwnerName =_nameTextField.text?:@"";
    NSString *CCNumber =[self CCNumber]?:@"";
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *userID = [auth getUserId];
    
    NSDictionary *param = @{
                            @"address_street": CCAddress,
                            @"amount":_cartSummary.payment_left?:@"",
                            @"billingAddress" : CCAddress,
                            @"billingCity": CCCity,
                            @"billingCountry" : @"Indonesia",
                            @"billingEmail": _dataCC.user_email?:@"",
                            @"billingName": CCOwnerName,
                            @"billingPhone" : CCPhone,
                            @"billingPostalCode": CCPostalCode,
                            @"billingState":CCState,
                            @"cardExpMonth":_selectedMonth?:@"",
                            @"cardExpYear":_selectedYear?:@"",
                            @"cardNo": CCNumber,
                            @"cardSecurity": _CVVTextField.text?:@"",
                            @"cardType":_dataCC.cc_type?:@"",
                            @"city":CCCity,
                            @"credit_card_edit_flag" :@"1",
                            @"credit_card_token":_dataCC.payment_id?:@"",
                            @"currency":@"IDR",
                            @"deliveryAddress":CCAddress,
                            @"deliveryCity":CCCity,
                            @"deliveryCountry":@"Indonesia",
                            @"deliveryName":CCOwnerName,
                            @"deliveryPostalCode":CCPostalCode,
                            @"deliveryState":CCState,
                            @"first_name":CCFirstName,
                            @"gateway":[_cartSummary.gateway stringValue]?:@"",
                            @"last_name":CCLastName,
                            @"merchantTransactionID":_dataCC.payment_id?:@"",
                            @"merchantTransactionNote":@"",
                            @"phone":CCPhone,
                            @"postal_code":CCPostalCode,
                            @"refback":@"",
                            @"serviceVersion":@"1.1",
                            @"siteID":@"mTokopediaios",
                            @"step":@"2",
                            @"token":_cartSummary.token?:@"",
                            @"transactionType":@"SALE",
                            //@"redirect":@"1",
                            //@"user_id":userID?:@""
                            };
    [request setURL:[NSURL URLWithString:stringURL]];

    [_alertLoading dismissWithClickedButtonIndex:0 animated:NO];
    TransactionCartWebViewViewController *vc = [TransactionCartWebViewViewController new];
    vc.gateway = @(TYPE_GATEWAY_CC);
    vc.token = _cartSummary.token;
    vc.URLString = stringURL?:@"";
    vc.cartDetail = _cartSummary;
    vc.delegate = self;
    vc.CCParam = param;
    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:vc];
    navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)doRequestCC:(NSDictionary *)param
{
    NSMutableDictionary *dataInput = [NSMutableDictionary new];
    [dataInput addEntriesFromDictionary:_data];
    [dataInput setObject:[self CCNumber]?:@"" forKey:API_CC_CARD_NUMBER_KEY];
    [dataInput setObject:_nameTextField.text?:@"" forKey:API_CC_OWNER_KEY];
    [dataInput setObject:_CVVTextField.text?:@"" forKey:API_CC_CVV_KEY];
    [dataInput setObject:_selectedMonth?:@"" forKey:API_CC_EXP_MONTH_KEY];
    [dataInput setObject:_selectedYear?:@"" forKey:API_CC_EXP_YEAR_KEY];
    [dataInput setObject:_token.token_id?:@"" forKey:API_CC_TOKEN_ID_KEY];
    
    [_delegate doRequestCC:dataInput];
    [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count-3] animated:YES];
}

-(void)isSucessSprintAsia:(NSDictionary *)param
{
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
    [_delegate isSucessSprintAsia:param];
    [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count-3] animated:YES];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    _isFailMaxRequest = YES;
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - Methods
-(NSDictionary *)param
{
    NSDictionary *param = @{@"action":@"step_1_process_credit_card",
                            @"credit_card_edit_flag":@"1",
                            API_CC_FIRST_NAME_KEY:[_data objectForKey:API_CC_FIRST_NAME_KEY]?:@"",
                            API_CC_LAST_NAME_KEY:[_data objectForKey:API_CC_LAST_NAME_KEY]?:@"",
                            API_CC_CITY_KEY:[_data objectForKey:API_CC_CITY_KEY]?:@"",
                            API_CC_POSTAL_CODE_KEY:[_data objectForKey:API_CC_POSTAL_CODE_KEY]?:@"",
                            API_CC_ADDRESS_KEY:[_data objectForKey:API_CC_ADDRESS_KEY]?:@"",
                            API_CC_PHONE_KEY:[_data objectForKey:API_CC_PHONE_KEY]?:@"",
                            API_CC_STATE_KEY:[_data objectForKey:API_CC_STATE_KEY]?:@"",
                            API_CC_CARD_NUMBER_KEY:[self CCNumber]?:@""
                            };
    
    return param;
}

-(NSString*)CCNumber
{
    return [_CCNumberTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(IBAction)nextButton:(id)sender
{
    [self.view endEditing:YES];

    [_activeTextField resignFirstResponder];
    _activeTextField = nil;

    
    if ([self isValidInput]) {
        _requestCart.param = [self param];
        [_requestCart doRequestCC];
    }
}
- (IBAction)infoCVC:(id)sender {
    AlertInfoView *alertInfo = [AlertInfoView newview];
    alertInfo.text = @"Info CVC/CVV2";
    alertInfo.detailText = @"CVC atau Card Verification Code adalah tiga digit angka terakhir yang terdapat pada bagian belakang kartu kredit.";
    [alertInfo show];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
#define CHARACTER_LIMIT 16
    
    if (textField == _CCNumberTextField) {
        __block NSString *text = [textField text];
        
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789\b"];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) {
            return NO;
        }
        
        text = [text stringByReplacingCharactersInRange:range withString:string];
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *newString = @"";
        while (text.length > 0) {
            NSString *subString = [text substringToIndex:MIN(text.length, 4)];
            newString = [newString stringByAppendingString:subString];
            if (subString.length == 4) {
                newString = [newString stringByAppendingString:@" "];
            }
            text = [text substringFromIndex:MIN(text.length, 4)];
        }
        
        newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
        
        if (newString.length >= 20) {
            return NO;
        }
        
        [textField setText:newString];
        
        return NO;
    }
    if (textField == _CVVTextField) {
#define CVV_CHARACTER_LIMIT 3
        return textField.text.length + (string.length - range.length) <= CVV_CHARACTER_LIMIT;
    }
    
    return YES;
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if ([_nameTextField.text isEqualToString:@""]) {
        [errorMessage addObject:@"Nama harus diisi."];
        isValid = NO;
    }
    if ([_CCNumberTextField.text isEqualToString:@""]) {
        [errorMessage addObject:@"Nomor kartu kredit harus diisi."];
        isValid = NO;
    }
    else if (_CCNumberTextField.text.length < 19) {
        [errorMessage addObject:@"Nomor kartu harus 16 karakter."];
        isValid = NO;
    }
    if ([_expDateLabel.text isEqualToString:@"MM/YYYY"]) {
        [errorMessage addObject:@"Tanggal kadaluarsa harus diisi."];
        isValid = NO;
    }
    if ([_CVVTextField.text isEqualToString:@""]) {
        [errorMessage addObject:@"CVC/CVV2 harus diisi."];
        isValid = NO;
    }
    else if (_CVVTextField.text.length <3)
    {
        [errorMessage addObject:@"Kode CVC/CVV2 harus 3 karakter."];
        isValid = NO;
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isValid;
}

@end
