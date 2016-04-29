//
//  MyReviewDetailHeaderDelegate.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailMyInboxReputation.h"

@protocol MyReviewDetailHeaderDelegate <NSObject>
- (void)didTapRevieweeNameWithID:(NSString*)revieweeID;
- (void)didTapRevieweeReputation:(id)sender role:(NSString*)role atView:(UIView*)view;
@end
