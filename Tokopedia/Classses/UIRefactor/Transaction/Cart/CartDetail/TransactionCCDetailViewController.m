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
    
    RequestCart *_requestCart;
    NSString *_CCAgent;
    UIAlertView *_alertLoading;
    
    VTToken *_token;
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
        [_years addObject:@{DATA_NAME_KEY:@(i)}];
    }
    
    _requestCart = [RequestCart new];
    _requestCart.viewController = self;
    _requestCart.delegate = self;
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
    _selectedMonth = [alertData objectForKey:DATA_INDEX_KEY];
}

#pragma mark - Request Delegate
-(void)actionBeforeRequest:(int)tag
{
    _alertLoading = [[UIAlertView alloc]initWithTitle:@"Processing" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
}

-(void)requestSuccessCC:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    [_alertLoading dismissWithClickedButtonIndex:0 animated:YES];

    TransactionCC *step1 = (TransactionCC*)object;
    _CCAgent = step1.result.data_credit.cc_agent;
    
    NSMutableDictionary *dataInput = [NSMutableDictionary new];
    [dataInput addEntriesFromDictionary:_data];
    [dataInput setObject:_CCNumberTextField.text?:@"" forKey:API_CC_CARD_NUMBER_KEY];
    [dataInput setObject:_nameTextField.text?:@"" forKey:API_CC_OWNER_KEY];
    [dataInput setObject:_CVVTextField.text?:@"" forKey:API_CC_CVV_KEY];
    [dataInput setObject:_selectedMonth?:@"" forKey:API_CC_EXP_MONTH_KEY];
    [dataInput setObject:_selectedYear?:@"" forKey:API_CC_EXP_YEAR_KEY];
    
    [self shouldDoRequestCC];
}

-(void)shouldDoRequestCC
{
    [VTConfig setCLIENT_KEY:@"a2ce64ee-ecc5-4cff-894d-c789ff2ab003"];
    [VTConfig setVT_IsProduction:NO];
    
    VTDirect *vtDirect = [VTDirect new];
    VTCardDetails *cardDetails = [VTCardDetails new];
    
    cardDetails.card_number = _CCNumberTextField.text?:@"";
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
                UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 400, 420)];
                [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:token.redirect_url]]];
                webView.delegate = self;
                [self.view addSubview:webView];
            }
        }
    }];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView.request.URL.absoluteString rangeOfString:@"callback"].location != 0) {
        [webView removeFromSuperview];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"http://128.199.141.15:9091/index.php"]];
        NSURLSession *session = [NSURLSession sharedSession];
        request.HTTPMethod = @"POST";
        NSString *postString = [NSString stringWithFormat:@"token-id=%@&price=%@", _token.token_id, _cartSummary.payment_left];
        NSData *bodyData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

        request.HTTPBody = bodyData;
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (error == nil) {
                            NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            NSLog(@"String Data Veritrans :%@",strData);
                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            NSString *status = [json[@"status"] stringValue];
                        
                            if (status != nil) {
                                if ([status isEqualToString:@"success"]) {
                                    //do request
                                    NSLog(@"success to Charge");
                                }
                                else
                                {
                                    NSLog(@" Error : %@", [json[@"status"] stringValue]);
                                }
                            }
                            else
                            {
                                NSLog(@"Failed to Charge");
                            }
                        }
                        else
                        {
                            NSLog(@" Error : %@",error.localizedDescription);
                        }
                    }] resume];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
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
                            API_CC_CARD_NUMBER_KEY: _CCNumberTextField.text?:@""
                            };
    
    return param;
}

-(IBAction)nextButton:(id)sender
{
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

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if ([_nameTextField.text isEqualToString:@""]) {
        [errorMessage addObject:@"Nama harus diisi."];
        isValid = NO;
    }
    if ([_CCNumberTextField.text isEqualToString:@""]) {
        [errorMessage addObject:@"Nomer kartu kredit harus diisi."];
        isValid = NO;
    }
    if ([_expDateLabel.text isEqualToString:@"MM/YYYY"]) {
        [errorMessage addObject:@"Tanggal kadaluarsa harus diisi."];
        isValid = NO;
    }
    if ([_CVVTextField.text isEqualToString:@""]) {
        [errorMessage addObject:@"CVC "];
        isValid = NO;
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return isValid;
}

@end
