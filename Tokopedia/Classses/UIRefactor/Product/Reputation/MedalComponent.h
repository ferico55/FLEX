//
//  MedalComponent.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CKCompositeComponent.h"
#import <ComponentKit/ComponentKit.h>

@interface MedalComponent : CKCompositeComponent
+ (instancetype)newMedalWithLevel:(NSInteger)level set:(NSInteger)set;
@end
