//
//  TagManagerHandler.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/1/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TagManagerHandler.h"

@implementation TagManagerHandler

- (instancetype)init {
    self = [super init];
    if(self) {

    }
    
    return self;
}

- (void)pushDataLayer:(NSDictionary *)data {
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    [dataLayer push:data];
}

+ (TAGContainer*)getContainer {
    TAGContainer *_gtmContainer;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    return _gtmContainer;
}


@end
