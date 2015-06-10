//
//  InboxTicketDetailViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketDetailViewController.h"
#import "InboxTicket.h"
#import "ResolutionCenterDetailCell.h"

NSString *const cellIdentifier = @"ResolutionCenterDetailCellIdentifier";

@interface InboxTicketDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>
{
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    NoResultView *_noResult;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *messages;

@end

@implementation InboxTicketDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResolutionCenterDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    InboxTicket *product = self.messages[indexPath.row];
//    [cell setViewModel:product.viewModel];
//    
//    //next page if already last cell
//    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
//    if (row == indexPath.row) {
//        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
//            _isFailRequest = NO;
//            [_networkManager doRequest];
//        }
//    }
    
    return cell;
}

@end
