//
//  ReviewShareComponent.m
//  Tokopedia
//
//  Created by Billion Goenawan on 2/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReviewShareComponent.h"
#import "FBSDKShareKit.h"
#import "AHKActionSheet.h"
#import "UIColor+Theme.h"
#import <ComponentKit/ComponentKit.h>


@interface ReviewShareComponent ()

@end

@implementation ReviewShareComponent {
    DetailReputationReview *_review;
}

+ (instancetype)newWithReview:(DetailReputationReview*)review {
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
              action:@selector(didTapShare:)
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

- (void)didTapShare:(id)sender {
    AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:nil];
    
    [AnalyticsManager trackEventName:@"clickShare"
                            category:@"Share Review"
                              action:GA_EVENT_ACTION_CLICK
                               label:@"Share - Review"];
    
    // Ini untuk mengubah warna icon menjadi berwarna, kalau di set 1 jadi hitam putih
    actionSheet.automaticallyTintButtonImages = 0;
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [actionSheet addButtonWithTitle:@"Facebook" image:[UIImage imageNamed:@"icon_facebook"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *actionSheet) {
        FBSDKShareLinkContent *fbShareContent = [FBSDKShareLinkContent new];
        fbShareContent.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NSString tokopediaUrl] , _review.product_uri]];
        fbShareContent.quote = _review.review_message;
        
        [FBSDKShareDialog showFromViewController: rootViewController                                    withContent:fbShareContent
                                        delegate:nil];

    }];
    [actionSheet addButtonWithTitle:@"Lainnya"  image: [UIImage imageNamed:@"icon_more_grey"] type:AHKActionSheetButtonTypeDefault handler:^(AHKActionSheet *as) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[_review.review_message, [NSString stringWithFormat:@"%@/%@", [NSString tokopediaUrl], _review.product_uri]] applicationActivities:nil];
        
        [rootViewController presentViewController:activityVC animated:YES completion:nil];
    }];
    [actionSheet show];
}

@end
