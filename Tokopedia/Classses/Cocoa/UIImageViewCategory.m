//
//  UIImageViewCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UIImageViewCategory.h"

@implementation UIImageView (tkpdCategory)

+(UIImageView*)circleimageview:(UIImageView*)imageview{
    imageview.layer.cornerRadius = imageview.frame.size.height /2;
    imageview.layer.masksToBounds = YES;
    imageview.layer.borderWidth = 0;
    
    return imageview;
}

@end
