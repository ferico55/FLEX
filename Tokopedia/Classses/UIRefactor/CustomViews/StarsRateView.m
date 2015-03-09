//
//  StarsRateView.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/24/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "StarsRateView.h"

#pragma mark - Stars Rate View
@implementation StarsRateView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    _starimages = [NSArray sortViewsWithTagInArray:_starimages];
}

#pragma mark - properties
-(void)setStarscount:(NSInteger)starscount
{
    _starscount = starscount;
    if (starscount) {
        UIImage *image =[UIImage imageNamed:kTKPDIMAGE_ICONSTAR];
        UIImage *imageactive = [UIImage imageNamed:kTKPDIMAGE_ICONSTAR_ACTIVE];
        [_starimages makeObjectsPerformSelector:@selector(setImage:)withObject:image];

        for (int i =0; i<_starscount; i++) {
            ((UIImageView*)_starimages[i]).image = imageactive;
        }
    }
    else
    {
        [self reset];
    }
}

#pragma mark - methods
-(void)reset
{
    UIImage *image =[UIImage imageNamed:kTKPDIMAGE_ICONSTAR];
    [_starimages makeObjectsPerformSelector:@selector(setImage:)withObject:image];
}

@end
