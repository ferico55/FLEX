//
//  RequestResoInputAddress.h
//  Tokopedia
//
//  Created by IT Tkpd on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InboxResolutionCenterList.h"
@class AddressFormList;

@protocol addressDelegate <NSObject>
@required
- (void)successAddress:(InboxResolutionCenterList*)resolution successStatus:(NSArray*)successStatus;
- (void)failedAddress:(InboxResolutionCenterList*)resolution errors:(NSArray*)errors;

@end

@interface RequestResoInputAddress : NSObject


@property (nonatomic, weak) IBOutlet id<addressDelegate> delegate;

@property InboxResolutionCenterList *resolution;
@property NSInteger resolutionID;
@property UIViewController *viewController;

-(void)setParamInputAddress:(AddressFormList*)address resolutionID:(NSString*)resolutionID oldDataID:(NSString*)oldDataID isEditAddress:(BOOL)isEditAddress action:(NSString*)action;

-(void)doRequest;

@end
