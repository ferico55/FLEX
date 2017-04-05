//
//  EncodeDecoderManager.h
//  Tokopedia
//
//  Created by Tokopedia on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodeDecoderManager : NSObject

- (NSString*)getRandomUUID;
- (NSString*)getKey;
- (NSString*)encryptKeyAndIv;
- (NSString*)encryptParams:(NSString*)param;


@end
