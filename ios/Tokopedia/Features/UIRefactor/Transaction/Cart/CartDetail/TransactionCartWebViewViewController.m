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
#import "PurchaseViewController.h"
#import "Tokopedia-Swift.h"
#import "UIBarButtonItem+BlocksKit.h"

@interface TransactionCartWebViewViewController ()<UIWebViewDelegate, UIAlertViewDelegate>
{
    BOOL _isAlertShow ;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property PaymentTouchIDServiceBridging *service;

@end

@implementation TransactionCartWebViewViewController{
    NSURLRequest *_OTPRequest;
    BOOL _canUseTouchID;
}

+(void)pushToppayFrom:(UIViewController*)vc data:(TransactionActionResult*)data {
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.toppayQueryString = data.query_string;
    controller.URLString = data.redirect_url;
    controller.toppayParam = data.parameter;
    controller.delegate = vc;
    controller.callbackURL = data.callback_url;
    controller.title = @"Pembayaran";
    controller.hidesBottomBarWhenPushed = YES;
    controller.navigationItem.rightBarButtonItem = nil;
    
    [vc.navigationController pushViewController:controller animated:YES];
}

+(void)pushToppayFromURL:(NSString*)url viewController:(UIViewController*)vc shouldAuthorizedRequest:(BOOL)shouldAuthorizedRequest {
    
    TransactionCartWebViewViewController *controller = [TransactionCartWebViewViewController new];
    controller.URLString = url;
    controller.delegate = vc;
    controller.callbackURL = @"https://*/nocallback";
    controller.shouldAuthorizedRequest = shouldAuthorizedRequest;
    controller.title = @"Pembayaran";
    controller.hidesBottomBarWhenPushed = YES;
    
    [vc.navigationController pushViewController:controller animated:YES];
}

-(instancetype)initWithCart:(TransactionCartPayment *) cart {
    if (self = [super init]) {
        self.URLString = cart.url;
        self.callbackURL = cart.callbackUrl;
        self.toppayQueryString = cart.queryString;
        if (cart.parameter) {
            self.toppayParam = cart.parameter;
        }
        self.title = @"Pembayaran";
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     FBTweakAction(@"Others", @"TouchID", @"Reset Payment TouchID", ^{
         PaymentTouchIDServiceBridging *service = [PaymentTouchIDServiceBridging new];
         [service doResetAllPaymentTouchID];
     });
    
    _canUseTouchID = YES;
    _service = [PaymentTouchIDServiceBridging new];
    
    __weak typeof(self) wself = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             bk_initWithImage:[UIImage imageNamed:@"icon_arrow_white"]
                                             style:UIBarButtonItemStylePlain
                                             handler:^(id sender) {
                                                 [wself.navigationController popViewControllerAnimated:YES];
                                             }];
    
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
    if(self.shouldAuthorizedRequest){
        [_webView loadRequest:[self requestDefaultWithAuthorizedHeader]];
    }else{
        [_webView loadRequest:[self requestDefault]];
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

-(NSMutableURLRequest*)requestDefaultWithAuthorizedHeader{
    return [NSMutableURLRequest requestWithAuthorizedHeader:[NSURL URLWithString:_URLString]];
}


- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *callbackURL = [NSURL URLWithString:_callbackURL];
    if ([request.URL.absoluteString rangeOfString:callbackURL.path].location != NSNotFound) {
        NSDictionary *paramURL = [request.URL parameters];
        if ([paramURL objectForKey:@"id"]) {
            NSString *paymentID = [paramURL objectForKey:@"id"]?:_toppayParam[@"transaction_id"]?:@"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSaldoTokopedia" object:nil userInfo:nil];
            [_delegate shouldDoRequestTopPayThxCode:paymentID toppayParam:_toppayParam];
            
            PurchaseViewController *vc = [PurchaseViewController new];;
            [vc setHidesBottomBarWhenPushed:YES];
            UINavigationController *controller = self.navigationController;
            NSMutableArray *controllers=[[NSMutableArray alloc] initWithArray:controller.viewControllers] ;
            [controllers removeLastObject];
            [controllers addObject:vc];
            [controller setViewControllers:controllers animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"thanks"] && [request.URL.parameters objectForKey:@"id"]) {
        NSDictionary *param = _toppayParam;
        if (!param && self.toppayQueryString) {
            NSString *urlString = [NSString stringWithFormat:@"%@?%@",self.URLString,[self.toppayQueryString stringByRemovingPercentEncoding]];
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            param = [url parameters];
        }
        NSLog(@"%@",param);
        if (param) {
            BranchAnalytics *branch = [BranchAnalytics new];
            [branch sendCommerceEventWithParams:param];
        }
    }
    
    BOOL isCreditCardOTPPage = ([request.URL.path containsString:@"/v2/3dsecure/cc/veritrans/"] || [request.URL.path containsString:@"/v2/3dsecure/sprintasia"]);
    if (isCreditCardOTPPage) {
        
        NSData *data = request.HTTPBody;
        NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSDictionary *parameter = [self dictionaryFromQueryString: string];
        
        if(_canUseTouchID && [parameter[@"enable_fingerprint"] boolValue]) {

            _OTPRequest = request;
            __weak typeof(self) weakSelf = self;
            [self.service validateTouchIDPaymentWithParameter:parameter onSuccess:^(NSString* urlString, NSString* parameterString) {
                
                NSMutableURLRequest *requestOTP = [[NSMutableURLRequest alloc] init];
                NSData *postData = [parameterString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                [requestOTP setHTTPBody:postData];
                [requestOTP setHTTPMethod:@"POST"];
                NSURL *url = [NSURL URLWithString: urlString];
                [requestOTP setURL:url];
                
                [weakSelf.webView loadRequest: requestOTP];
                
                _canUseTouchID = NO;

            } onError:^(NSString * errorMessage) {
                if (errorMessage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showTouchIDAlertError:errorMessage OTPRequest:_OTPRequest];
                    });
                } else {
                    [weakSelf.webView loadRequest: _OTPRequest];
                }
                _canUseTouchID = NO;
            }];
            
            return !_canUseTouchID;
        }
    }
    
    BOOL isSaveFingerprint = ([request.URL.absoluteString containsString:@"/fingerprint/save"]);
    if (isSaveFingerprint) {
        NSDictionary *parameters = [request.URL parameters];
        NSString *transactionID = parameters[@"transaction_id"];
        NSString *ccHash = parameters[@"cc_hashed"];
        [self registerTouchIDTransactionID:transactionID ccHash:ccHash];
        
        return NO;
    }

    return YES;
}

-(void)showTouchIDAlertError:(NSString*)message OTPRequest:(NSURLRequest*)otpRequest {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *option = [UIAlertAction actionWithTitle:@"Ok"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self.webView loadRequest: otpRequest];
                                                   }];
    [alertController addAction:option];
    
    [self presentViewController:alertController
                                        animated:YES
                                      completion:nil];
}

-(void)showRegisterTouchIDAlertError:(NSString*)message transactionID:(NSString*)transactionID ccHash:(NSString*)ccHash {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Tutup"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:close];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Coba lagi"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [weakSelf registerTouchIDTransactionID:transactionID ccHash:ccHash];
                                                   }];
    [alertController addAction:tryAgain];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

-(void)registerTouchIDTransactionID:(NSString*)transactionID ccHash:(NSString*)ccHash {
    __weak typeof(self) wself = self;
    [self.service registerPublicKeyWithTransactionID:transactionID ccHash:ccHash onSuccess:^(NSString * _Nonnull successMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [StickyAlertView showSuccessMessage:@[successMessage]];
        });
    } onError:^(NSString * _Nullable error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself showRegisterTouchIDAlertError:error transactionID:transactionID ccHash:ccHash];
            });
        }
    }];
}

-(NSDictionary *)dictionaryFromQueryString:(NSString *)queryString {
    NSArray * pairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs) {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [[bits objectAtIndex:0] stringByRemovingPercentEncoding];
        NSString * value = [[bits objectAtIndex:1] stringByRemovingPercentEncoding];
        [dictionary setObject:value forKey:key];
    }
    
    return [dictionary copy];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    
    __weak typeof(self) wself = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             bk_initWithImage:[UIImage imageNamed:@"icon_arrow_white"]
                                             style:UIBarButtonItemStylePlain
                                             handler:^(id sender) {
                                                 if([wself.webView.request.URL.path containsString:@"thanks"]) {
                                                     [wself.navigationController popToRootViewControllerAnimated:YES];
                                                 } else {
                                                     if ([wself.webView.request.URL.absoluteString containsString:@"pay.tokopedia.com"]) {
                                                         [wself.webView stringByEvaluatingJavaScriptFromString:@"handlePop()"];
                                                     } else {
                                                         [wself.navigationController popViewControllerAnimated:YES];
                                                     }
                                                 }
                                             }];

}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    [AnalyticsManager trackExceptionDescription:[NSString stringWithFormat:@"Payment ID: %@, User ID: %@, Gateway ID: %@, Error Description: %@, URL: %@", _paymentID?:@"", [userManager getUserId]?:@"", _gateway?:@"", error.localizedDescription?:@"", webView.request.URL.absoluteString?:@""]];
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
