//
//  WebViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@import NJKWebViewProgress;

@interface WebViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
{

}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *strContentHTML;
@property (nonatomic, strong) NSString *strURL;
@property (nonatomic, strong) NSString *strTitle;

@property(copy) void(^onTapLinkWithUrl)(NSURL* url);

@property BOOL isLPWebView;

@end
