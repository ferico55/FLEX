//
//  MyReviewDetailDataManager.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailDataManager.h"
#import <ComponentKit/ComponentKit.h>
#import "DetailReputationReviewComponent.h"
#import "AFNetworkingImageDownloader.h"
#import "DetailMyInboxReputation.h"

@interface MyReviewDetailModel : NSObject
@property DetailReputationReview *review;
@property NSString *role;
@property BOOL isDetail;
@end

@implementation MyReviewDetailModel

@end

@implementation MyReviewDetailDataManager {
    CKCollectionViewDataSource* _dataSource;
    CKComponentFlexibleSizeRangeProvider *_sizeRangeProvider;
    NSString *_role;
    BOOL _isDetail;
    NSArray<DetailReputationReview*>* _reviews;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView role:(NSString*)role isDetail:(BOOL)isDetail imageCache:(ImageStorage *)imageCache delegate:(id<DetailReputationReviewComponentDelegate>)delegate  {
    if (self = [super init]) {
        _role = role;
        _isDetail = isDetail;
        
        DetailReputationReviewContext* context = [DetailReputationReviewContext new];
        context.imageDownloader = [AFNetworkingImageDownloader new];
        context.delegate = delegate;
        context.imageCache = imageCache;
        
        _sizeRangeProvider = [CKComponentFlexibleSizeRangeProvider providerWithFlexibility:CKComponentSizeRangeFlexibleHeight];
        _dataSource = [[CKCollectionViewDataSource alloc] initWithCollectionView:collectionView
                                                     supplementaryViewDataSource:nil
                                                               componentProvider:[self class]
                                                                         context:context
                                                       cellConfigurationFunction:nil];
        
        CKArrayControllerSections sections;
        sections.insert(0);
        [_dataSource enqueueChangeset:sections constrainedSize:{}];
    }
    return self;
}

- (void)replaceReviews:(NSArray<DetailReputationReview*>*)reviews {
    CKArrayControllerInputItems items;
    _reviews = reviews;
    
    for (NSInteger index = 0; index < reviews.count; index++) {
        MyReviewDetailModel* model = [MyReviewDetailModel new];
        model.review = reviews[index];
        model.role = _role;
        model.isDetail = _isDetail;
        items.insert({0, index}, model);
    }

    [_dataSource enqueueChangeset:items
                  constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:_dataSource.collectionView.bounds.size]];
}

- (void)addReviews:(NSArray<DetailReputationReview*>*)reviews {
    
}

- (void)removeAllReviews {
    CKArrayControllerInputItems items;
    for (NSInteger index = 0; index < _reviews.count; index++) {
        items.remove({0, index});
    }
    
    [_dataSource enqueueChangeset:items
                  constrainedSize:[_sizeRangeProvider sizeRangeForBoundingSize:_dataSource.collectionView.bounds.size]];
    
}

+ (CKComponent *)componentForModel:(MyReviewDetailModel*)model context:(DetailReputationReviewContext*)context {
    return [DetailReputationReviewComponent newWithReview:model.review role:model.role isDetail:model.isDetail context:context];
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
