//
//  EtalaseListOther.h
//  Tokopedia
//
//  Created by Johanes Effendi on 4/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EtalaseListOther : NSObject
@property (strong, nonatomic) NSString* etalase_url;
@property (strong, nonatomic) NSString* etalase_id;
@property (strong, nonatomic) NSString* etalase_name;
@property (strong, nonatomic) NSString* etalase_badge;

+(RKObjectMapping*)mapping;
@end
