//
//  DepositListBankViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Bank Name View Delegate
@protocol DepositListBankViewControllerDelegate <NSObject>
@required
-(void)DepositListBankViewController:(UIViewController*)vc withData:(NSDictionary*)data;

@end

@interface DepositListBankViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<DepositListBankViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSArray *listBankAccount;




@end
