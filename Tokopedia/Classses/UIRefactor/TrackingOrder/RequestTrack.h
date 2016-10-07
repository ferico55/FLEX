//
//  RequestTrack.h
//  Tokopedia
//
//  Created by Renny Runiawati on 4/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

@interface RequestTrack : NSObject

+(void)fetchTrackResoAWB:(NSString*)AWB
              shipmentID:(NSString*)shipmentID
                 success:(void(^)(TrackOrderResult* data))success
                  failed:(void(^)(NSError * error))failed;

+(void)fetchTrackOrderID:(NSString*)orderID
                 success:(void(^)(TrackOrderResult* data))success
                  failed:(void(^)(NSError * error))failed;

@end
