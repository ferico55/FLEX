//
//  AudioCampaignTweaks.m
//  Tokopedia
//
//  Created by Vishun Dayal on 17/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import "AudioCampaignTweaks.h"

@implementation AudioCampaignTweaks
- (BOOL)shallUseFirebaseValueForShake {
#if DEBUG
    return FBTweakValue(@"Others", @"Shake-Shake", @"Use Firebase", YES);
#endif
    return YES;
}
@end
