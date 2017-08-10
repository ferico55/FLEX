//
//  OrderDetailProductInformationCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderDetailProductInformationCell.h"

@implementation OrderDetailProductInformationCell

static CGFloat textMarginVertical = 40.0f;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 220.0f;
    } else {
        return 400.0f;
    }
}

+ (CGSize)messageSize:(NSString*)message {
    message = [message stringByAppendingString:@"\n"];
    CGRect messageRect = [message boundingRectWithSize:CGSizeMake([self maxTextWidth], CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{ NSFontAttributeName:[UIFont largeTheme] }
                                               context:nil];
    
    return messageRect.size;
}

+ (CGFloat)textMarginVertical {
    return textMarginVertical;
}

@end
