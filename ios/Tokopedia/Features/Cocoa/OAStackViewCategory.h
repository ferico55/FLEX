//
//  OAStackViewCategory.h
//  Tokopedia
//
//  Created by Samuel Edwin on 1/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import OAStackView;

@interface OAStackView(Extension)

- (void)setAttribute:(UILayoutConstraintAxis)axis
           alignment:(OAStackViewAlignment)alignment
        distribution:(OAStackViewDistribution)distribution
             spacing:(CGFloat)spacing;

@end
