//
//  ContactUsWebViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsWebViewController.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "Tokopedia-Swift.h"

@interface ContactUsWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *backBarButton;
@property (strong, nonatomic) UIBarButtonItem *forwardBarButton;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIBarButtonItem *safariButton;

@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@property (strong, nonatomic) NJKWebViewProgressView *progressView;

@property BOOL linkClicked;

@end

@implementation ContactUsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Hubungi Kami";
    
    self.navigationItem.backBarButtonItem = self.backBarButtonItem;
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    [self.navigationController setToolbarItems:self.toolbarItems];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_webView];
    
    [self loadWebView];
    
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = _progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;
    
    //SetUp Progress View
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Web view delegate

- (void)loadWebView {
    NSString *appVersion = [UIApplicationCategory getAppVersionStringWithoutDot];
    NSString *urlString = [NSString stringWithFormat:@"https://m.tokopedia.com/bantuan?flag_app=3&device=ios&app_version=%@", appVersion];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.backBarButton.enabled = self.webView.canGoBack;
    self.forwardBarButton.enabled = self.webView.canGoForward;
    self.refreshButton.enabled = YES;
    self.safariButton.enabled = YES;
}

#pragma mark - Bar button

- (UIBarButtonItem *)backBarButtonItem {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    return backButton;
}

- (NSArray *)toolbarItems {
    self.backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapBackBarButton)];
    self.backBarButton.enabled = NO;
    self.forwardBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-forward"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapForwardBarButton)];
    self.forwardBarButton.enabled = NO;
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didTapRefreshBarButton)];
    self.refreshButton.enabled = NO;
    self.safariButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-safari"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSafariBarButton)];
    self.safariButton.enabled = NO;
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    return @[_backBarButton, flexible, _forwardBarButton, flexible, _refreshButton, flexible, _safariButton];
}

#pragma mark - Action 

- (void)didTapBackBarButton {
    [self.webView goBack];
}

- (void)didTapForwardBarButton {
    [self.webView goForward];
}

- (void)didTapRefreshBarButton {
    [self.webView loadRequest:_webView.request];
}

- (void)didTapSafariBarButton {
    [[UIApplication sharedApplication] openURL:_webView.request.URL];
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:YES];
}

@end
