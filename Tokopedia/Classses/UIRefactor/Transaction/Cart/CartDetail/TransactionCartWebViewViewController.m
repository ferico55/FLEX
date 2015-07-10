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
    
    NSInteger requestCount;
    BOOL _isAlertShow ;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TransactionCartWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    _isSuccessBCA = NO;
    
    _isAlertShow = NO;
    [self loadRequest];
}

-(void)loadRequest
{
    requestCount++;
    
    NSInteger gateway = [_gateway integerValue];
    
    NSString *urlAddress = @"" ;
    _webView.scalesPageToFit = YES;
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if (gateway == TYPE_GATEWAY_CLICK_BCA) {
        self. title = @"KlikPay BCA";
        urlAddress =_BCAParam.bca_url;
        
        NSString *clickPayCode = _BCAParam.bca_code?:@"";
        NSString *paymentID = _BCAParam.payment_id?:@"";
        NSString *amount = _BCAParam.bca_amt?:@"";
        NSString *currency = _BCAParam.currency?:@"";
        NSString *payType = _BCAParam.payType?:@"";
        NSString *callBack = _BCAParam.callback?:@"";
        NSString *date = _BCAParam.bca_date?:@"";
        NSString *MISCFee = _BCAParam.miscFee?:@"";
        NSString *signature = _BCAParam.signature?:@"";
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
    if (gateway == TYPE_GATEWAY_MANDIRI_E_CASH) {
        urlAddress = _URLStringMandiri ;
    }
    
    [request setURL:[NSURL URLWithString:urlAddress]];
    [_webView loadRequest:request];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [_act startAnimating];
    NSInteger gateway = [_gateway integerValue];
    if ( gateway == TYPE_GATEWAY_CLICK_BCA)
    {
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
                UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
                [backBarButtonItem setTintColor:[UIColor whiteColor]];
                backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
                self.navigationItem.leftBarButtonItem = backBarButtonItem;
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
    [_act stopAnimating];
    NSString *errorMessage ;

    if (error.code==-1009) {
        errorMessage = @"Tidak ada koneksi internet";
    } else {
        errorMessage = @"Mohon maaf, terjadi kendala pada server. Mohon coba beberapa saat lagi.";
    }
    
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if (!_isAlertShow) {
        _isAlertShow = YES;
        errorAlert.tag = 11;
        [errorAlert show];
    }
}

- (BOOL)checkAlertExist {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            for (id cc in subviews) {
                if ([cc isKindOfClass:[UIAlertView class]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
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
    if (alertView.tag == 11) {
        [_webView stopLoading];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if (buttonIndex == 1) {
            [_delegate refreshCartAfterCancelPayment];
            [_webView stopLoading];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
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
