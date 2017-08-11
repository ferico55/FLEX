//
//  WebViewInvoiceViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "WebViewInvoiceViewController.h"
#import "TkpdHMAC.h"
#import "NSURL+Dictionary.h"
#import "RequestUtils.h"
#import "Tokopedia-Swift.h"

@interface WebViewInvoiceViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation WebViewInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithAuthorizedHeader:[NSURL URLWithString:_urlAddress]];

    [_webView setScalesPageToFit:YES];
    [_webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Invoice";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_act stopAnimating];
}

@end
