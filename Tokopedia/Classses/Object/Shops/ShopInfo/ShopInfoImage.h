//
//  ShopInfoImage.h
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopInfoImage : NSObject

@property (strong, nonatomic) NSString *logo;
@property (strong, nonatomic) NSString *og_image;

+ (RKObjectMapping *)mapping;

@end
