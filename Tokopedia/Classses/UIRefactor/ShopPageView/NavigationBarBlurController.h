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

@property (strong, nonatomic) UIImage *backgroundImage;
@property (weak, nonatomic) UINavigationBar *navigationBar;
@property (nonatomic) CGFloat threshold;
@property (nonatomic) CGFloat maxOffset;
@property (nonatomic) CGFloat minimumOffset;

@end
