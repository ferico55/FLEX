//
//  ReactTPRoutes.m
//  Tokopedia
//
//  Created by Tonito Acen on 7/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactTPRoutes.h"
#import "Tokopedia-Swift.h"
#import "ReactEventManager.h"

@implementation ReactTPRoutes

@synthesize bridge = _bridge;

- (id)initWithBridge:(RCTBridge *)bridge {
    if (self = [super init]) {
        _bridge = bridge;
    }
    return self;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(navigate:(NSString*)url) {
    if(url != nil) {
        [TPRoutes routeURL:[NSURL URLWithString:url]];
    }
}


RCT_EXPORT_METHOD(addNavbarRightButtons:(NSArray<NSDictionary*>*)buttonRawArray) {
    ReactEventManager *eventManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
    NSMutableArray *buttonArray = [NSMutableArray new];
    int flag = 0;
    for (NSDictionary *dict in buttonRawArray)
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                   bk_initWithImage:[UIImage imageNamed:dict[@"image"]]
                                   style:UIBarButtonItemStylePlain
                                   handler:^(id sender) {
                                       [eventManager navBarButtonTapped:[NSNumber numberWithInt:flag]];
                                   }];
        
        if(buttonRawArray.count <= 2){
            if(flag == 0){
                button.imageInsets = UIEdgeInsetsMake(0.0, -15, 0, 0);
            }else{
                button.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0, -15);
            }
        }
        flag++;

        [buttonArray addObject:button];
    }
    
    UIViewController* vc = [UIApplication topViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController]];
    vc.navigationItem.rightBarButtonItems = buttonArray;
}

@end
