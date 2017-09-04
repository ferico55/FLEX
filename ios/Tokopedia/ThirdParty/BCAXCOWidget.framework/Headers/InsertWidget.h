//
//  InsertWidget.h
//  WidgetBCAFramework
//
//  Created by PT Bank Central Asia Tbk on 6/13/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InsertCardNumberView.h"

@interface InsertWidget : NSObject

@property (nonatomic, weak) id <BCADelegate> delegate;

@property (weak, nonatomic) NSString *accessToken;

+ (instancetype) sharedInstance;

- (void)startWidget;
- (void)stopWidget;

- (void)editDailyLimitWithView:(UIView *)masterView
                andAccessToken:(NSString *)accessToken
                        APIKey:(NSString *)APIKey
                       APISeed:(NSString *)APISeed
            customerIDMerchant:(NSString *)customerIDMerchant
                    merchantID:(NSString *)merchantID
                         XCOID:(NSString *)XCOID;

- (void)openWidgetWithView:(UIView *)masterView
            andAccessToken:(NSString *)accessToken
                    APIKey:(NSString *)APIKey
                   APISeed:(NSString *)APISeed
        customerIDMerchant:(NSString *)customerIDMerchant
                merchantID:(NSString *)merchantID;

- (void)submitRegistration;
- (void)submitUpdateLimit;
- (BOOL)isWidgetRunning;


/** NOTE ***/
// Get Access Token
// Please remove this method later
- (void)getAccessToken:(void (^)(NSString *accessToken))accessToken;

@end
