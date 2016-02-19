//
//  DetailReputationReviewComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CKCompositeComponent.h"
#import "DetailReputationReview.h"
#import <ComponentKit/ComponentKit.h>

@interface DetailReputationReviewContext : NSObject
@property id<CKNetworkImageDownloading> imageDownloader;
@end

@interface DetailReputationReviewComponent : CKCompositeComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review role:(NSString*)role context:(DetailReputationReviewContext*)context;
@end
