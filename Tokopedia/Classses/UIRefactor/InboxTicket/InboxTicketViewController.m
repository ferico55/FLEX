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

@interface InboxTicketViewController ()
<
    TokopediaNetworkManagerDelegate,
    TKPDTabViewDelegate,
    InboxTicketDetailDelegate
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

@end

@implementation InboxTicketViewController

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

    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    [_networkManager doRequest];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataSource:)
                                                 name:TKPDTabNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    NSInteger index = ticket.ticket_update_time_fmt.length;
    if (![ticket.ticket_update_time_fmt isEqualToString:@"0"]) {
        cell.dateLabel.text = [ticket.ticket_update_time_fmt substringToIndex:index-7];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [_networkManager doRequest];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxTicketList *ticket = [_tickets objectAtIndex:indexPath.row];
    
    InboxTicketDetailViewController *controller = [InboxTicketDetailViewController new];
    controller.inboxTicket = ticket;
    controller.delegate = self;
    
    _selectedIndexPath = indexPath;
    
    if ([self.delegate respondsToSelector:@selector(pushViewController:)]) {
        [self.delegate pushViewController:controller];
    }
}

#pragma mark - Tokopedia network manager

- (NSDictionary *)getParameter:(int)tag
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

- (NSString *)getPath:(int)tag
{
    return API_PATH;
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxTicket class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxTicketResult class]];
    
    RKObjectMapping *inboxTicketMapping = [RKObjectMapping mappingForClass:[InboxTicketList class]];
    [inboxTicketMapping addAttributeMappingsFromArray:@[API_LIST_TICKET_CREATE_TIME_FMT2_KEY,
                                                        API_LIST_TICKET_FIRST_MESSAGE_NAME_KEY,
                                                        API_LIST_TICKET_UPDATE_TIME_FMT2_KEY,
                                                        API_LIST_TICKET_UPDATE_TIME_FMT_KEY,
                                                        API_LIST_TICKET_STATUS_KEY,
                                                        API_LIST_TICKET_READ_STATUS_KEY,
                                                        API_LIST_TICKET_UPDATE_IS_CS_KEY,
                                                        API_LIST_TICKET_INBOX_ID_KEY,
                                                        API_LIST_TICKET_UPDATE_BY_URL_KEY,
                                                        API_LIST_TICKET_CATEGORY_KEY,
                                                        API_LIST_TICKET_TITLE_KEY,
                                                        API_LIST_TICKET_TOTAL_MESSAGE_KEY,
                                                        API_LIST_TICKET_SHOW_MORE_KEY,
                                                        API_LIST_TICKET_RESPOND_STATUS_KEY,
                                                        API_LIST_TICKET_IS_REPLIED_KEY,
                                                        API_LIST_TICKET_URL_DETAIL_KEY,
                                                        API_LIST_TICKET_UPDATE_BY_ID_KEY,
                                                        API_LIST_TICKET_ID_KEY,
                                                        API_LIST_TICKET_UPDATE_BY_NAME_KEY,
                                                        API_LIST_TICKET_CATEGORY_ID_KEY
                                                        ]];
    
    RKObjectMapping *userInvolveMapping = [RKObjectMapping mappingForClass:[InboxTicketUserInvolve class]];
    [userInvolveMapping addAttributeMappingsFromArray:@[
                                                        API_LIST_TICKET_FULL_NAME_KEY,
                                                        ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[InboxTicketPaging class]];
    [pagingMapping addAttributeMappingsFromArray:@[API_PAGING_URI_NEXT_KEY,
                                                   API_PAGING_URI_PREV_KEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_KEY
                                                                                 toKeyPath:API_LIST_KEY
                                                                               withMapping:inboxTicketMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_PAGING_KEY
                                                                                 toKeyPath:API_PAGING_KEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *userInvolve = [RKRelationshipMapping relationshipMappingFromKeyPath:API_LIST_TICKET_USER_INVOLVE_KEY
                                                                                     toKeyPath:API_LIST_TICKET_USER_INVOLVE_KEY
                                                                                   withMapping:userInvolveMapping];
    [inboxTicketMapping addPropertyMapping:userInvolve];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    InboxTicket *inboxTicket = [mappingResult.dictionary objectForKey:@""];
    return inboxTicket.status;
}

- (void)actionBeforeRequest:(int)tag {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    UIView *loadingView = [[UIView alloc] initWithFrame:frame];
    [loadingView addSubview:indicator];
    
    indicator.center = loadingView.center;
    
    self.tableView.tableFooterView = loadingView;
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag{
    InboxTicket *inboxTicket = [mappingResult.dictionary objectForKey:@""];
    
    if (_page == 1) {
        [_tickets removeAllObjects];
    }
    
    [_tickets addObjectsFromArray: inboxTicket.result.list];
    
    if (_tickets.count > 0) {
        _uriNext =  inboxTicket.result.paging.uri_next;
        if (![_uriNext isEqualToString:@"0"]) {
            _page = [[_networkManager splitUriToPage:_uriNext] integerValue];
        }
        self.tableView.tableFooterView = nil;
    } else {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 156);
        NoResultView *noResultView = [[NoResultView alloc] initWithFrame:frame];
        self.tableView.tableFooterView = noResultView;
    }
    
    [self.tableView reloadData];
    
    [_refreshControl endRefreshing];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

#pragma mark - Inbox detail delegate

- (void)updateInboxTicket:(InboxTicketList *)inboxTicket {
    if (_currentTabSegmentIndex == 1 && [inboxTicket.ticket_status isEqualToString:@"2"]) {
        [_tickets removeObjectAtIndex:_selectedIndexPath.row];
    } else {
        if (_selectedIndexPath.row < _tickets.count) {
            [_tickets replaceObjectAtIndex:_selectedIndexPath.row withObject:inboxTicket];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Methods

- (void)refreshView {
    _page = 1;
    [_networkManager requestCancel];
    [_networkManager doRequest];
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
        [_networkManager requestCancel];
        [_networkManager doRequest];
    }
}

@end
