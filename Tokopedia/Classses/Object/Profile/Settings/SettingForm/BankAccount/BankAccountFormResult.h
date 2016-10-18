//
//  BankAccountFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"
#import "BankAccountFormList.h"

@interface BankAccountFormResult : NSObject

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray<BankAccountFormList*> *list;

+ (RKObjectMapping *)mapping;

@end
