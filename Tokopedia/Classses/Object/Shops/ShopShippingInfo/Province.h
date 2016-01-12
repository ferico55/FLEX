//
//  Province.h
//  Tokopedia
//
//  Created by Tokopedia on 11/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Province : NSObject

@property NSInteger province_id;
@property (strong, nonatomic) NSString *province_name;
@property (strong, nonatomic) NSArray *cities;

@end
