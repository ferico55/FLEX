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
    [_delegate isSucessSprintAsia:_data];
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
    
    NSString *urlAddress = @"" ;
    _webView.scalesPageToFit = YES;
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *url;
    
    if (gateway == TYPE_GATEWAY_BCA_CLICK_PAY) {
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
        
        url = [NSURL URLWithString:urlAddress];
        //[_delegate shouldDoRequestBCAClickPay];
    }
    else if (gateway == TYPE_GATEWAY_MANDIRI_E_CASH) {
        urlAddress = _URLString;
        url = [NSURL URLWithString:urlAddress];
    }
    else if ((gateway == TYPE_GATEWAY_CC || gateway == TYPE_GATEWAY_INSTALLMENT) && !_isVeritrans) {
        
        urlAddress = _URLString;
        
        NSDictionary *paramEncrypt = [_CCParam encrypt];
        
        NSString *postString = [self encodeDictionary:paramEncrypt];

        postString = [postString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSLog(@"POST String %@", postString);
        
        [request setHTTPBody:postData];
        [request setHTTPMethod:@"POST"];

        url = [NSURL URLWithString:urlAddress];
    }
    else if (gateway == TYPE_GATEWAY_BRI_EPAY)
    {
        urlAddress = _URLString;
        NSString *postString = [NSString stringWithFormat:@"keysTrxEcomm=%@&gateway=%@,token=%@,step=2", _transactionCode,_gateway,_token];
        NSLog(@"%@", postString);
        NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [request setHTTPBody:postData];
        [request setHTTPMethod:@"POST"];
        
        url = [NSURL URLWithString:urlAddress];
    }
    else{
        urlAddress = _URLString;//@"http://pay-staging.tokopedia.com/v1/payment";
        NSString *postString                = _toppayQueryString?:@"";
        NSData *postData                    = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        
        url = [NSURL URLWithString:urlAddress];
    }
    
    [request setURL:url];
    [_webView loadRequest:request];
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
        if ([request.URL.absoluteString isEqualToString:_BCAParam.callback] ||
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
        if ([request.URL.absoluteString rangeOfString:@"tx-toppay-thanks.pl"].location != NSNotFound) {
            
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
    [_delegate doRequestCC:_data];
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
