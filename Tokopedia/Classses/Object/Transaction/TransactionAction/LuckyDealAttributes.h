//
//  LuckyDealAttributes.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuckyDealAttributes : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *extid;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *ut;

@end
