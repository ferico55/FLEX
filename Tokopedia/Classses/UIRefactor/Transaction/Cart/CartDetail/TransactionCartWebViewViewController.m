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
#import "RequestCart.h"
#import <objc/runtime.h>

#define CLICK_BCA_LOGIN_URL @"https://klikpay.klikbca.com/login.do?action=loginRequest"
#define CLICK_BCA_LOGIN_PAYEMNET_URL @"https://klikpay.klikbca.com/purchasing/purchase.do?action=loginRequest"
#define CLICK_BCA_SUMMARY_URL @"https://klikpay.klikbca.com/purchasing/payment.do?action=summaryRequest"
#define CLICK_BCA_VIEW_TRANSACTION @"https://klikpay.klikbca.com/purchasing/payment.do?action=viewTransaction"
#define BRI_EPAY_CALLBACK_URL @"https://api.tokopedia.com/briPayment?tid"

@interface TransactionCartWebViewViewController ()<UIWebViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL _isSuccessBCA;
    BOOL _isBRIEPayRequested;
    NSOperationQueue *_operationQueue;
    
    NSInteger requestCount;
    BOOL _isAlertShow ;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation TransactionCartWebViewViewController

+(void)pushBCAKlikPayFrom:(UIViewController*)vc cartDetail:(TransactionSummaryDetail*)cartDetail {
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.gateway = cartDetail.gateway;
    controller.token = cartDetail.token;
    controller.cartDetail = cartDetail;
    controller.delegate = vc;
    controller.paymentID = cartDetail.payment_id;
    controller.title = cartDetail.gateway_name?:@"BCA KlikPay";
    
    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    [vc.navigationController presentViewController:navigationController animated:YES completion:nil];
}

+(void)pushMandiriECashFrom:(UIViewController*)vc cartDetail:(TransactionSummaryDetail*)cartDetail LinkMandiri:(NSString*)linkMandiri {

    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.gateway = @(TYPE_GATEWAY_MANDIRI_E_CASH);
    controller.token = cartDetail.token;
    controller.URLString = linkMandiri?:@"";
    controller.cartDetail = cartDetail;
    controller.emoney_code = cartDetail.emoney_code;
    controller.delegate = vc;
    controller.paymentID = cartDetail.payment_id;
    controller.title = cartDetail.gateway_name?:@"Mandiri E-Cash";
    
    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    
    [vc.navigationController presentViewController:navigationController animated:YES completion:nil];
}

+(void)pushBRIEPayFrom:(UIViewController*)vc cartDetail:(TransactionSummaryDetail*)cartDetail{
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.gateway = cartDetail.gateway;
    controller.token = cartDetail.token;
    controller.URLString = cartDetail.bri_website_link?:@"";
    controller.cartDetail = cartDetail;
    controller.transactionCode = cartDetail.transaction_code?:@"";
    controller.delegate = vc;
    controller.paymentID = cartDetail.payment_id;
    controller.title = cartDetail.gateway_name?:@"BRI E-Pay";
    
    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    [vc.navigationController presentViewController:navigationController animated:YES completion:nil];
}

+(void)pushToppayFrom:(UIViewController*)vc data:(TransactionActionResult*)data gatewayID:(NSInteger)gatewayID gatewayName:(NSString*)gatewayName {
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.toppayQueryString = data.query_string;
    controller.URLString = data.redirect_url;
    controller.toppayParam = data.parameter;
    controller.gateway = @(gatewayID);
    controller.delegate = vc;
    controller.callbackURL = data.callback_url;
    controller.title = gatewayName?:@"Pembayaran";
    
    [vc.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    
    if ([self isModal]) {
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    _isSuccessBCA = NO;
    
    _isAlertShow = NO;
    [self loadRequest];
}

-(IBAction)didTapSuccess:(id)sender
{
    [_delegate isSucessSprintAsia:@{}];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)didTapRetry:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadRequest
{
    requestCount++;
    
    NSInteger gateway = [_gateway integerValue];
    
    _webView.scalesPageToFit = YES;

    switch (gateway) {
        case TYPE_GATEWAY_BCA_CLICK_PAY:
            [_webView loadRequest:[self requestBCAKlikPay]];
            break;
        case TYPE_GATEWAY_MANDIRI_E_CASH:
            [_webView loadRequest:[self requestMandiriECash]];
            break;
        case TYPE_GATEWAY_CC:
        case TYPE_GATEWAY_INSTALLMENT:
            if (!_isVeritrans) {
                [_webView loadRequest:[self requestCC]];
            } else {
                [_webView loadRequest:[self requestDefault]];
            }
            break;
        case TYPE_GATEWAY_BRI_EPAY:
            [_webView loadRequest:[self requestBRIEPay]];
            break;
        default:
            [_webView loadRequest:[self requestDefault]];
            break;
    }

}

-(NSMutableURLRequest*)requestDefault{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postString                = _toppayQueryString?:@"";
    NSData *postData                    = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    NSURL *url = [NSURL URLWithString:_URLString];
    [request setURL:url];
    
    return request;
}

-(NSMutableURLRequest*)requestBRIEPay{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postString = [NSString stringWithFormat:@"keysTrxEcomm=%@&gateway=%@,token=%@,step=2", _transactionCode,_gateway,_token];
    NSLog(@"%@", postString);
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    NSURL *url = [NSURL URLWithString:_URLString];
    [request setURL:url];
    
    return request;
}

-(NSMutableURLRequest*)requestCC{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSDictionary *paramEncrypt = [_CCParam encrypt];
    NSString *postString = [self encodeDictionary:paramEncrypt];
    
    postString = [postString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    NSURL *url = [NSURL URLWithString:_URLString];
    [request setURL:url];
    
    return request;
}

-(NSMutableURLRequest*)requestMandiriECash{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [NSURL URLWithString:_URLString];
    [request setURL:url];

    return request;
}

-(NSMutableURLRequest*)requestBCAKlikPay{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    TransactionSummaryBCAParam *bcaParam =_cartDetail.bca_param;
    
    NSDictionary *param = @{
                            @"token_cart"       : _token,
                            @"gateway"          : [_gateway stringValue],
                            @"step"             : @"2",
                            @"klikPayCode"      : bcaParam.bca_code,
                            @"transactionNo"    : bcaParam.payment_id,
                            @"totalAmount"      : bcaParam.bca_amt,
                            @"currency"         : bcaParam.currency,
                            @"payType"          : bcaParam.payType,
                            @"callback"         : bcaParam.callback,
                            @"transactionDate"  : bcaParam.bca_date,
                            @"miscFee"          : bcaParam.miscFee,
                            @"signature"        : bcaParam.signature
                            };
    
    NSString *postString = [self encodeDictionary:param];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    NSURL *url = [NSURL URLWithString:_cartDetail.bca_param.bca_url];
    [request setURL:url];
    
    return request;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

-(NSString*)encodeDictionary:(NSDictionary*)dictionary{
    NSMutableString *bodyData = [[NSMutableString alloc]init];
    int i = 0;
    for (NSString *key in dictionary.allKeys) {
        i++;
        [bodyData appendFormat:@"%@=",key];
        NSString *value = [dictionary valueForKey:key];
        NSString *newString = [value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [bodyData appendString:newString];
        if (i < dictionary.allKeys.count) {
            [bodyData appendString:@"&"];
        }
    }
    return bodyData;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [_act startAnimating];
     NSLog(@"URL shouldStartLoadWithRequest: %@", webView.request.URL.absoluteString);
    NSLog(@"URL shouldStartLoadWithRequest: %@", request.URL.absoluteString);


    NSInteger gateway = [_gateway integerValue];
    if ( gateway == TYPE_GATEWAY_BCA_CLICK_PAY)
    {
        if ([request.URL.absoluteString isEqualToString:_cartDetail.bca_param.callback] ||
            [request.URL.absoluteString isEqualToString:CLICK_BCA_VIEW_TRANSACTION] ||
            [webView.request.URL.absoluteString isEqualToString:CLICK_BCA_SUMMARY_URL]
            ) {
            _isSuccessBCA = YES;
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [_delegate shouldDoRequestBCAClickPay];
            return NO;
        }
        
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
        NSString *stringURLEMoney = [self getStringURLMandiriECash];
            if ([request.URL.absoluteString rangeOfString:stringURLEMoney].location != NSNotFound) {
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
    else if ((gateway == TYPE_GATEWAY_CC || gateway == TYPE_GATEWAY_INSTALLMENT)&& !_isVeritrans)
    {
        
    }
    else if (gateway == TYPE_GATEWAY_BRI_EPAY){
        if ([request.URL.absoluteString rangeOfString:@"ecommerce/ecommerce_payment"].location != NSNotFound) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        if ([request.URL.absoluteString rangeOfString:BRI_EPAY_CALLBACK_URL].location != NSNotFound) {

            if (!_isBRIEPayRequested) {
                [_delegate shouldDoRequestBRIEPayCode:_transactionCode];
                _isBRIEPayRequested = YES;
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return NO;
        }
    }
    else
    {
        if ([request.URL.absoluteString rangeOfString:_callbackURL].location != NSNotFound) {
            
            NSDictionary *paramURL = [self dictionaryFromURLString:request.URL.absoluteString];

            [_delegate shouldDoRequestTopPayThxCode:[paramURL objectForKey:@"id"]?:_toppayParam[@"transaction_id"]?:@""];
            if ([self isModal]) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            return NO;
        }
    }
    
    return YES;
}

-(NSDictionary *)dictionaryFromURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString * q = [url query];
    NSArray * pairs = [q componentsSeparatedByString:@"&"];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs) {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dictionary setObject:value forKey:key];
    }
    
    return [dictionary copy];
}

-(NSString *)getStringURLMandiriECash
{
    TKPDSecureStorage* storage = [TKPDSecureStorage standardKeyChains];
    NSString *baseURLFull = [[storage keychainDictionary] objectForKey:@"AppBaseUrl"]?:kTkpdBaseURLString;
    NSURL *url = [NSURL URLWithString:baseURLFull];
    NSURL *root = [NSURL URLWithString:@"/" relativeToURL:url];
    NSString *baseURL = root.absoluteString;
    
    NSString *stringURLEMoney = [NSString stringWithFormat:@"%@ws-new/tx-payment-emoney.pl?id=",baseURL];
    
    return stringURLEMoney;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_act stopAnimating];
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"html String WebView %@", html);
    NSLog(@"URL webViewDidFinishLoad: %@", webView.request.URL.absoluteString);
    
    NSInteger gateway = [_gateway integerValue];
    
    if(gateway == TYPE_GATEWAY_CC || gateway == TYPE_GATEWAY_INSTALLMENT)
    {
        if (_isVeritrans)
        {
            if ([webView.request.URL.absoluteString rangeOfString:@"callback"].location != NSNotFound && webView.request.URL.absoluteString != nil) {
                [self performSelector:@selector(requestCCCallback) withObject:nil afterDelay:3.0f];
            }
        }
        else
        {
            if (([webView.request.URL.absoluteString rangeOfString:@"tx-payment-cc-bca.pl"].location != NSNotFound || [webView.request.URL.absoluteString rangeOfString:@"tx-payment-cc-bca-installment.pl"].location != NSNotFound) && webView.request.URL.absoluteString != nil) {
                // get issuccess value
                NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.outerHTML"];
                if ([html rangeOfString:@"value=\"1\""].location != NSNotFound && webView.request.URL.absoluteString != nil) {
                    UIButton *transparentButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [transparentButton addTarget:self action:@selector(didTapSuccess:) forControlEvents:(UIControlEventTouchUpInside)];
                    transparentButton.frame = webView.frame;
                    transparentButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
                    [self.webView addSubview:transparentButton];
                }
                if ([html rangeOfString:@"Ulangi"].location != NSNotFound && webView.request.URL.absoluteString != nil) {
                    UIButton *transparentButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [transparentButton addTarget:self action:@selector(didTapRetry:) forControlEvents:(UIControlEventTouchUpInside)];
                    transparentButton.frame = webView.frame;
                    transparentButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
                    [self.webView addSubview:transparentButton];
                }
            }
        }
    }
}

-(void)requestCCCallback
{
    [_delegate doRequestCC:@{}];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [webView stopLoading];
    [_act stopAnimating];
    NSString *errorMessage ;

    NSLog(@"%@", error.localizedDescription);
    
    if (error.code==-1009) {
        errorMessage = [NSString stringWithFormat:@"Tidak ada koneksi internet\n%@",error.localizedDescription];
    } else {
        errorMessage = [NSString stringWithFormat:@"Mohon maaf, terjadi kendala pada server. Mohon coba beberapa saat lagi.\n%@",error.localizedDescription];
    }
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    [TPAnalytics trackExeptionDescription:[NSString stringWithFormat:@"Payment ID: %@, User ID: %@, Gateway ID: %@, Error Description: %@, URL: %@", _paymentID?:@"", [userManager getUserId]?:@"", _gateway?:@"", error.localizedDescription?:@"", webView.request.URL.absoluteString?:@""]];
    
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
        if ([self isModal]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }    }
    else
    {
        if (buttonIndex == 1) {
            [_webView stopLoading];
            if ([self isModal]) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
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
