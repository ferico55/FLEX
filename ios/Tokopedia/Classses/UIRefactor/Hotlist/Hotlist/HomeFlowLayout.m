//
//  HomeFlowLayout.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HomeFlowLayout.h"
@import QuartzCore;

@implementation HomeFlowLayout

-(void)prepareForCollectionViewUpdates:(NSArray *)updateItems{

}

-(void)prepareLayout
{

}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    [self.collectionView.viewForBaselineLayout.layer setSpeed:0.8f];
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    switch (self.transitionType) {
        case HomeFlowLayoutTransitionTypeHotlist:
            [self setInitialLayoutAttributesForHomeToHotlistTransition:attributes forItemAtIndexPath:itemIndexPath];
            break;
        default:
            break;
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    [self.collectionView.viewForBaselineLayout.layer setSpeed:0.1f];
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    switch (self.transitionType) {
        case HomeFlowLayoutTransitionTypeHotlist:
            [self setFinalLayoutAttributesForHomeToHotlistTransition:attributes forItemAtIndexPath:itemIndexPath];
            break;
        default:
            break;
    }
    
    return attributes;
}


- (void)setInitialLayoutAttributesForHomeToHotlistTransition:(UICollectionViewLayoutAttributes *)attributes forItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    CGPoint center = attributes.center;
    center.y = 120.0f;
    [attributes setCenter:center];
    [attributes setAlpha:0.2f];
}

- (void)setFinalLayoutAttributesForHomeToHotlistTransition:(UICollectionViewLayoutAttributes *)attributes forItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    [self setFinalLayoutAttributesForHomeToSearchTransition:attributes forItemAtIndexPath:itemIndexPath];
}

- (void)setFinalLayoutAttributesForHomeToSearchTransition:(UICollectionViewLayoutAttributes *)attributes forItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    CGPoint center = attributes.center;
    center.y = self.collectionView.bounds.size.height;
    attributes.center = center;
    attributes.alpha = 0.0f;
}

@end
