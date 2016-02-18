//
//  DetailReputationReviewComponent.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DetailReputationReviewComponent.h"
#import "DetailReputationReviewHeaderComponent.h"
#import <ComponentKit/ComponentKit.h>

static CKComponent* messageLabel(NSString* message) {
    if (![message boolValue]) {
        return nil;
    }
    
    return [CKInsetComponent
            newWithInsets:{8,8,8,8}
            component:
            [CKLabelComponent
             newWithLabelAttributes:{
                 .string = message,
                 .font = [UIFont fontWithName:@"Gotham Book" size:14],
                 .maximumNumberOfLines = 0,
                 .lineSpacing = 0.6
             }
             viewAttributes:{}
             size:{}]];
}

@implementation DetailReputationReviewComponent
+ (instancetype)newWithReview:(DetailReputationReview*)review {
    UIColor* buttonColor = [UIColor colorWithRed:18.0/255
                                           green:199.0/255
                                            blue:0
                                           alpha:1];
    
    return [super newWithComponent:
            [CKInsetComponent
             newWithView:{}
             insets:{8, 8, 8, 8}
             component:
                 [CKStackLayoutComponent
                  newWithView:{
                      [UIView class],
                      {
                          {@selector(setBackgroundColor:), [UIColor whiteColor]}
                      }
                  }
                  size:{}
                  style:{
                      .direction = CKStackLayoutDirectionVertical,
                      .alignItems = CKStackLayoutAlignItemsStretch,
                      .justifyContent = CKStackLayoutJustifyContentCenter
                  }
                  children:{
                      {
                          //header
                          [DetailReputationReviewHeaderComponent newWithReview:review]
                      },
                      {
                          messageLabel(review.review_message)
                      },
                      {
                          [CKButtonComponent
                           newWithTitles:{
                               {UIControlStateNormal, @"Beri Ulasan"}
                           }
                           titleColors:{
                               {UIControlStateNormal, buttonColor}
                           }
                           images:{}
                           backgroundImages:{}
                           titleFont:[UIFont fontWithName:@"Gotham Medium" size:14.0]
                           selected:NO
                           enabled:YES
                           action:nil
                           size:{.height = 30}
                           attributes:{
                               {CKComponentViewAttribute::LayerAttribute(@selector(setBorderWidth:)), 2.0},
                               {CKComponentViewAttribute::LayerAttribute(@selector(setCornerRadius:)), 5.0},
                               {CKComponentViewAttribute::LayerAttribute(@selector(setBorderColor:)), (id)[buttonColor CGColor]},
                               {@selector(setClipsToBounds:), YES},
                               {@selector(setContentHorizontalAlignment:), UIControlContentHorizontalAlignmentCenter}
                           }
                           accessibilityConfiguration:{}],
                          .flexGrow = YES
                      },
                  }]
             ]];
}
@end
