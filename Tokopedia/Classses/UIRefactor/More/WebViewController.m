//
//  WebViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NJKWebViewProgressView.h"
#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
{
    NJKWebViewProgress *progressProxy;
    NJKWebViewProgressView *progressView;
}
@synthesize strURL, strTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = strTitle;

    //SetUp URL
    progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = progressProxy;
    progressProxy.webViewProxyDelegate = self;
    progressProxy.progressDelegate = self;
    
    
    //SetUp Progress View
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0,     navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    [self.navigationController.navigationBar addSubview:progressView];
    [webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [progressView removeFromSuperview];
}


#pragma mark - UIWebView Delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
}


#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [progressView setProgress:progress animated:YES];
}
@end
