//
//  WebViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NJKWebViewProgressView.h"
#import "WebViewController.h"
#import "TkpdHMAC.h"
#import "NSURL+Dictionary.h"
#import "Tokopedia-Swift.h"

#import "Tokopedia-Swift.h"
#import <Popover/Popover-Swift.h>
#import "HomeTabViewController.h"
#import "NavigateViewController.h"

@interface WebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) WebviewPopover *popover;
@end

@implementation WebViewController
{
    NJKWebViewProgress *progressProxy;
    NJKWebViewProgressView *progressView;
}
@synthesize strURL, strTitle, strContentHTML, strQuery;

-(id)init{
    if ((self = [super init])) {
        _navigationPivotVisible = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setWhite];
    _shouldAuthorizeRequest = YES;
    
    self.navigationItem.title = strTitle;
    
    if(strContentHTML != nil) {
        [_webView loadHTMLString:strContentHTML baseURL:nil];
    }
    else {
        //SetUp URL
        progressProxy = [[NJKWebViewProgress alloc] init];
        _webView.delegate = progressProxy;
        progressProxy.webViewProxyDelegate = self;
        progressProxy.progressDelegate = self;
        
        //SetUp Progress View
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0,     navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
        progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        [self.navigationController.navigationBar addSubview:progressView];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_white"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidTapped)];
        
        NSURL* url = [NSURL URLWithString:strURL];
        if (strQuery == nil) {
            [_webView loadRequest:[self requestForUrl:url]];
        } else {
            _shouldAuthorizeRequest = NO;
            [_webView loadRequest:[self requestForUrl:url query:strQuery]];
        }
    }
    
    //popover
    if (_navigationPivotVisible) {
        _popover = [[WebviewPopover alloc] initWithViewController:self];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem makeWithController:self selector:@selector(tapPopover)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressView removeFromSuperview];
}

- (void) backButtonDidTapped {
    if (self.webView.canGoBack) {
        [self.webView goBack];
        if(self.onTapBackButton) {
            self.onTapBackButton(self.webView.request.URL);
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *documentTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (documentTitle && ![documentTitle isEqualToString:@""] &&
        (!self.strTitle || [self.strTitle isEqualToString:@""])) {
        self.navigationItem.title = documentTitle;
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked && _isLPWebView) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        
        return NO;
    }
    
    if(self.onTapLinkWithUrl) {
        self.onTapLinkWithUrl([inRequest URL]);
    }
    
    return YES;
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [progressView setProgress:progress animated:YES];
}

- (NSMutableURLRequest*)requestForUrl:(NSURL*)url {
    NSMutableURLRequest* request;
    if(_shouldAuthorizeRequest) {
        request = [NSMutableURLRequest requestWithAuthorizedHeader:url];
    } else {
        request = [[NSMutableURLRequest alloc] init];
        [request setValue:@"Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" forHTTPHeaderField:@"User-Agent"];
        [request setURL:url];
    }
    
    return request;
}

- (NSMutableURLRequest*)requestForUrl:(NSURL*)url query:(NSString *)query {
    NSMutableURLRequest* request;
    if(_shouldAuthorizeRequest) {
        request = [NSMutableURLRequest requestWithAuthorizedHeader:url];
    } else {
        request = [[NSMutableURLRequest alloc] init];
        [request setValue:@"Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" forHTTPHeaderField:@"User-Agent"];
        [request setURL:url];
    }
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    return request;
}
    
#pragma mark - pop over
- (void)tapPopover {
    [self.popover tapShowWithCoordinate:CGPointMake(self.view.frame.size.width-26, 50)];
}

@end
