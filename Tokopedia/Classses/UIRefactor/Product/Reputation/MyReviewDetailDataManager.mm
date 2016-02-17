//
//  MyReviewDetailDataManager.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailDataManager.h"
#import <ComponentKit/ComponentKit.h>

@implementation MyReviewDetailDataManager {
    CKCollectionViewDataSource* _dataSource;
    CKComponentFlexibleSizeRangeProvider *_sizeRangeProvider;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView {
    if (self = [super init]) {
        _sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
        _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                                     supplementaryViewDataSource:nil
                                                               componentProvider:[self class]
                                                                         context:nil
                                                       cellConfigurationFunction:nil];
        
        CKArrayControllerSections sections;
        sections.insert(0);
        [_dataSource enqueueChangeset:sections constrainedSize:{}];
    }
    return self;
}

- (void)replaceReviews:(NSArray<DetailReputationReview*>*)reviews {
    CKArrayControllerInputItems items;
    
    for (NSInteger index = 0; index < reviews.count; index++) {
        items.insert({0, index}, reviews[index]);
    }

    [_dataSource enqueueChangeset:items
                  constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:_dataSource.collectionView.bounds.size]];
}

- (void)addReviews:(NSArray<DetailReputationReview*>*)reviews {
    
}

+ (CKComponent *)componentForModel:(DetailReputationReview*)model context:(id<NSObject>)context {
    return [CKLabelComponent
            newWithLabelAttributes:{
                .string = model.product_name
            }
            viewAttributes:{}
            size:{}];
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dataSource sizeForItemAtIndexPath:indexPath];
}

- (void)announceWillAppearForItemInCell:(UICollectionViewCell *)cell {
    [_dataSource announceWillAppearForItemInCell:cell];
}

- (void)announceDidDisappearForItemInCell:(UICollectionViewCell *)cell {
    [_dataSource announceDidDisappearForItemInCell:cell];
}

@end
