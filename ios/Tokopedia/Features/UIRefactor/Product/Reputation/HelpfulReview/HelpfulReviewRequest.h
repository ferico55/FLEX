//
//  HelpfulReviewRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 1/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailReputationReview.h"

@protocol HelpfulReviewRequestDelegate <NSObject>

- (void)didReceiveHelpfulReview:(NSArray*)helpfulReview;

@end

@interface HelpfulReviewRequest : NSObject
@property (weak, nonatomic) id<HelpfulReviewRequestDelegate> delegate;
- (void)requestHelpfulReview:(NSString*) productId;
@end
