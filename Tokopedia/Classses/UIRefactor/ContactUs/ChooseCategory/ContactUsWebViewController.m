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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *contactUsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactUsButton;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contactUsBarButton;

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
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadWebView)];
    self.navigationItem.rightBarButtonItem = reloadButton;
    
    [self reloadWebView];
    
    self.contactUsButton.layer.cornerRadius = 3;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"GothamBook" size:13.0], NSFontAttributeName, nil];
    [self.contactUsBarButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
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
    CGFloat webViewContentHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    self.webViewHeightConstraint.constant = webViewContentHeight;
    [self.view layoutIfNeeded];
    self.footerView.hidden = NO;
}

- (void)reloadWebView {
    NSURL *redirectURL = [NSURL URLWithString:@"https://m.tokopedia.com/contact-us-faq.pl?flag_app=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:redirectURL];
    [self.webView loadRequest:request];
}

@end
