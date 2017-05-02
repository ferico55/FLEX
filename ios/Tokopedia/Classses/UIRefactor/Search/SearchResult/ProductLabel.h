//
//  ProductLabel.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductLabel : NSObject
@property (strong, nonatomic, nonnull) NSString *title;
@property (strong, nonatomic, nonnull) NSString *color;


+(RKObjectMapping*)mapping;

@end
