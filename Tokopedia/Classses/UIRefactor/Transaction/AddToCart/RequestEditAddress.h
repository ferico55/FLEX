//
//  RequestEditAddress.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressFormList.h"

@protocol RequestEditAddressDelegate <NSObject>
@required
-(void)requestSuccessEditAddress:(id)successResult withOperation:(RKObjectRequestOperation*)operation;

@end

@interface RequestEditAddress : NSObject <TokopediaNetworkManagerDelegate>

@property (nonatomic, weak) IBOutlet id<RequestEditAddressDelegate> delegate;
-(void)doRequestWithAddress:(AddressFormList*)address;

@end
