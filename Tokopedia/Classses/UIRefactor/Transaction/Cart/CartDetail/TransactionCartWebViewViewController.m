//
//  TransactionCartWebViewViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartWebViewViewController.h"

#import "TxEmoney.h"
#import "string_transaction.h"

#define CLICK_BCA_LOGIN_URL @"https://klikpay.klikbca.com/login.do?action=loginRequest"
#define CLICK_BCA_LOGIN_PAYEMNET_URL @"https://klikpay.klikbca.com/purchasing/purchase.do?action=loginRequest"
#define CLICK_BCA_SUMMARY_URL @"https://klikpay.klikbca.com/purchasing/payment.do?action=summaryRequest"
#define CLICK_BCA_VIEW_TRANSACTION @"https://klikpay.klikbca.com/purchasing/payment.do?action=viewTransaction"

@interface TransactionCartWebViewViewController ()<UIWebViewDelegate, UIAlertViewDelegate>
{
    BOOL _isSuccessBCA;
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TransactionCartWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    
    NSInteger gateway = [_gateway integerValue];
    
    self.title = (gateway == TYPE_GATEWAY_CLICK_BCA)?@"KlikPay BCA":@"Mandiri e-Cash";
    
    NSString *urlAddress = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.bca_url:_URLStringMandiri;
    _webView.scalesPageToFit = YES;
    NSLog(@"%@", urlAddress);
    
    NSString *clickPayCode = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.bca_code:@"";
    NSString *paymentID = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.payment_id:@"";
    NSString *amount = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.bca_amt:@"";
    NSString *currency = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.currency:@"";
    NSString *payType = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.payType:@"";
    NSString *callBack = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.callback:@"";
    NSString *date = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.bca_date:@"";
    NSString *MISCFee = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.miscFee:@"";
    NSString *signature = (gateway == TYPE_GATEWAY_CLICK_BCA)?_BCAParam.signature:@"";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if (gateway == TYPE_GATEWAY_CLICK_BCA) {
        NSString *postString = [NSString stringWithFormat:@"token_cart=%@&gateway=%@&step=2&klikPayCode=%@&transactionNo=%@&totalAmount=%@&currency=%@&payType=%@&callback=%@&transactionDate=%@&miscFee=%@&signature=%@",
                                _token,
                                _gateway,
                                clickPayCode,
                                paymentID,
                                amount,
                                currency,
                                payType,
                                callBack,
                                date,
                                MISCFee,
                                signature
                                ];
        NSLog(@"%@", postString);
        NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        [request setHTTPMethod:@"POST"];
        //[_delegate shouldDoRequestBCAClickPay];
    }
    
    [request setURL:[NSURL URLWithString:urlAddress]];
    [_webView loadRequest:request];
    
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 20;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    _isSuccessBCA = NO;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSInteger gateway = [_gateway integerValue];
    if ( gateway == TYPE_GATEWAY_CLICK_BCA)
    {
        [_act startAnimating];
        if ([request.URL.absoluteString isEqualToString:_BCAParam.callback] ||
            [request.URL.absoluteString isEqualToString:CLICK_BCA_VIEW_TRANSACTION] ||
            [webView.request.URL.absoluteString isEqualToString:CLICK_BCA_SUMMARY_URL]
            ) {
            _isSuccessBCA = YES;
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [_delegate shouldDoRequestBCAClickPay];
            return NO;
        }
        //if ([request.URL.absoluteString isEqualToString:CLICK_BCA_VIEW_TRANSACTION]) {
        //    _isSuccessBCA = YES;
        //}
        
        if ([webView.request.URL.absoluteString isEqualToString:CLICK_BCA_SUMMARY_URL]) {
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
            [backBarButtonItem setTintColor:[UIColor whiteColor]];
            backBarButtonItem.tag = 20;
            self.navigationItem.leftBarButtonItem = backBarButtonItem;
        }
        else if ([webView.request.URL.absoluteString isEqualToString:CLICK_BCA_LOGIN_URL]||[webView.request.URL.absoluteString isEqualToString:CLICK_BCA_LOGIN_PAYEMNET_URL])
        {
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
            [backBarButtonItem setTintColor:[UIColor whiteColor]];
            backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
            self.navigationItem.leftBarButtonItem = backBarButtonItem;
        }
    }
    else if(gateway == TYPE_GATEWAY_MANDIRI_E_CASH)
    {
        //if ([request.URL.absoluteString rangeOfString:@"ws-new"].location != NSNotFound) {
            if ([request.URL.absoluteString rangeOfString:@"http://www.tokopedia.com/ws-new/tx-payment-emoney.pl?id="].location != NSNotFound) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                [_delegate shouldDoRequestEMoney:YES];
            }
        //}
        //if ([request.URL.absoluteString rangeOfString:@"ws"].location != NSNotFound) {
            //if ([request.URL.absoluteString rangeOfString:@"http://www.tokopedia.com/ws/tx-payment-emoney.pl?id="].location != NSNotFound) {
            //    [self.navigationController popViewControllerAnimated:YES];
            //    [_delegate shouldDoRequestEMoney:NO];
            //}
        //}

    }
    
    return YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_act stopAnimating];
    NSLog(@"URL String WebView %@", [webView request]);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [webView stopLoading];
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    NSData *jsonData = webView.request.HTTPBody;
    id jsonObj = [NSJSONSerialization JSONObjectWithData: jsonData options: NSJSONReadingMutableContainers error: nil];
    NSLog(@"JSON %@", jsonObj);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)tap:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    if (button.tag == TAG_BAR_BUTTON_TRANSACTION_BACK) {
        UIAlertView *alertCancel = [[UIAlertView alloc]initWithTitle:nil message:@"Apakah Anda yakin ingin membatalkan transaksi pembayaran Anda?" delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
        [alertCancel show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [_delegate refreshCartAfterCancelPayment];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isSuccessBCA) {
        [_delegate shouldDoRequestBCAClickPay];
    }
}

@end
