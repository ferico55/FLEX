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
#import "TxOrderTabViewController.h"
#import "TxOrderStatusViewController.h"
#import "RequestCart.h"
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

+(void)pushToppayFrom:(UIViewController*)vc data:(TransactionActionResult*)data gatewayID:(NSInteger)gatewayID gatewayName:(NSString*)gatewayName {
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.toppayQueryString = data.query_string;
    controller.URLString = data.redirect_url;
    controller.toppayParam = data.parameter;
    controller.gateway = @(gatewayID);
    controller.delegate = vc;
    controller.callbackURL = data.callback_url;
    controller.title = gatewayName?:@"Pembayaran";
    controller.gatewayCode = data.parameter[@"gateway_code"];
    
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
            TxOrderTabViewController *vc = [TxOrderTabViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([html rangeOfString:@"Status Pemesanan"].location != NSNotFound && webView.request.URL.absoluteString != nil) {
            TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
            vc.action = @"get_tx_order_status";
            vc.viewControllerTitle = @"Status Pemesanan";
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
            networkManager.isUsingHmac = YES;
            
            NSDictionary *paramURL = [self dictionaryFromURLString:request.URL.absoluteString];
            NSString *paymentID = [paramURL objectForKey:@"id"]?:_toppayParam[@"transaction_id"]?:@"";
            NSArray *products = _toppayParam[@"items"];
            NSMutableArray *productIDs = [NSMutableArray new];
            NSInteger quantity = 0;
            
            for (NSDictionary *product in products) {
                [productIDs addObject:product[@"id"]];
                quantity = quantity + [product[@"quantity"] integerValue];
            }
            
            [RequestCart fetchToppayThanksCode:paymentID
                                       success:^(TransactionActionResult *data) {
                                           if (data.is_success == 1) {
                                               NSDictionary *parameter = data.parameter;
                                               NSString *paymentMethod = [parameter objectForKey:@"gateway_name"]?:@"";
                                               NSNumber *revenue = [[NSNumberFormatter IDRFormatter] numberFromString:[parameter objectForKey:@"order_open_amt"]];
                                               
                                               [TPAnalytics trackScreenName:[NSString stringWithFormat:@"Thank you page - %@", paymentMethod]];
                                               
                                               [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{AFEventParamRevenue : [revenue stringValue]?:@"",
                                                                                                                         AFEventParamContentType : @"Product",
                                                                                                                         AFEventParamContentId : [NSString jsonStringArrayFromArray:productIDs]?:@"",
                                                                                                                         AFEventParamQuantity : [@(quantity) stringValue]?:@"",
                                                                                                                         AFEventParamCurrency : _toppayParam[@"currency"]?:@"",
                                                                                                                         AFEventOrderId : paymentID}];
                                               
                                               [Localytics tagEvent:@"Event : Finished Transaction"
                                                         attributes:@{
                                                                      @"Payment Method" : paymentMethod,
                                                                      @"Total Transaction" : [revenue stringValue]?:@"",
                                                                      @"Total Quantity" : [@(quantity) stringValue]?:@"",
                                                                      @"Total Shipping Fee" : @""
                                                                      }
                                              customerValueIncrease:revenue];
                                               
                                               [Localytics incrementValueBy:0
                                                        forProfileAttribute:@"Profile : Total Transaction"
                                                                  withScope:LLProfileScopeApplication];
                                           }
                                           
                                           
                                       }
                                         error:^(NSError *error) {
                                             
                                             
                                         }];
            
            
            [_delegate shouldDoRequestTopPayThxCode:paymentID];
            if ([self isModal]) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        return NO;
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
    [TPAnalytics trackExeptionDescription:[NSString stringWithFormat:@"Payment ID: %@, User ID: %@, Gateway ID: %@, Error Description: %@, URL: %@", _paymentID?:@"", [userManager getUserId]?:@"", _gateway?:@"", error.localizedDescription?:@"", webView.request.URL.absoluteString?:@""]];
    
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

}

@end
