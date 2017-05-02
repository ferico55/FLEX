//
//  Errors.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 6/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Errors : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;

+ (RKObjectMapping *)mapping;
   
@end
