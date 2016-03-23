//
//  DetailReputationReviewHeaderComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReview.h"
#import "ImageStorage.h"
#import <ComponentKit/ComponentKit.h>

@interface DetailReputationReviewHeaderComponent : CKCompositeComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review
                         role:(NSString*)role
           tapToProductAction:(SEL)action
              tapButtonAction:(SEL)buttonAction
              imageDownloader:(id<CKNetworkImageDownloading>)imageDownloader
                   imageCache:(ImageStorage*)imageCache;
@end
