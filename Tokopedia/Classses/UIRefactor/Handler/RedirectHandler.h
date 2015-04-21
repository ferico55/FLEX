//
//  RedirectHandler.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RedirectHandlerDelegate <NSObject>


@end

@interface RedirectHandler : NSObject {
    
}

@property (assign, nonatomic) id<RedirectHandlerDelegate> delegate;

- (void)proxyRequest:(int)state;

@end
