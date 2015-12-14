//
//  InboxResolutionCenterList.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionDetail.h"

@interface InboxResolutionCenterList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) ResolutionDetail *resolution_detail;
@property (nonatomic) NSInteger resolution_read_status;


@end
