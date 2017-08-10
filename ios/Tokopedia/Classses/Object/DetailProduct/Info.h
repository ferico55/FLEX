//
//  Info.h
//  Tokopedia
//
//  Created by IT Tkpd on 4/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Info : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSString *product_returnable;
@property (nonatomic, strong, nonnull) NSString *shop_has_terms;

@end
