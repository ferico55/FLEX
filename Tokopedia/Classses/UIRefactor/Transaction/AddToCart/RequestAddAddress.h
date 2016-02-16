//
//  RequestAddAddress.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressFormList.h"

@protocol RequestAddAddressDelegate <NSObject>
@required
-(void)requestSuccessAddAddress:(AddressFormList*)address;

@end

@interface RequestAddAddress : NSObject <TokopediaNetworkManagerDelegate>

@property (nonatomic, weak) IBOutlet id<RequestAddAddressDelegate> delegate;
-(void)doRequestWithAddress:(AddressFormList*)address;

@end
