//
//  NavigationBarBlurController.h
//  Tokopedia
//
//  Created by Harshad Dange on 08/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationBarBlurController : NSObject

- (void)setContentOffset:(CGPoint)contentOffset;
- (void)setNavigationBarTitle:(NSString *)navigationBarTitle withContentOffSet:(CGPoint)contentOffset;
- (void)removeNavigationImage;

@property (strong, nonatomic) UIImage *backgroundImage;
@property (weak, nonatomic) UINavigationBar *navigationBar;
@property (weak, nonatomic) NSString *navigationBarTitle;
@property (nonatomic) CGFloat threshold;
@property (nonatomic) CGFloat titleOffset;
@property (nonatomic) CGFloat maxOffset;
@property (nonatomic) CGFloat minimumOffset;

@end
