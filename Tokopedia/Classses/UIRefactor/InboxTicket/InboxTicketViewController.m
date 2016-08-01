//
//  InboxTicketViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketViewController.h"
#import "InboxTicketCell.h"
#import "TokopediaNetworkManager.h"
#import "InboxTicket.h"
#import "InboxTicketList.h"
#import "InboxTicketPaging.h"
#import "InboxTicketUserInvolve.h"
#import "string_inbox_ticket.h"
#import "TKPDTabViewController.h"
#import "InboxTicketDetailViewController.h"
#import "NoResultReusableView.h"
#import "ContactUsWebViewController.h"

@interface InboxTicketViewController ()
<
    TokopediaNetworkManagerDelegate,
    TKPDTabViewDelegate,
    InboxTicketDetailDelegate,
NoResultDelegate
>
{
    TokopediaNetworkManager *_networkManager;
    NSMutableArray *_tickets;
    NSString *_uriNext;
    NSInteger _page;
    NSString *_filter;
    UIRefreshControl *_refreshControl;
    NSIndexPath *_selectedIndexPath;
    NSInteger _currentTabMenuIndex;
    NSInteger _currentTabSegmentIndex;
}
@property (strong, nonatomic) IBOutlet UIView *contentView;
@end

@implementation InboxTicketViewController{
    NoResultReusableView *_noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 12, 0);
    
    _tickets = [NSMutableArray new];
    _uriNext = @"";
    _page = 1;
    _currentTabMenuIndex = 0;
    _currentTabSegmentIndex = 0;
    _filter = @"all";

    [self requestInboxTicketList];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [_refreshControl beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataSource:)
                                                 name:TKPDTabNotification
                                               object:nil];
    self.contentView = self.view;
    [self initNoResultView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Anda tidak mempunyai tiket di Layanan Pengguna"
                                  desc:@""
                              btnTitle:@"Halaman Bantuan"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddTicket:) name:@"didAddTicket" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tickets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 124;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxTicketCell *cell = (InboxTicketCell *)[tableView dequeueReusableCellWithIdentifier:@"InboxCustomerServiceCell"];
    if (cell == nil) {
        cell = [InboxTicketCell initCell];
    }
    
    InboxTicketList *ticket = [_tickets objectAtIndex:indexPath.row];
    if ([ticket.ticket_status isEqualToString:@"2"]) {
        cell.statusLabel.text = @"   Ditutup   ";
        cell.statusLabel.textColor = [UIColor whiteColor];
        cell.statusLabel.backgroundColor = [UIColor colorWithRed:97.0/255.0
                                                           green:97.0/255.0
                                                            blue:97.0/255.0
                                                           alpha:1];
        cell.statusLabel.layer.cornerRadius = 2;
    } else {
        cell.statusLabel.text = @"   Dalam Proses   ";
        cell.statusLabel.textColor = [UIColor whiteColor];
        cell.statusLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
                                                           green:87.0/255.0
                                                            blue:34.0/255.0
                                                           alpha:1];
        cell.statusLabel.layer.cornerRadius = 2;
    }
    
    if (![ticket.ticket_update_time_fmt isEqualToString:@"0"]) {
        NSInteger index = ticket.ticket_update_time_fmt.length;
        cell.dateLabel.text = [ticket.ticket_update_time_fmt substringToIndex:index-7];
    } else if (![ticket.ticket_create_time_fmt isEqualToString:@"0"]) {
        NSInteger index = ticket.ticket_create_time_fmt.length;
        cell.dateLabel.text = [ticket.ticket_create_time_fmt substringToIndex:index-7];
    }
    
    cell.titleLabel.text = ticket.ticket_title;
    if ([ticket.ticket_read_status isEqualToString:@"1"]) {
        cell.titleLabel.font = [UIFont fontWithName:@"GothamMedium" size:14];
    }
    
    NSInteger totalMessages = [ticket.ticket_total_message integerValue];
    NSString *totalMessageString = [NSString stringWithFormat:@"%d", totalMessages];
    [cell.ticketTotalMessageButton setTitle:totalMessageString forState:UIControlStateNormal];
    
    NSMutableArray *users = [NSMutableArray arrayWithArray:@[ticket.ticket_first_message_name]];
    [users addObjectsFromArray:ticket.ticket_user_involve];
    cell.userInvolvedNameLabel.text = [[users valueForKey:@"description"] componentsJoinedByString:@", "];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self requestInboxTicketList];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxTicketList *ticket = [_tickets objectAtIndex:indexPath.row];
    
    InboxTicketDetailViewController *controller = self.detailViewController;
    if (self.detailViewController == nil) {
        controller = [InboxTicketDetailViewController new];
    }
    
    controller.inboxTicket = ticket;
    controller.delegate = self;
    
    _selectedIndexPath = indexPath;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.detailViewController updateTicket:ticket];
    } else if ([self.delegate respondsToSelector:@selector(pushViewController:)]) {
        [self.delegate pushViewController:controller];
    }
}

#pragma mark - Tokopedia network manager

- (void)requestInboxTicketList
{
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-ticket/get_inbox_ticket.pl"
                                method:RKRequestMethodGET
                             parameter:[self parameter]
                               mapping:[InboxTicket mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 [self actionAfterRequest:successResult withOperation:operation];
                             } onFailure:^(NSError *errorResult) {
                                 
                             }];
}

- (NSDictionary *)parameter
{
    NSString *status = @"";
    if (self.inboxCustomerServiceType == InboxCustomerServiceTypeInProcess) {
        status = @"1";
    } else if (self.inboxCustomerServiceType == InboxCustomerServiceTypeClosed) {
        status = @"2";
    }
    
    NSDictionary *dictionary = @{
                                 API_ACTION_KEY : API_GET_INBOX_TICKET,
                                 API_STATUS_KEY : status,
                                 API_FILTER_KEY : _filter,
                                 API_PAGE_KEY   : @(_page),
                                 };
    return dictionary;
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation{
    InboxTicket *inboxTicket = [mappingResult.dictionary objectForKey:@""];
    
    if (_page == 1) {
        [_tickets removeAllObjects];
    }
    
    [_tickets addObjectsFromArray: inboxTicket.result.list];
    
    if (_tickets.count > 0) {
        //self.view = _contentView;
        
        _uriNext =  inboxTicket.result.paging.uri_next;
        if (![_uriNext isEqualToString:@"0"]) {
            _page = [[_networkManager splitUriToPage:_uriNext] integerValue];
        }
        self.tableView.tableFooterView = nil;
    } else {
        
        if([_filter isEqualToString:@"unread"]){
            if(self.inboxCustomerServiceType == InboxCustomerServiceTypeClosed){
                [_noResultView setNoResultTitle:@"Anda sudah membaca semua tiket bantuan"];
                [_noResultView setNoResultDesc:@""];
                [_noResultView hideButton:YES];
            }else if(self.inboxCustomerServiceType == InboxCustomerServiceTypeInProcess){
                [_noResultView setNoResultTitle:@"Anda sudah membaca semua tiket bantuan"];
                [_noResultView setNoResultDesc:@""];
                [_noResultView hideButton:YES];
            }else{
                [_noResultView setNoResultTitle:@"Anda sudah membaca semua tiket bantuan"];
                [_noResultView setNoResultDesc:@""];
                [_noResultView hideButton:YES];
            }
        }else{
            if(self.inboxCustomerServiceType == InboxCustomerServiceTypeClosed){
                [_noResultView setNoResultTitle:@"Tidak ada tiket bantuan yang sudah ditutup"];
                [_noResultView setNoResultDesc:@""];
                [_noResultView hideButton:YES];
            }else if(self.inboxCustomerServiceType == InboxCustomerServiceTypeInProcess){
                [_noResultView setNoResultTitle:@"Tidak ada tiket bantuan dalam proses"];
                [_noResultView setNoResultDesc:@""];
                [_noResultView hideButton:YES];
            }else{
                [_noResultView setNoResultTitle:@"Tidak ada tiket bantuan"];
                [_noResultView setNoResultDesc:@"Butuh informasi dan bantuan yang lebih lengkap? Anda bisa cari di halaman bantuan kami"];
                [_noResultView hideButton:NO];
                [_noResultView setNoResultButtonTitle:@"Hubungi Kami"];
            }
        }
        [_noResultView removeFromSuperview];
        [_noResultView layoutIfNeeded];
        self.tableView.tableFooterView = _noResultView;
        //self.view = _noResultView;
    }
    
    [self.tableView reloadData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        InboxTicketList* ticket = _tickets.count? [_tickets objectAtIndex:0]: nil;
        if (_tickets.count) {
            if (!_selectedIndexPath) {
                _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }
            [self selectCurrentTableRow];
        }
        [self.detailViewController updateTicket:ticket];
    }
    
    [_refreshControl endRefreshing];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

#pragma mark - No Result Delegate

- (void)buttonDidTapped:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToContactUs" object:nil];
}

#pragma mark - Inbox detail delegate

- (void)updateInboxTicket:(InboxTicketList *)inboxTicket {
    if (_currentTabSegmentIndex == 1 && [inboxTicket.ticket_status isEqualToString:@"2"]) {
        [_tickets removeObjectAtIndex:_selectedIndexPath.row];
        [self.tableView reloadData];
    } else {
        if (_selectedIndexPath.row < _tickets.count) {
            [_tickets replaceObjectAtIndex:_selectedIndexPath.row withObject:inboxTicket];
            [self reloadTableWhileRetainingSelection];
        }
    }
}

- (void)reloadTableWhileRetainingSelection {
    [self.tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self selectCurrentTableRow];
}

- (void)selectCurrentTableRow {
    dispatch_async(dispatch_get_main_queue(), ^(void) { //select the row after table finished loading
        [self.tableView selectRowAtIndexPath:_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    });
}

#pragma mark - Methods

- (void)refreshView {
    _page = 1;
    //[_networkManager requestCancel];
    [self requestInboxTicketList];
}

- (void)reloadDataSource:(NSNotification *)notification {
    NSInteger currentSegmentedIndex = [[[notification object] objectForKey:TKPDTabViewSegmentedIndex] integerValue];
    _currentTabSegmentIndex = currentSegmentedIndex;

    NSInteger currentMenuIndex = [[[notification object] objectForKey:TKPDTabViewNavigationMenuIndex] integerValue];
    if (_currentTabMenuIndex != currentMenuIndex) {
        _currentTabMenuIndex = currentMenuIndex;
        if (_currentTabMenuIndex == 1) {
            _filter = @"unread";
        } else {
            _filter = @"all";
        }
        _page = 1;
        [_tickets removeAllObjects];
        [self.tableView reloadData];
        //[_networkManager requestCancel];
        [self requestInboxTicketList];
    }
}

- (void)didAddTicket:(NSNotification*)notification {
    self.view = _contentView;
}

@end
