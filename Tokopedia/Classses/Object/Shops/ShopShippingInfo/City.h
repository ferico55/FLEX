//
//  City.h
//  Tokopedia
//
//  Created by Tokopedia on 11/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject

@property NSInteger city_id;
@property (strong, nonatomic) NSString *city_name;
@property (strong, nonatomic) NSArray *districts;

@end
