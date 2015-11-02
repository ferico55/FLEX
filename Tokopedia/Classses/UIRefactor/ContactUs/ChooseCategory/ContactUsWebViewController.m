//
//  ContactUsWebViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsWebViewController.h"
#import "ContactUsWireframe.h"
#import "TPContactUsDependencies.h"

@interface ContactUsWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *contactUsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactUsButton;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ContactUsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"FAQ";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadWebView)];
    self.navigationItem.rightBarButtonItem = reloadButton;
    
    [self reloadWebView];
    
    [self.webView.scrollView addSubview:_footerView];
    
    self.contactUsButton.layer.cornerRadius = 3;
    
    CGFloat webViewContentHeight = 700;
    
    CGRect frame = self.footerView.frame;
    frame.origin.y = webViewContentHeight;
    self.footerView.frame = frame;
    
    CGFloat newHeight = webViewContentHeight + frame.size.height;
    self.webView.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, newHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTabContactUsButton:(id)sender {
    TPContactUsDependencies *dependencies = [TPContactUsDependencies new];
    [dependencies pushContactUsViewControllerFromNavigation:self.navigationController];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.footerView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    CGFloat webViewContentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    self.footerView.hidden = NO;
}

- (void)reloadWebView {
    NSURL *url = [NSURL URLWithString:@"https://m-alpha.tokopedia.com/contact-us-faq.pl?flag_app=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
