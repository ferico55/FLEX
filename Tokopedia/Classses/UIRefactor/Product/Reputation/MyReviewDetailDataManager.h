//
//  MyReviewDetailDataManager.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailReputationReview.h"

@interface MyReviewDetailDataManager : NSObject

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView role:(NSString*)role;
- (void)replaceReviews:(NSArray<DetailReputationReview*>*)reviews;
- (void)addReviews:(NSArray<DetailReputationReview*>*)reviews;
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)announceWillAppearForItemInCell:(UICollectionViewCell*)cell;
- (void)announceDidDisappearForItemInCell:(UICollectionViewCell*)cell;
@end
