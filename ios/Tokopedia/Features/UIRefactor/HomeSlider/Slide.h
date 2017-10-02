//
//  Slide.h
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Slide : NSObject <TKPObjectMapping>

@property(strong, nonatomic) NSString *slideId;
@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSString *message;
@property(strong, nonatomic) NSString *image_url;
@property(strong, nonatomic) NSString *redirect_url;
@property(strong, nonatomic) NSString *applinks;

@end
