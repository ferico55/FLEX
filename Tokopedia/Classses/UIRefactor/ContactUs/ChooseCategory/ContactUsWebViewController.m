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
@property BOOL linkClicked;

@end

@implementation ContactUsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    [self reloadWebView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadWebView)];
    self.navigationItem.rightBarButtonItem = reloadButton;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL shouldStartLoad = YES;
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        shouldStartLoad = NO;
        
        NSString *title = @"Hubungi Kami";
        NSArray *urlComponents = [request.URL.absoluteString componentsSeparatedByString:@"/"];
        if (urlComponents.count > 3) {
            title = [urlComponents objectAtIndex:urlComponents.count - 1];
            NSArray *components = [title componentsSeparatedByString:@"?"];
            if (components.count > 1) {
                title = [components objectAtIndex:0];
            }
            title = [title stringByReplacingOccurrencesOfString:@".pl" withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"-" withString:@" "];
            title = [title capitalizedString];
        }
        
        if ([request.URL.absoluteString rangeOfString:@"contact-us-faq.pl"].location == NSNotFound) {
            ContactUsWebViewController *controller = [ContactUsWebViewController new];
            controller.title = title;
            controller.url = request.URL;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            shouldStartLoad = YES;
        }
    }
    return shouldStartLoad;
}

- (void)reloadWebView {
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (NSURL *)url {
    if (_url) {
        return _url;
    } else {
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSString *urlString = [NSString stringWithFormat:@"https://m.tokopedia.com/bantuan?flag_app=3&device=ios&app_version=%@", appVersion];
        NSURL *initialURL = [NSURL URLWithString:urlString];
        return initialURL;
    }
}

@end
