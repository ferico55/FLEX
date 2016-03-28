//
//  ResolutionAttachment.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionAttachment : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *real_file_url;
@property (nonatomic, strong) NSString *file_url;

@end
