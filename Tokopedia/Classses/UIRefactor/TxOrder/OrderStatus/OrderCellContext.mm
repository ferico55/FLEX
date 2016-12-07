//
//  OrderCellContext.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <ComponentKit/ComponentKit.h>
#import <ComponentKit/CKNetworkImageDownloading.h>

#import "OrderCellContext.h"

@implementation OrderCellContext

-(instancetype)init{
    
    UIImage *arrowImage = [UIImage imageNamed:@"icon_arrow_right_grey.png"];
    self.images = @{@"arrow" : arrowImage};
    
    return self;
}

@end
