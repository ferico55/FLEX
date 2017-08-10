//
//  CatalogSpecs.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpecChilds.h"

@interface CatalogSpecs : NSObject<TKPObjectMapping>

@property (strong, nonatomic, nonnull) NSArray *spec_childs;
@property (strong, nonatomic, nonnull) NSString *spec_header;

@end
