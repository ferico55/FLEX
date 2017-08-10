//
//  CatalogResult.h
//  Tokopedia
//
//  Created by Renny Runiawati on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatalogList.h"

@interface CatalogResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSArray<CatalogList*> *list;

@end
