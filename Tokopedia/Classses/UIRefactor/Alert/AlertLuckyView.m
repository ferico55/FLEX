//
//  AlertLuckyView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertLuckyView.h"

@interface TKPDAlertView (TkpdCategory)

- (void)dismissindex:(NSInteger)index silent:(BOOL)silent animated:(BOOL)animated;

@end

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

-(void)roundingCorners:(UIRectCorner)corners radius:(CGFloat)radius
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
    [self roundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) radius:radius];
}

-(void)roundBottomCornersRadius:(CGFloat)radius
{
    [self roundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) radius:radius];
}

- (IBAction)tapKlikDisini:(id)sender {
    [self dismissWithClickedButtonIndex:0 animated:YES];
    
    NSURL *url = [NSURL URLWithString:_urlString];
    [[UIApplication sharedApplication] openURL:url];
}

//- (IBAction)gesture:(UITapGestureRecognizer *)sender
//{
//
//}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    [super dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if(self.superview != nil){
        [self dismissindex:buttonIndex silent:NO animated:animated];
    }
}

//#pragma mark -
//#pragma mark Methods
//
//- (void)show
//{
//    id<TKPDAlertViewDelegate> _delegate = self.delegate;
//    
//    [_gesture removeTarget:self action:@selector(gesture:)];
//    [_gesture addTarget:self action:@selector(gesture:)];
//    
//    if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(willPresentAlertView:)])) {
//        [_delegate willPresentAlertView:self];
//    }
//    
//    self.center = _window.center;
//    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
//    
//    [UIView transitionWithView:_window duration:TKPD_FADEANIMATIONDURATION options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
//        
//        [_window addSubview:self];
//        
//    } completion:^(BOOL finished) {
//        
//        if ((_delegate != nil) && ([_delegate respondsToSelector:@selector(didPresentAlertView:)])) {
//            [_delegate didPresentAlertView:self];
//        }
//    }];
//}

@end
