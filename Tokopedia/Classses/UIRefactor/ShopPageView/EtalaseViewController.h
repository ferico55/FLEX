//
//  EtalaseFilterViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 4/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Etalase.h"

@protocol EtalaseViewControllerDelegate <NSObject>
-(void)didSelectEtalase:(NSString*)etalaseId;
@end

@interface EtalaseViewController : UIViewController
@property (strong, nonatomic) NSString* shopId;
@property (strong, nonatomic) NSString* userId;

@property (nonatomic) BOOL showOtherEtalase;
@property (nonatomic) BOOL enableAddEtalase;
@property (nonatomic) BOOL showTotalProduct;
@property (nonatomic) BOOL showChevron;

@property (strong, nonatomic) IBOutlet UIView *tambahEtalaseView;
@property (strong, nonatomic) IBOutlet UITextField *tambahEtalaseTextField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
