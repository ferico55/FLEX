//
//  UIKitCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UIKitCategory.h"

#pragma mark - UIView
@implementation UIView (Tkpdcategory)

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

-(UIView*)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    CGRect bounds = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = self.backgroundColor.CGColor;
    frameLayer.fillColor = nil;
    
    [self.layer addSublayer:frameLayer];
    
    return self;
}

@end

@implementation UIButton (TkpdCategory)

-(UIButton*)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius
{
    CGRect bounds = self.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = self.backgroundColor.CGColor;
    frameLayer.fillColor = nil;
    
    [self.layer addSublayer:frameLayer];
    
    return self;
}

-(void)setCustomAttributedText:(NSString *)text
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    [style setLineSpacing:6.0];
    
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:self.font,
                            NSParagraphStyleAttributeName:style};
    
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", text] attributes:dict1]];
    [self setAttributedTitle:attString forState:UIControlStateNormal];
}

@end

#pragma mark - UIImageView
@implementation UIImageView (TkpdCategory)

+(UIImageView*)circleimageview:(UIImageView*)imageview{
    imageview.layer.cornerRadius = imageview.frame.size.height /2;
    imageview.layer.masksToBounds = YES;
    imageview.layer.borderWidth = 0;
    
    return imageview;
}

- (void)setImage:(UIImage*)image animated:(BOOL)animated
{
	[self setImage:image animated:animated options:(UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut)];
}

- (void)setImage:(UIImage*)image animated:(BOOL)animated options:(UIViewAnimationOptions)options
{
	if (animated) {
		[UIView transitionWithView:self duration:TKPD_FADEANIMATIONDURATION options:options animations:^{
			self.image = image;
		} completion:NULL];
		
	} else {
		self.image = image;
	}
}

@end

#pragma mark - UILabel
@implementation UILabel (Tkpdcategory)

- (void)setText:(NSString*)text animated:(BOOL)animated
{
	[self setText:text animated:animated options:(UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut)];
}

- (void)setText:(NSString*)text animated:(BOOL)animated options:(UIViewAnimationOptions)options
{
	if (animated) {
		[UIView transitionWithView:self duration:TKPD_FADEANIMATIONDURATION options:options animations:^{
			self.text = text;
		} completion:NULL];
		
	} else {
		self.text = text;
	}
}

-(void)setCustomAttributedText:(NSString *)text
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = self.textAlignment;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: self.textColor?:[UIColor blackColor],
                                 NSFontAttributeName: self.font?:[UIFont smallTheme],
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text?:@""
                                                                         attributes:attributes];
    self.attributedText = attributedText;
}

- (void)attributedLabel:(UILabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([[url scheme] hasPrefix:@"action"]) {
        if ([[url host] hasPrefix:@"show-help"]) {
            /* load help screen */
        } else if ([[url host] hasPrefix:@"show-settings"]) {
            /* load settings screen */
        }
    } else {
        /* deal with http links here */
    }
}
@end
