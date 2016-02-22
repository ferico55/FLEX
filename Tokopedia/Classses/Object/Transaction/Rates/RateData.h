//
//  RateData.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RateAttributes.h"

@interface RateData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *dataID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *attributes;

@end
