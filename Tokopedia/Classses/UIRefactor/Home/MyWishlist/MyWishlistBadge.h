//
//  MyWishlistBadge.h
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyWishlistBadge : NSObject <TKPObjectMapping>
    @property (nonatomic, strong) NSString *title;
    @property (nonatomic, strong) NSString *image_url;
@end
