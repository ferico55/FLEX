//
//  TxOrderInvoiceViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderInvoiceViewController.h"

@interface TxOrderInvoiceViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TxOrderInvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView.scalesPageToFit = YES;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:_urlAddress]];
    [_webView loadRequest:request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
