//
//  AlertLuckyView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertLuckyView.h"

@implementation AlertLuckyView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    
}

-(void)setUpperView:(UIView *)upperView
{
    _upperView = upperView;
    [self roundTopCornersRadius:5.0f];
}

-(void)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    CGRect bounds = self.upperView.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.upperView.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = self.upperColor.CGColor;
    frameLayer.fillColor = nil;
    
    [self.upperView.layer addSublayer:frameLayer];
}

-(void)roundTopCornersRadius:(CGFloat)radius
{
    [self roundCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) radius:radius];
}

-(void)roundBottomCornersRadius:(CGFloat)radius
{
    [self roundCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) radius:radius];
}

- (IBAction)tapKlikDisini:(id)sender {
    NSURL *url = [NSURL URLWithString:_urlString];
    [[UIApplication sharedApplication] openURL:url];
}


@end
