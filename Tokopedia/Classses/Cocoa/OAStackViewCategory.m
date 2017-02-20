//
//  OAStackViewCategory.m
//  Tokopedia
//
//  Created by Samuel Edwin on 1/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "OAStackViewCategory.h"

@implementation OAStackView(Extension)

- (void)setAttribute:(UILayoutConstraintAxis)axis
           alignment:(OAStackViewAlignment)alignment
        distribution:(OAStackViewDistribution)distribution
             spacing:(CGFloat)spacing {
    self.axis = axis;
    self.alignment = alignment;
    self.distribution = distribution;
    self.spacing = spacing;
}

@end
