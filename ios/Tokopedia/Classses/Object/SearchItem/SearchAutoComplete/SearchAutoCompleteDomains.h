//
//  SearchAutoCompleteDomains.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAutoCompleteGeneral.h"
#import "SearchAutoCompleteHotlist.h"

@interface SearchAutoCompleteDomains : NSObject

@property (nonatomic, strong) NSArray *hotlist;
@property (nonatomic, strong) NSArray *general;

@end
