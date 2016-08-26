//
//  ResolutionCenterCreatePOSTFormSolution.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionCenterCreatePOSTFormSolution : NSObject
@property (strong, nonatomic) NSString* refund_type;
@property (strong, nonatomic) NSString* show_refund_box;
@property (strong, nonatomic) NSString* max_refund;
@property (strong, nonatomic) NSString* max_refund_idr;
@property (strong, nonatomic) NSString* solution_text;
@property (strong, nonatomic) NSString* solution_id;
@property (strong, nonatomic) NSString* refund_text_desc;

+(RKObjectMapping*)mapping;
@end
