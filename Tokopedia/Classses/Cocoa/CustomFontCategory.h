//
//  CustomFontCategory.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (TkpdCategory)
@property (nonatomic, copy) NSString* fontName;
@end

@interface UIButton (TkpdCategory)
@property (nonatomic, copy) NSString* fontName;
@end
