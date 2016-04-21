//
//  ReportViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 3/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReportViewControllerDelegate <NSObject>

@required
- (NSDictionary*)getParameter;
- (NSString*)getPath;
- (UIViewController*)didReceiveViewController;

@optional
- (void)didFinishWritingReportWithReviewID:(NSString*)reviewID
                                    talkID:(NSString*)talkID
                                    shopID:(NSString*)shopID
                               textMessage:(NSString*)textMessage;

@end

@interface ReportViewController : UIViewController

@property (weak, nonatomic) id<ReportViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *strProductID;
@property (nonatomic, strong) NSString *strCommentTalkID;
@property (nonatomic, strong) NSString *strShopID;
@property (nonatomic, strong) NSString *strReviewID;
@end
