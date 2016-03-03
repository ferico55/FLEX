//
//  SliderObject.h
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SliderData.h"

@interface SliderObject : NSObject <TKPObjectMapping>

@property(strong, nonatomic) SliderData *data;

@end
