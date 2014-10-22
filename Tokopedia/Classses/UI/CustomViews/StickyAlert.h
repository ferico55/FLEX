//
//  BackgroundLayer.h
//  Tokopedia
//
//  Created by Tokopedia on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface StickyAlert : NSObject
-(void)alertError:(NSArray*)errorArray;
-(void)initView:(UIView*)view;

@end
