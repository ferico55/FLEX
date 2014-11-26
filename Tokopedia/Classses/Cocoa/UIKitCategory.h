//
//  UIKitCategory.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark - UIView
@interface UIView(TkpdCategory)

- (void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;
- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

@end

#pragma mark - UIImageView
@interface UIImageView(TkpdCategory)

+(UIImageView*)circleimageview:(UIImageView*)imageview;

- (void)setImage:(UIImage*)image animated:(BOOL)animated;

@end

#pragma mark - UILabel
@interface UILabel(TkpdCategory)

+(UIImageView*)circleimageview:(UIImageView*)imageview;

- (void)setText:(NSString*)text animated:(BOOL)animated;

@end
