//
//  ReviewShareComponent.m
//  Tokopedia
//
//  Created by Billion Goenawan on 2/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReviewShareComponent.h"
#import "UIColor+Theme.h"
#import <ComponentKit/ComponentKit.h>


@interface ReviewShareComponent ()

@end

@implementation ReviewShareComponent {
    DetailReputationReview *_review;
}

+ (instancetype)newWithReview:(DetailReputationReview*)review
              tapButtonAction:(SEL)buttonAction {
    if ([review.review_message isEqualToString:@"0"] || review.review_message == nil) {
        return nil;
    }
    
    
    ReviewShareComponent *component = [super newWithComponent:
            [CKInsetComponent
             newWithInsets:{8,8,8,8}
             component:
             [CKButtonComponent
              newWithTitles:{
                  {UIControlStateNormal, @"Bagikan"}
              }
              titleColors:{
                  {UIControlStateNormal, [UIColor tpGreen]}
              }
              images:{}
              backgroundImages:{}
              titleFont:[UIFont largeThemeMedium]
              selected:NO
              enabled:YES
              action:buttonAction
              size:{.height = 30}
              attributes:{
                  {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                  {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                  {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[[UIColor colorWithRed:60/255.0 green:179/255.0 blue:57/255.0 alpha:1.0] CGColor]},
                  {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
              }
              accessibilityConfiguration:{
              }]
             ]];
    
    component ->_review = review;
    return component;
    
}

@end
