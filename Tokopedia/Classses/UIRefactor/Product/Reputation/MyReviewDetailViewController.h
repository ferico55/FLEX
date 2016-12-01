//
//  MyReviewDetailViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailMyInboxReputation;

@interface MyReviewDetailViewController : UIViewController

@property (nonatomic, weak) DetailMyInboxReputation *detailMyInboxReputation;
@property (nonatomic, weak) NSString* autoRead;
@property (nonatomic, copy) void (^onSmileyTapped)();
@property (nonatomic, copy) void (^didDetailReviewUpdated)();
@property int tag;

@end
