//
//  WebViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

@interface WebViewController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    IBOutlet UIWebView *webView;
}

@property (nonatomic, strong) NSString *strContentHTML;
@property (nonatomic, strong) NSString *strURL;
@property (nonatomic, strong) NSString *strTitle;

@property(copy) void(^onTapButtonWithURL)(NSURL* url);

@property BOOL isLPWebView;

@end
