//
//  RequestLDExtension.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LuckyDeal.h"

@class LuckyDealWord;

@protocol requestLDExttensionDelegate <NSObject>

@optional
-(void)showPopUpLuckyDeal:(LuckyDealWord*)words;
-(void)finishRequestLD;

@end

@interface RequestLDExtension : NSObject <TokopediaNetworkManagerDelegate>

@property (weak, nonatomic) id<requestLDExttensionDelegate> delegate;

@property LuckyDeal *luckyDeal;

-(void)doRequestMemberExtendURLString:(NSString*)urlString;


@end
