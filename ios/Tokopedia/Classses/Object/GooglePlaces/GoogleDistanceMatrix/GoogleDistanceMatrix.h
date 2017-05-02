//
//  GoogleDistanceMatrix.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleDistanceMatrixRows.h"

@interface GoogleDistanceMatrix : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSArray *destination_addresses;
@property (strong, nonatomic) NSArray *origin_addresses;

@property (strong, nonatomic) NSArray *rows;
@property (strong, nonatomic) NSString *status;

@end
