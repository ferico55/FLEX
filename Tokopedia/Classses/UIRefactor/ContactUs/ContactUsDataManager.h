//
//  ContactUsDataManager.h
//  Tokopedia
//
//  Created by Tokopedia on 9/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsResponse.h"

@protocol ContactUsDataManagerDelegate <NSObject>

- (void)didReceiveTicketResponse:(ContactUsResponse *)response;
- (void)didReceiveTicketError:(NSError *)error;

@end

@interface ContactUsDataManager : NSObject

@property (nonatomic, weak) id<ContactUsDataManagerDelegate> delegate;

- (void)requestTicketCategories;

@end
