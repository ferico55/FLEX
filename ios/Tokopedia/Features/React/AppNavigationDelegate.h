//
//  AppNavigationDelegate.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppNavigationDelegate <NSObject>

- (void)openViewWithName:(NSString *)name andParams:(NSDictionary *)params;

@optional

@end
