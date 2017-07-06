//
//  OrderCellContext.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ComponentKit/CKNetworkImageDownloading.h>

@class TxOrderStatusList;

@interface OrderCellContext : NSObject

@property id<CKNetworkImageDownloading> imageDownloader;
@property (nonatomic, strong) NSDictionary *images;

@property (nonatomic, copy) void(^onTapReorder)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapSeeComplaint)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapReceivedOrder)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapComplaintNotReceived)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapTracking)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapAskSeller)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapCancel)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapShop)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapInvoice)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapDetail)(TxOrderStatusList *);
@property (nonatomic, copy) void(^onTapCancelReplacement)(TxOrderStatusList *);

@end
