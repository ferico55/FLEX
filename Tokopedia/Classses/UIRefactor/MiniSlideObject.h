//
//  MiniSlideObject.h
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MiniSlideData.h"


@interface MiniSlideObject : NSObject <TKPObjectMapping>

@property(strong, nonatomic) MiniSlideData *data;

@end
