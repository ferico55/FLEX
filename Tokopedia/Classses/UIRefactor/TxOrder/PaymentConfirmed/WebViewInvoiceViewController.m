//
//  WebViewInvoiceViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "WebViewInvoiceViewController.h"

@interface WebViewInvoiceViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation WebViewInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView.scalesPageToFit = YES;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setValue:@"Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" forHTTPHeaderField:@"User-Agent"];
    [request setURL:[NSURL URLWithString:_urlAddress]];
    [_webView loadRequest:request];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Invoice";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_act stopAnimating];
}

@end
