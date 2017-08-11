//
//  TKPAppFlow.h
//  Tokopedia
//
//  Created by Harshad Dange on 18/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TKPStoreManager;

@protocol TKPAppFlow <NSObject>

- (TKPStoreManager *)storeManager;

@end
