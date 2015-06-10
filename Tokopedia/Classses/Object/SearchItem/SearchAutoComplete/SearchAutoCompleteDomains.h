//
//  SearchAutoCompleteDomains.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAutoCompleteCatalog.h"
#import "SearchAutoCompleteCategory.h"

@interface SearchAutoCompleteDomains : NSObject

@property (nonatomic, strong) NSArray *catalog;
@property (nonatomic, strong) NSArray *category;

@end
