//
//  GoogleAnalyticsManager.h
//  Tokopedia
//
//  Created by Tonito Acen on 5/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GoogleAnalyticsManagerDelegate <NSObject>

@end

@interface GoogleAnalyticsManager : NSObject {

}

@property (weak, nonatomic) id<GoogleAnalyticsManagerDelegate> delegate;
@property (nonatomic) int tagLabel;


@end
