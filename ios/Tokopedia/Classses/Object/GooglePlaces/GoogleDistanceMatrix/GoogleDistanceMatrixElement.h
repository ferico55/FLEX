//
//  GoogleDistanceMatrixElement.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GoogleDistanceMatrixDetail.h"
#import "GoogleDistanceMatrixDuration.h"

@interface GoogleDistanceMatrixElement : NSObject <TKPObjectMapping>

@property(nonatomic, strong) GoogleDistanceMatrixDetail *distance;
@property (nonatomic, strong) GoogleDistanceMatrixDuration *duration;
@property (strong, nonatomic) NSString *status;

@end
