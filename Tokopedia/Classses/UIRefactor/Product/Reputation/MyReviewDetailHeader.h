//
//  MyReviewDetailHeader.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ComponentKit/CKComponentHostingView.h>
#import <ComponentKit/CKNetworkImageDownloading.h>
#import "DetailMyInboxReputation.h"
#import "MyReviewDetailHeaderDelegate.h"

@interface MyReviewDetailContext : NSObject
@property id<CKNetworkImageDownloading> imageDownloader;
@property (weak, nonatomic) id<MyReviewDetailHeaderDelegate> delegate;
@end

@interface MyReviewDetailHeader : CKComponentHostingView
- (instancetype)initWithInboxDetail:(DetailMyInboxReputation*)inbox;
@end
