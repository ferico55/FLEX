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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setWhite];
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


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"URL shouldStartLoadWithRequest: %@", webView.request.URL.absoluteString);
    NSLog(@"URL shouldStartLoadWithRequest: %@", request.URL.absoluteString);
    
    NSURL *callbackURL = [NSURL URLWithString:_callbackURL];
    if ([request.URL.absoluteString rangeOfString:callbackURL.path].location != NSNotFound) {
        NSDictionary *paramURL = [self dictionaryFromURLString:request.URL.absoluteString];
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
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"html String WebView %@", html);
    NSLog(@"URL webViewDidFinishLoad: %@", webView.request.URL.absoluteString);

    __weak typeof(self) wself = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             bk_initWithImage:[UIImage imageNamed:@"icon_arrow_white"]
                                             style:UIBarButtonItemStylePlain
                                             handler:^(id sender) {
                                                 if([wself.webView.request.URL.path containsString:@"thanks"]) {
                                                     [wself.navigationController popToRootViewControllerAnimated:YES];
                                                 } else {
                                                     [wself.webView stringByEvaluatingJavaScriptFromString:@"handlePop()"];
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
