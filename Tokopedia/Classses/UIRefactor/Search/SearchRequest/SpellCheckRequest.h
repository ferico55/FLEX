//
//  SpellCheckRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 10/26/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellCheckResponse.h"

@protocol SpellCheckRequestDelegate <NSObject>

-(void)didReceiveSpellSuggestion:(NSString *)suggestion totalData:(NSString *)totalData;

@end


@interface SpellCheckRequest : NSObject

@property (weak, nonatomic) id<SpellCheckRequestDelegate> delegate;

- (void)getSpellingSuggestion:(NSString*)type query:(NSString *)query category:(NSString *)category;
- (void)requestSpellingSuggestion;

@end
