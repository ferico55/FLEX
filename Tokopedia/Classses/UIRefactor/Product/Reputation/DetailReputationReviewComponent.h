//
//  DetailReputationReviewComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CKCompositeComponent.h"
#import "DetailReputationReview.h"
#import "DetailReputationReviewComponentDelegate.h"
#import "ImageStorage.h"
#import <ComponentKit/ComponentKit.h>

@interface DetailReputationReviewContext : NSObject
@property (nonatomic, weak) ImageStorage *imageCache;
@property id<CKNetworkImageDownloading> imageDownloader;
@property(weak, nonatomic) id<DetailReputationReviewComponentDelegate> delegate;
@end

@interface DetailReputationReviewComponent : CKCompositeComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review role:(NSString*)role isDetail:(BOOL)isDetail context:(DetailReputationReviewContext*)context;
@end
