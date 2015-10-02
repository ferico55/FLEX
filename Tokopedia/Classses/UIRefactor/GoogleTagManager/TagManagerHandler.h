//
//  TagManagerHandler.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/1/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagDataLayer.h"

@interface TagManagerHandler : NSObject {

}

+ (TAGContainer*)getContainer;
- (void)pushDataLayer:(NSDictionary*)data;


@end
