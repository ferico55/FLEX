//
//  LuckyDealAttributes.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuckyDealWord.h"

@interface LuckyDealAttributes : NSObject <TKPObjectMapping>

@property (strong, nonatomic, nonnull) NSString *token;
//@property NSInteger extid;
@property NSInteger extId;
@property NSInteger code;
@property NSInteger ut;
@property (strong, nonatomic, nonnull) NSString *success;
@property (strong, nonatomic, nonnull) LuckyDealWord *words;

@end
