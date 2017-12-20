//
//  AddressFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
#import "AddressFormList.h"

@interface AddressFormResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) ShipmentKeroToken *keroToken;
@property (nonatomic, strong) NSArray<AddressFormList*> *list;

@end
