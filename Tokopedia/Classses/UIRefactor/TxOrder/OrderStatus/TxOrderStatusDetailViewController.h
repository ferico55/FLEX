//
//  TxOrderStatusDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TxOrderStatusList;

@interface TxOrderStatusDetailViewController : UIViewController

@property (nonatomic , strong) TxOrderStatusList *order;

@property (nonatomic, copy) void(^didReorder)(TxOrderStatusList *);
@property (nonatomic, copy) void(^didReceivedOrder)(TxOrderStatusList *);
@property (nonatomic, copy) void(^didComplaint)(TxOrderStatusList *);
@property (nonatomic, copy) void(^didRequestCancel)(TxOrderStatusList *);
@property (nonatomic, copy) void(^didCancelComplaint)(TxOrderStatusList *);
@property (nonatomic, copy) void(^didCreateComplaint)(TxOrderStatusList *);

@end
