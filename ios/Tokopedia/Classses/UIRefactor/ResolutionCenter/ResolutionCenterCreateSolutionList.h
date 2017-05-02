//
//  ResolutionCenterCreateSolutionList.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionCenterCreateSolutionList : NSObject
@property (strong, nonatomic) NSString* refund_type;
@property (strong, nonatomic) NSString* attachment;
@property (strong, nonatomic) NSString* solution_text;
@property (strong, nonatomic) NSString* solution_id;
+(RKObjectMapping*)mapping;
@end
