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
#import "ShipmentConfirmationViewController.h"
#import "SegmentedReviewReputationViewController.h"
#import "SplitReputationViewController.h"
#import "SalesNewOrderViewController.h"
#import "ShipmentStatusViewController.h"

#import "TxOrderConfirmedViewController.h"
#import "TxOrderStatusViewController.h"
#import "TxOrderStatusViewController.h"

#import "TKPDTabViewController.h"
#import "InboxTicketViewController.h"
#import "InboxRootViewController.h"
#import "InboxTalkSplitViewController.h"
#import "InboxResolSplitViewController.h"
#import "InboxTicketSplitViewController.h"
#import "NavigateViewController.h"
#import "ContactUsWebViewController.h"
#import "Tokopedia-Swift.h"

@interface NotificationViewController () <NewOrderDelegate, ShipmentConfirmationDelegate, SplitReputationVcProtocol> {
    NSDictionary *_auth;
}

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
{
    UISplitViewController *splitViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
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
    
    if([_notification.result.inbox.inbox_wishlist integerValue] > 0) {
        _priceNotificationCountLabel.text = _notification.result.inbox.inbox_wishlist;
        [self updateLabelAppearance:_priceNotificationCountLabel];
    }
    
    if([_notification.result.inbox.inbox_wishlist integerValue] > 0) {
        _priceNotificationCountLabel.text = _notification.result.inbox.inbox_wishlist;
        [self updateLabelAppearance:_priceNotificationCountLabel];
    }
    
    if([_notification.result.inbox.inbox_ticket integerValue] > 0) {
        _customerCareCountLabel.text = _notification.result.inbox.inbox_ticket;
        [self updateLabelAppearance:_customerCareCountLabel];
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
    
    NSInteger totalPaymentConfirmation = [_notification.result.purchase.purchase_payment_conf integerValue] +        [_notification.result.purchase.purchase_payment_confirm integerValue];
    
    if(totalPaymentConfirmation > 0) {
        _paymentConfirmationLabel.text = [NSString stringWithFormat:@"%zd",totalPaymentConfirmation];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // UA
    [AnalyticsManager trackScreenName:@"Top Notification Center"];
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
            numberOfRows = 5;
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor clearColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
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
        NSInteger totalPaymentConfirmation = [_notification.result.purchase.purchase_payment_conf integerValue] +        [_notification.result.purchase.purchase_payment_confirm integerValue];
        if(row == 0 && [_notification.result.purchase.purchase_reorder integerValue] == 0) {
            return 0;
        } else if(row == 1 && totalPaymentConfirmation == 0) {
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
           [_notification.result.purchase.purchase_payment_confirm integerValue] == 0 &&
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
    titleLabel.font = [UIFont title2ThemeMedium];
    titleLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1];
    if (section == 0) titleLabel.text = @"Kotak Masuk";
    else if (section == 1) titleLabel.text = @"Penjualan";
    else if (section == 2) titleLabel.text = @"Pembelian";
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 33, self.view.frame.size.width, 1)];
    borderView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:0.5f];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
    headerView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:0.7];
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
                [AnalyticsManager trackEventName:@"clickTopedIcon"
                                        category:GA_EVENT_CATEGORY_NOTIFICATION
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Message"];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    InboxRootViewController *controller = [InboxRootViewController new];
                    [self.delegate pushViewController:controller];
                    
                } else {
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
                    controller.hidesBottomBarWhenPushed = YES;
                    [self.delegate pushViewController:controller];
                }

                break;
            }
            case 1 : {
                [AnalyticsManager trackEventName:@"clickTopedIcon"
                                        category:GA_EVENT_CATEGORY_NOTIFICATION
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Product Discussion"];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    InboxTalkSplitViewController *controller = [InboxTalkSplitViewController new];
                    [self.delegate pushViewController:controller];
                    
                } else {
                    //        InboxTalkViewController *vc = [InboxTalkViewController new];
                    //        vc.data=@{@"nav":@"inbox-talk"};
                    //
                    //        InboxTalkViewController *vc1 = [InboxTalkViewController new];
                    //        vc1.data=@{@"nav":@"inbox-talk-my-product"};
                    //
                    //        InboxTalkViewController *vc2 = [InboxTalkViewController new];
                    //        vc2.data=@{@"nav":@"inbox-talk-following"};
                    //
                    //        NSArray *vcs = @[vc,vc1, vc2];
                    //
                    //        TKPDTabInboxTalkNavigationController *controller = [TKPDTabInboxTalkNavigationController new];
                    //        [controller setSelectedIndex:2];
                    //        [controller setViewControllers:vcs];
                    //        controller.hidesBottomBarWhenPushed = YES;
                    //
                    //        [viewController.navigationController pushViewController:controller animated:YES];
                    TKPDTabViewController *controller = [TKPDTabViewController new];
                    controller.hidesBottomBarWhenPushed = YES;
                    controller.inboxType = InboxTypeTalk;
                    
                    InboxTalkViewController *allTalk = [InboxTalkViewController new];
                    allTalk.inboxTalkType = InboxTalkTypeAll;
                    allTalk.delegate = controller;
                    
                    InboxTalkViewController *myProductTalk = [InboxTalkViewController new];
                    myProductTalk.inboxTalkType = InboxTalkTypeMyProduct;
                    myProductTalk.delegate = controller;
                    
                    InboxTalkViewController *followingTalk = [InboxTalkViewController new];
                    followingTalk.inboxTalkType = InboxTalkTypeFollowing;
                    followingTalk.delegate = controller;
                    
                    controller.viewControllers = @[allTalk, myProductTalk, followingTalk];
                    controller.tabTitles = @[@"Semua", @"Produk Saya", @"Ikuti"];
                    controller.menuTitles = @[@"Semua Diskusi", @"Belum Dibaca"];
                    
                    [self.delegate pushViewController:controller];
                }

                break;
            }
                
            case 2 : {
                [AnalyticsManager trackEventName:@"clickTopedIcon"
                                        category:GA_EVENT_CATEGORY_NOTIFICATION
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Review"];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    splitViewController = [UISplitViewController new];
                    
                    SplitReputationViewController *splitReputationViewController = [SplitReputationViewController new];
                    splitReputationViewController.splitViewController = splitViewController;
                    splitReputationViewController.isFromNotificationView = YES;
                    splitReputationViewController.del = self;
                    [self.delegate pushViewController:splitReputationViewController];
                } else {
                    SegmentedReviewReputationViewController *segmentedReputationViewController = [SegmentedReviewReputationViewController new];
	                segmentedReputationViewController.hidesBottomBarWhenPushed = YES;
                    segmentedReputationViewController.userHasShop = ([_auth objectForKey:@"shop_id"] && [[_auth objectForKey:@"shop_id"] integerValue] > 0);
    	            [self.delegate pushViewController:segmentedReputationViewController];
                }
                break;
            }
            case 3:
            {
                [AnalyticsManager trackEventName:@"clickTopedIcon"
                                        category:GA_EVENT_CATEGORY_NOTIFICATION
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Help"];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    InboxTicketSplitViewController *controller = [InboxTicketSplitViewController new];
                    
                    [self.delegate pushViewController:controller]; 
                } else {
                    TKPDTabViewController *controller = [TKPDTabViewController new];
                    controller.hidesBottomBarWhenPushed = YES;
                    controller.inboxType = InboxTypeTicket;
                    __weak typeof(self) weakSelf = self;
                    
                    InboxTicketViewController *allInbox = [InboxTicketViewController new];
                    allInbox.inboxCustomerServiceType = InboxCustomerServiceTypeAll;
                    allInbox.delegate = controller;
                    allInbox.onTapContactUsButton = ^{
                        [weakSelf navigateToContactUs];
                    };
                    
                    InboxTicketViewController *unreadInbox = [InboxTicketViewController new];
                    unreadInbox.inboxCustomerServiceType = InboxCustomerServiceTypeInProcess;
                    unreadInbox.delegate = controller;
                    unreadInbox.onTapContactUsButton = ^{
                        [weakSelf navigateToContactUs];
                    };
                    
                    InboxTicketViewController *closedInbox = [InboxTicketViewController new];
                    closedInbox.inboxCustomerServiceType = InboxCustomerServiceTypeClosed;
                    closedInbox.delegate = controller;
                    closedInbox.onTapContactUsButton = ^{
                        [weakSelf navigateToContactUs];
                    };
                    
                    controller.viewControllers = @[allInbox, unreadInbox, closedInbox];
                    controller.tabTitles = @[@"Semua", @"Dalam Proses", @"Ditutup"];
                    controller.menuTitles = @[@"Semua Layanan Pengguna", @"Belum Dibaca"];
                    
                    [self.delegate pushViewController:controller];
                }
                break;
            }
                
            case 4 : {
                [AnalyticsManager trackEventName:@"clickTopedIcon"
                                        category:GA_EVENT_CATEGORY_NOTIFICATION
                                          action:GA_EVENT_ACTION_CLICK
                                           label:@"Resolution Center"];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    InboxResolSplitViewController *controller = [InboxResolSplitViewController new];
                    controller.hidesBottomBarWhenPushed = YES;
                    [self.delegate pushViewController:controller];
                    
                } else {
                    InboxResolutionCenterTabViewController *controller = [InboxResolutionCenterTabViewController new];
                    controller.hidesBottomBarWhenPushed = YES;
                    [self.delegate pushViewController:controller];
                }
                break;
            }

            default:
                break;
        }
    }
    
    if([indexPath section] == 1) {
        if([indexPath row] == 0) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"New Order"];
            SalesNewOrderViewController *controller = [[SalesNewOrderViewController alloc] init];
            controller.delegate = self;
            controller.hidesBottomBarWhenPushed = YES;
            [self.delegate pushViewController:controller];
        } else if ([indexPath row] == 1) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Delivery Confirmation"];
            ShipmentConfirmationViewController *controller = [[ShipmentConfirmationViewController alloc] init];
            controller.delegate = self;
            controller.hidesBottomBarWhenPushed = YES;
            [self.delegate pushViewController:controller];
        } else if ([indexPath row] == 2) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Delivery Status"];
            ShipmentStatusViewController *controller = [[ShipmentStatusViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.delegate pushViewController:controller];
        }
    }
    
    if([indexPath section] == 2) {
        if([indexPath row] == 0) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Canceled Order"];
            TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
            vc.action = @"get_tx_order_list";
            vc.isCanceledPayment = YES;
            vc.viewControllerTitle = @"Pesanan Dibatalkan";
            vc.hidesBottomBarWhenPushed = YES;
            [self.delegate pushViewController:vc];
        } else if ([indexPath row] == 1) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Order Status"];
            TxOrderConfirmedViewController *vc = [TxOrderConfirmedViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            [self.delegate pushViewController:vc];
        } else if ([indexPath row] == 2) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Order Status"];
            TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            vc.action = @"get_tx_order_status";
            vc.viewControllerTitle = @"Status Pemesanan";
            [self.delegate pushViewController:vc];
        } else if ([indexPath row] == 3) {
            [AnalyticsManager trackEventName:@"clickTopedIcon"
                                    category:GA_EVENT_CATEGORY_NOTIFICATION
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Receive Confirmation"];
            TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
            vc.hidesBottomBarWhenPushed = YES;
            vc.action = @"get_tx_order_deliver";
            vc.viewControllerTitle = @"Konfirmasi Penerimaan";
            [self.delegate pushViewController:vc];
        }
    }
}

- (void)navigateToContactUs {
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSString *contactUsURL = @"https://www.tokopedia.com/contact-us?flag_app=1&utm_source=ios";
    WKWebViewController *controller = [[WKWebViewController alloc] initWithUrlString:[auth webViewUrlFromUrl:contactUsURL] shouldAuthorizeRequest:YES];
    controller.title = @"Tokopedia Contact";
    [self.delegate pushViewController:controller];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewController:(UIViewController *)viewController numberOfProcessedOrder:(NSInteger)totalOrder {
    
}

#pragma mark - SplitVC Delegate
- (void)deallocVC {
    splitViewController = nil;
}

@end
