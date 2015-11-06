//
//  ContactUsWebViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsWebViewController.h"

@interface ContactUsWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ContactUsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Hubungi Kami";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self reloadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingView startAnimating];
    UIBarButtonItem *loadingButton = [[UIBarButtonItem alloc] initWithCustomView:loadingView];
    self.navigationItem.rightBarButtonItem = loadingButton;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadWebView)];
    self.navigationItem.rightBarButtonItem = reloadButton;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadWebView)];
    self.navigationItem.rightBarButtonItem = reloadButton;
}

- (void)reloadWebView {
    NSURL *redirectURL = [NSURL URLWithString:@"https://m.tokopedia.com/contact-us-faq.pl?flag_app=1&device=ios"];
    NSURLRequest *request = [NSURLRequest requestWithURL:redirectURL];
    [self.webView loadRequest:request];
}

@end
