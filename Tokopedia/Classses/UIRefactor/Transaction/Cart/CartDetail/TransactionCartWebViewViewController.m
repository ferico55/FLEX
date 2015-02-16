//
//  TransactionCartWebViewViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCartWebViewViewController.h"

@interface TransactionCartWebViewViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TransactionCartWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlAddress = @"https://klikpay.klikbca.com/purchasing/purchase.do?action=loginRequest";
    _webView.scalesPageToFit = YES;
    
    NSString *username = @"abc";
    NSString *password = @"abc";
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@",username, password]; //TODO::add bca_param
    NSLog(@"%@", postString);
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlAddress]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [_webView loadRequest:request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
