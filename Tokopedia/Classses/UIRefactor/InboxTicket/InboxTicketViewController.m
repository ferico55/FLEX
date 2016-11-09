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
#import "Tokopedia-Swift.h"

@interface InboxTicketViewController ()
<
    TKPDTabViewDelegate,
    InboxTicketDetailDelegate,
    NoResultDelegate
>
{
    NSMutableArray *_tickets;
    NSString *_uriNext;
    InboxTicketFilterType _filter;
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
    _currentTabMenuIndex = 0;
    _currentTabSegmentIndex = 0;
    _filter = InboxTicketFilterTypeAll;

    [self requestListTicketPage:1];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Inbox Ticket Page"];
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
    return 80;
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
        cell.titleLabel.font = [UIFont largeThemeMedium];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            [self requestListTicketPage:[self page]];
        }
    }
}

-(NSInteger)page{
    return [[TokopediaNetworkManager getPageFromUri:_uriNext] integerValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxTicketList *ticket = [_tickets objectAtIndex:indexPath.row];
    [AnalyticsManager trackInboxTicketClickWithType:_inboxCustomerServiceType];
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
-(TicketListRequestObject *)requestObjectListTicket{
    TicketListRequestObject *object = [TicketListRequestObject new];
    object.filter = _filter;
    object.keyword = @"";
    object.status = _inboxCustomerServiceType;
    
    return object;
}

-(void)setLoadingView{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    UIView *loadingView = [[UIView alloc] initWithFrame:frame];
    [loadingView addSubview:indicator];
    
    indicator.center = loadingView.center;
    
    self.tableView.tableFooterView = loadingView;
}

-(NSString *)noResultViewTitle{
    NSDictionary *readNoResultViewTitle = @{
         @(InboxCustomerServiceTypeClosed) : @"Tidak ada tiket bantuan yang sudah ditutup",
         @(InboxCustomerServiceTypeInProcess) : @"Tidak ada tiket bantuan dalam proses",
         @(InboxCustomerServiceTypeAll) : @"Tidak ada tiket bantuan"
    };
    
    if (_filter == InboxTicketFilterTypeUnread){
        return @"Anda sudah membaca semua tiket bantuan";
    } else {
        return readNoResultViewTitle[@(_inboxCustomerServiceType)];
    }
}

-(NSString*)noResultViewDescription{
    if (_filter == InboxTicketFilterTypeAll &&
        _inboxCustomerServiceType == InboxCustomerServiceTypeAll){
        return @"Butuh informasi dan bantuan yang lebih lengkap? Anda bisa cari di halaman bantuan kami";
    }
    return @"";
}

-(void)setNoResultViewAppearance{
    [_noResultView setNoResultTitle:[self noResultViewTitle]];
    [_noResultView setNoResultDesc:[self noResultViewDescription]];
    
    if (_filter == InboxTicketFilterTypeAll &&
        _inboxCustomerServiceType == InboxCustomerServiceTypeAll){
        [_noResultView hideButton:NO];
        [_noResultView setNoResultButtonTitle:@"Hubungi Kami"];
    } else {
        [_noResultView hideButton:YES];
    }
    [_noResultView layoutIfNeeded];
    self.tableView.tableFooterView = _noResultView;
}

-(void)requestListTicketPage:(NSInteger)page{
    
    [self setLoadingView];
    
    [InboxTicketRequest fetchListTicket:[self requestObjectListTicket] page:page onSuccess:^(InboxTicketResult * data) {
        
        if (page == 1) {
            [_tickets removeAllObjects];
        }
        
        [_tickets addObjectsFromArray: data.list];
        
        if (_tickets.count > 0) {
            _uriNext =  data.paging.uri_next;
            self.tableView.tableFooterView = nil;
            
        } else {
            [self setNoResultViewAppearance];
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
        
    } onFailure:^{
        [_refreshControl endRefreshing];
    }];
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
    [self requestListTicketPage:1];
}

- (void)reloadDataSource:(NSNotification *)notification {
    NSInteger currentSegmentedIndex = [[[notification object] objectForKey:TKPDTabViewSegmentedIndex] integerValue];
    _currentTabSegmentIndex = currentSegmentedIndex;

    NSInteger currentMenuIndex = [[[notification object] objectForKey:TKPDTabViewNavigationMenuIndex] integerValue];
    if (_currentTabMenuIndex != currentMenuIndex) {
        _currentTabMenuIndex = currentMenuIndex;
        _filter = _currentTabMenuIndex;
        [_tickets removeAllObjects];
        [self.tableView reloadData];
        [self requestListTicketPage:1];
    }
}

- (void)didAddTicket:(NSNotification*)notification {
    self.view = _contentView;
}

@end
