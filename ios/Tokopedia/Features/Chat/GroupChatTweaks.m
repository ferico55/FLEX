//
//  GroupChatTweaks.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/26/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import "GroupChatTweaks.h"

@implementation GroupChatTweaks

+ (BOOL)alwaysShowGroupChat {
    return FBTweakValue(@"Others", @"GroupChat", @"Show GroupChat", NO);
}

@end
