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

-(void)multipleLineLabel:(UILabel*)label
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = label.textAlignment;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: label.textColor,
                                 NSFontAttributeName: label.font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label.text?:@""
                                                                         attributes:attributes];
    label.attributedText = attributedText;
    //return label;
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
