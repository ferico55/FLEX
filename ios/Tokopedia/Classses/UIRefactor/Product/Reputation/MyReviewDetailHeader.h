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
#import "MyReviewDetailHeaderSmileyDelegate.h"
#import "ImageStorage.h"

@interface MyReviewDetailContext : NSObject
@property (weak, nonatomic) ImageStorage *imageCache;
@property id<CKNetworkImageDownloading> imageDownloader;
@property (weak, nonatomic) id<MyReviewDetailHeaderDelegate> delegate;
@property (weak, nonatomic) id<MyReviewDetailHeaderSmileyDelegate> smileyDelegate;
@end

@interface MyReviewDetailHeader : CKComponentHostingView
- (instancetype)initWithInboxDetail:(DetailMyInboxReputation*)inbox
                         imageCache:(ImageStorage*)imageCache
                           delegate:(id<MyReviewDetailHeaderDelegate>)delegate
                     smileyDelegate:(id<MyReviewDetailHeaderSmileyDelegate>)smileyDelegate;
@end
