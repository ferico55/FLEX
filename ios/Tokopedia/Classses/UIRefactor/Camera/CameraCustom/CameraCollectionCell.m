//
//  CameraCollectionCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "CameraCollectionCell.h"

@implementation CameraCollectionCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"CameraCollectionCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - properties
- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    _thumb.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end
