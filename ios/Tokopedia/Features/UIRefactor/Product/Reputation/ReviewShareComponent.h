//
//  ReviewShareComponent.h
//  Tokopedia
//
//  Created by Billion Goenawan on 2/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import "DetailReputationReview.h"
#import "ImageStorage.h"

@interface ReviewShareComponent : CKCompositeComponent
    
+ (instancetype)newWithReview:(DetailReputationReview*)review tapButtonAction:(SEL)buttonAction;
    
@end
