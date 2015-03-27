//
//  NotificationViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationViewController.h"
#import "InboxMessageViewController.h"
#import "InboxTalkViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxResolutionCenterTabViewController.h"

@interface NotificationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *discussionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceNotificationCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerCareCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionCenterCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *salesOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingConfirmationCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *shippingStatusCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *salesListCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderCancelledLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentConfirmationLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiveConfirmationCountLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *salesNewOrder;
@property (weak, nonatomic) IBOutlet UITableViewCell *shippingConfirmation;
@property (weak, nonatomic) IBOutlet UITableViewCell *shippingStatus;

@property (weak, nonatomic) IBOutlet UITableViewCell *orderCancelled;
@property (weak, nonatomic) IBOutlet UITableViewCell *paymentConfirmation;
@property (weak, nonatomic) IBOutlet UITableViewCell *orderStatus;
@property (weak, nonatomic) IBOutlet UITableViewCell *receiveConfirmation;


@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Inbox section
    
    if ([_notification.result.inbox.inbox_message integerValue] > 0) {
        _messageCountLabel.text = _notification.result.inbox.inbox_message;
        [self updateLabelAppearance:_messageCountLabel];
    }
    
    if ([_notification.result.inbox.inbox_talk integerValue] > 0) {
        _discussionCountLabel.text = _notification.result.inbox.inbox_talk;
        [self updateLabelAppearance:_discussionCountLabel];
    }
    
    if ([_notification.result.inbox.inbox_review integerValue] > 0) {
        _reviewCountLabel.text = _notification.result.inbox.inbox_review;
        [self updateLabelAppearance:_reviewCountLabel];
    }

    if ([_notification.result.resolution integerValue] > 0) {
        _resolutionCenterCountLabel.text = [_notification.result.resolution stringValue];
        [self updateLabelAppearance:_resolutionCenterCountLabel];
    }
    

    
    // Payment section
    if([_notification.result.sales.sales_new_order integerValue] > 0) {
        _salesNewOrder.hidden = NO;
        _salesOrderLabel.text = _notification.result.sales.sales_new_order;
    } else {
        _salesNewOrder.hidden = YES;
    }
    
    if([_notification.result.sales.sales_shipping_confirm integerValue] > 0) {
        _shippingConfirmationCountLabel.text = _notification.result.sales.sales_shipping_confirm;\
        _shippingConfirmation.hidden = NO;
    } else {
        _shippingConfirmation.hidden = YES;
    }
    
    if([_notification.result.sales.sales_shipping_status integerValue] > 0) {
        _shippingStatusCountLabel.text = _notification.result.sales.sales_shipping_status;
        _shippingStatus.hidden = NO;
    } else {
        _shippingStatus.hidden = YES;
    }

    // Purchase section
    if([_notification.result.purchase.purchase_reorder integerValue] > 0) {
        _orderCancelledLabel.text = _notification.result.purchase.purchase_reorder;
        _orderCancelled.hidden = NO;
    } else {
        _orderCancelled.hidden = YES;
    }
    
    if([_notification.result.purchase.purchase_payment_conf integerValue] > 0) {
        _paymentConfirmationLabel.text = _notification.result.purchase.purchase_payment_conf;
        _paymentConfirmation.hidden = NO;
    } else {
        _paymentConfirmation.hidden = YES;
    }
    
    if([_notification.result.purchase.purchase_order_status integerValue] > 0) {
        _orderStatusCountLabel.text = _notification.result.purchase.purchase_order_status;
        _orderStatus.hidden = NO;
    } else {
        _orderStatus.hidden = YES;
    }
    
    if([_notification.result.purchase.purchase_delivery_confirm integerValue] > 0) {
        _receiveConfirmationCountLabel.text = _notification.result.purchase.purchase_delivery_confirm;
        _receiveConfirmation.hidden = NO;
    } else {
        _receiveConfirmation.hidden = YES;
    }

 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 6;
            break;
            
        case 1:
            numberOfRows = 3;
            break;
            
        case 2:
            numberOfRows = 4;
            break;
            
        default:
            break;
    }
    return numberOfRows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if(section == 1) {
        NSInteger row = indexPath.row;
        if(row == 0 && [_notification.result.sales.sales_new_order integerValue] == 0) {
            return 0;
        } else if(row == 1 && [_notification.result.sales.sales_shipping_confirm integerValue] == 0) {
            return 0;
        } else if(row == 2 && [_notification.result.sales.sales_shipping_status integerValue] == 0) {
            return 0;
        }
    } else if(section == 2) {
        NSInteger row = indexPath.row;
        if(row == 0 && [_notification.result.purchase.purchase_reorder integerValue] == 0) {
            return 0;
        } else if(row == 1 && [_notification.result.purchase.purchase_payment_conf integerValue] == 0) {
            return 0;
        } else if(row == 2 && [_notification.result.purchase.purchase_order_status integerValue] == 0) {
            return 0;
        } else if(row == 3 && [_notification.result.purchase.purchase_delivery_confirm integerValue] == 0) {
            return 0;
        }
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1) {
        if([_notification.result.sales.sales_new_order integerValue] == 0 &&
           [_notification.result.sales.sales_shipping_confirm integerValue] == 0 &&
           [_notification.result.sales.sales_shipping_status integerValue] == 0
           ) {
            return  0;
        }
    } else if(section == 2) {
        if([_notification.result.purchase.purchase_reorder integerValue] == 0 &&
           [_notification.result.purchase.purchase_payment_conf integerValue] == 0 &&
           [_notification.result.purchase.purchase_order_status integerValue] == 0 &&
           [_notification.result.purchase.purchase_delivery_confirm integerValue] == 0
           ) {
            return 0;
        }
    }
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 4, self.view.frame.size.width, 30)];
    titleLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1];
    if (section == 0) titleLabel.text = @"Kotak Masuk";
    else if (section == 1) titleLabel.text = @"Penjualan";
    else if (section == 2) titleLabel.text = @"Pembelian";

    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 33, self.view.frame.size.width, 1)];
    borderView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:0.5f];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
    headerView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    [headerView addSubview:titleLabel];
    [headerView addSubview:borderView];
    
    return headerView;
}

#pragma mark - Methods

- (void)updateLabelAppearance:(UILabel *)label {
    
    CGRect messageFrame = label.frame;
    messageFrame.origin.x -= 18;
    label.frame = messageFrame;

    UIView *redCircle = [[UIView alloc] initWithFrame:CGRectMake(40, 17, 8, 8)];
    redCircle.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:28.0/255.0 blue:35.0/255.0 alpha:1];
    redCircle.layer.cornerRadius = 4;
    redCircle.clipsToBounds = YES;
    [label addSubview:redCircle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:{
                InboxMessageViewController *vc = [InboxMessageViewController new];
                vc.data=@{@"nav":@"inbox-message"};
                
                InboxMessageViewController *vc1 = [InboxMessageViewController new];
                vc1.data=@{@"nav":@"inbox-message-sent"};
                
                InboxMessageViewController *vc2 = [InboxMessageViewController new];
                vc2.data=@{@"nav":@"inbox-message-archive"};
                
                InboxMessageViewController *vc3 = [InboxMessageViewController new];
                vc3.data=@{@"nav":@"inbox-message-trash"};
                NSArray *vcs = @[vc,vc1, vc2, vc3];
                
                TKPDTabInboxMessageNavigationController *controller = [TKPDTabInboxMessageNavigationController new];
                [controller setSelectedIndex:2];
                [controller setViewControllers:vcs];
                
                [self.delegate pushViewController:controller];

                break;
            }
            case 1 : {
                InboxTalkViewController *vc = [InboxTalkViewController new];
                vc.data=@{@"nav":@"inbox-talk"};
                
                InboxTalkViewController *vc1 = [InboxTalkViewController new];
                vc1.data=@{@"nav":@"inbox-talk-my-product"};
                
                InboxTalkViewController *vc2 = [InboxTalkViewController new];
                vc2.data=@{@"nav":@"inbox-talk-following"};
                
                NSArray *vcs = @[vc,vc1, vc2];
                
                TKPDTabInboxTalkNavigationController *controller = [TKPDTabInboxTalkNavigationController new];
                [controller setSelectedIndex:2];
                [controller setViewControllers:vcs];

                [self.delegate pushViewController:controller];

                break;
            }
            case 5:
            {
                InboxResolutionCenterTabViewController *vc = [InboxResolutionCenterTabViewController new];
                [self.delegate pushViewController:vc];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
