//
//  ShopInfoResult.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopEditInfo.h"
#import "ShopCloseDetail.h"
#import "ShopInfoImage.h"

@interface ShopInfoResult : NSObject

@property (strong, nonatomic) ShopEditInfo *info;
@property (strong, nonatomic) NSString *is_allow;
@property (strong, nonatomic) ShopCloseDetail *closed_detail;
@property (strong, nonatomic) ShopInfoImage *image;

@property BOOL isOpen;
@property BOOL isClosed;

+ (RKObjectMapping *)mapping;

@end
