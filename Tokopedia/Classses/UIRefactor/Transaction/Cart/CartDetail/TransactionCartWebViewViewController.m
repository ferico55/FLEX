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
#import "TxOrderConfirmedViewController.h"
#import "TxOrderStatusViewController.h"
#import "TransactionActionResult.h"
#import "NSNumberFormatter+IDRFormater.h"
#import <objc/runtime.h>

@interface TransactionCartWebViewViewController ()<UIWebViewDelegate, UIAlertViewDelegate>
{
    BOOL _isAlertShow ;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TransactionCartWebViewViewController

+(void)pushToppayFrom:(UIViewController*)vc data:(TransactionActionResult*)data {
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.toppayQueryString = data.query_string;
    controller.URLString = data.redirect_url;
    controller.toppayParam = data.parameter;
    controller.delegate = vc;
    controller.callbackURL = data.callback_url;
    controller.title = @"Pembayaran";
    
    [vc.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    
    if ([self isModal]) {
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    _isAlertShow = NO;
    [self loadRequest];
}

-(IBAction)didTapSuccess:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)didTapRetry:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadRequest
{
    _webView.scalesPageToFit = YES;
    [_webView loadRequest:[self requestDefault]];
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


- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"URL shouldStartLoadWithRequest: %@", webView.request.URL.absoluteString);
    NSLog(@"URL shouldStartLoadWithRequest: %@", request.URL.absoluteString);
    
    NSURL *callbackURL = [NSURL URLWithString:_callbackURL];
    if ([request.URL.absoluteString rangeOfString:callbackURL.path].location != NSNotFound) {

        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.outerHTML"];
        if ([html rangeOfString:@"Konfirmasi Pembayaran"].location != NSNotFound && webView.request.URL.absoluteString != nil) {
            TxOrderConfirmedViewController *vc = [TxOrderConfirmedViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([html rangeOfString:@"Status Pemesanan"].location != NSNotFound && webView.request.URL.absoluteString != nil) {
            TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
            vc.action = @"get_tx_order_status";
            vc.viewControllerTitle = @"Status Pemesanan";
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            NSDictionary *paramURL = [self dictionaryFromURLString:request.URL.absoluteString];
            NSString *paymentID = [paramURL objectForKey:@"id"]?:_toppayParam[@"transaction_id"]?:@"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSaldoTokopedia" object:nil userInfo:nil];
            [_delegate shouldDoRequestTopPayThxCode:paymentID toppayParam:_toppayParam];
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
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"html String WebView %@", html);
    NSLog(@"URL webViewDidFinishLoad: %@", webView.request.URL.absoluteString);

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [webView stopLoading];
    NSString *errorMessage ;
    
    NSLog(@"%@", error.localizedDescription);
    
    if (error.code==-1009) {
        errorMessage = [NSString stringWithFormat:@"Tidak ada koneksi internet\n%@",error.localizedDescription];
    } else {
        errorMessage = [NSString stringWithFormat:@"Mohon maaf, terjadi kendala pada server. Mohon coba beberapa saat lagi.\n%@",error.localizedDescription];
    }
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    [AnalyticsManager trackExceptionDescription:[NSString stringWithFormat:@"Payment ID: %@, User ID: %@, Gateway ID: %@, Error Description: %@, URL: %@", _paymentID?:@"", [userManager getUserId]?:@"", _gateway?:@"", error.localizedDescription?:@"", webView.request.URL.absoluteString?:@""]];
    
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:nil message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    if (!_isAlertShow) {
        _isAlertShow = YES;
        errorAlert.tag = 11;
        [errorAlert show];
    }
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
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
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
    self.title = @"";
    
    [_webView endEditing:YES];

}

@end
