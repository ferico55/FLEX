//
//  XCODelegate.h
//  BCAXCOWidget
//
//  Created by PT Bank Central Asia Tbk on 8/3/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BCADelegate <NSObject>

- (void)onBCASuccess:(NSDictionary *)successObject;
- (void)onBCATokenExpired:(NSString *)tokenStatus;
- (void)onBCARegistered:(NSString *)XCOID;
- (void)onBCACloseWidget;

@end
