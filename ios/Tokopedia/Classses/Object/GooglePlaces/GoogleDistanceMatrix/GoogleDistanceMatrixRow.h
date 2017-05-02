//
//  GoogleDistanceMatrixRow.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleDistanceMatrixElements.h"

@interface GoogleDistanceMatrixRow : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSArray *elements;

@end
