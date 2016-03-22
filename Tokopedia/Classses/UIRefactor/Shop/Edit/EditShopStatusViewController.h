//
//  EditShopStatusViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopInfoResult.h"

@protocol EditShopStatusDelegate <NSObject>

- (void)didFinishEditShopClosedNote:(NSString *)note
                        closedUntil:(NSString *)until;

@end

@interface EditShopStatusViewController : UITableViewController

@property BOOL shopIsClosed;
@property (strong, nonatomic) NSString *closedNote;
@property (strong, nonatomic) NSString *closedUntil;

@property (weak, nonatomic) id<EditShopStatusDelegate> delegate;

@end
