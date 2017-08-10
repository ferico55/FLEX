//
//  SpecChilds.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpecChilds : NSObject<TKPObjectMapping>

@property (strong, nonatomic, nonnull) NSArray *spec_val;
@property (strong, nonatomic, nonnull) NSString *spec_key;

@end
