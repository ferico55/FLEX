//
//  ProductReputationViewModel.h
//  Tokopedia
//
//  Created by Tonito Acen on 11/26/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductReputationViewModel : NSObject

@property (strong, nonatomic) NSString *reviewUserName;
@property (strong, nonatomic) NSString *reviewDate;
@property (strong, nonatomic) NSString *productQuality;
@property (strong, nonatomic) NSString *productAccuracy;
@property (strong, nonatomic) NSString *reviewMessage;
@property (strong, nonatomic) NSString *reviewUserThumbUrl;

@end
