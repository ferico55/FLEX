//
//  ReviewResponseComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "DetailReputationReview.h"

@interface ReviewResponseComponent : CKCompositeComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review
              imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                         role:(NSString*)role
                       action:(SEL)action;
@end
