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
- (UIView*)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius;
@end

#pragma mark - UIImageView
@interface UIImageView(TkpdCategory)

+(UIImageView*)circleimageview:(UIImageView*)imageview;
- (void)setImage:(UIImage*)image animated:(BOOL)animated;

@end

#pragma mark - UILabel
@interface UILabel(TkpdCategory)

- (void)setText:(NSString*)text animated:(BOOL)animated;
-(void)setCustomAttributedText:(NSString *)text;

@end

@interface UIButton (TkpdCategory)

- (UIButton*)roundCorners:(UIRectCorner)corners radius:(CGFloat)radius;
- (void)setCustomAttributedText:(NSString *)text;

@end

@interface UINavigationController (CompletionHandler)

- (void)pushViewController:(UIViewController *)viewController
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion;

@end
