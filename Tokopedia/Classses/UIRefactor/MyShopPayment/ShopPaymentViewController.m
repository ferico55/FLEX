//
//  ShopPaymentViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopPaymentViewController.h"
#import "SettingPayment.h"
#import "MyShopPaymentCell.h"
#import "LoadingView.h"
#import "UITableView+LoadingView.h"

@interface ShopPaymentViewController () <LoadingViewDelegate>

@property (strong, nonatomic) NSArray *paymentOptions;
@property (strong, nonnull) NSString *titleForFooter;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@property (strong, nonatomic) LoadingView *loadingView;

@end

@implementation ShopPaymentViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tableView.allowsSelection = NO;
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Pembayaran";
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
    [self fetchPaymentData];
    
    UINib *nib = [UINib nibWithNibName:@"MyShopPaymentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MyShopPaymentCellIdentifier"];
    
    self.loadingView = [LoadingView new];
    self.loadingView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.paymentOptions.count;
}

- (MyShopPaymentCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyShopPaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyShopPaymentCellIdentifier" forIndexPath:indexPath];

    Payment *payment = self.paymentOptions[indexPath.row];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineSpacing = 6.0;
    
    NSDictionary *titleAttributes = @{
        NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:14],
        NSParagraphStyleAttributeName  : style,
    };
    
    NSDictionary *textAttributes = @{
        NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
        NSParagraphStyleAttributeName  : style,
    };
    
    cell.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:payment.payment_name attributes:titleAttributes];
    
    NSString *description = [NSString convertHTML:payment.payment_info];
    cell.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:description attributes:textAttributes];
    [cell.descriptionLabel sizeToFit];
    
    cell.indexPath = indexPath;
    
    NSURL *url = [NSURL URLWithString:payment.payment_image];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    cell.thumbnailImageView.image = nil;
    [cell.thumbnailImageView setImageWithURLRequest:request
                                   placeholderImage:nil
                                            success:^(NSURLRequest *request,
                                                      NSHTTPURLResponse *response,
                                                      UIImage *image) {
                              [cell.thumbnailImageView setImage:image];
                          } failure:nil];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.titleForFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        return UITableViewAutomaticDimension;
    } else {
        return 220;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        return UITableViewAutomaticDimension;
    } else {
        return 220;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Restkit 

- (void)fetchPaymentData {
    [self.tableView startIndicatorView];
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-payment/get_payment_info.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{}
                                    mapping:[SettingPayment mapping]
                                  onSuccess:^(RKMappingResult *successResult,
                                              RKObjectRequestOperation *operation) {
                                      [self didReceivePaymentData:[successResult.dictionary objectForKey:@""]];
                                  } onFailure:^(NSError *errorResult) {
                                      self.tableView.tableFooterView = _loadingView;
                                      [self.tableView startIndicatorView];
                                      [self.refreshControl endRefreshing];
                                  }];
}

- (void)didReceivePaymentData:(SettingPayment *)data {
    if (data.message_error.count > 0) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:data.message_error delegate:self];
        [alert show];
    } else if ([data.status isEqualToString:@"OK"]) {
        for (Payment *payment in data.result.payment_options) {
            if ([data.result.loc objectForKey:payment.payment_id]) {
                payment.payment_info = [data.result.loc objectForKey:payment.payment_id];
            }
        }

        self.paymentOptions = data.result.payment_options;

        self.titleForFooter = [NSString stringWithFormat:@"Pilihan Pembayaran yang ingin Anda berikan kepada pengunjung Toko Online Anda.\n\n%@\n\n", [data.result.note componentsJoinedByString:@"\n\n"]];
        
        [self.tableView reloadData];
        [self.tableView stopIndicatorView];
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Loading view delegate

- (void)pressRetryButton {
    [self fetchPaymentData];
}

#pragma mark - Refresh control

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self fetchPaymentData];
}

@end
