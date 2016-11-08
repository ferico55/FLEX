//
//  InboxTicketDetailViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketDetailViewController.h"
#import "DetailInboxTicket.h"
#import "InboxTicketDetail.h"
#import "InboxTicketResultDetail.h"
#import "InboxTicketReply.h"
#import "InboxTicketTicket.h"
#import "ResolutionCenterDetailCell.h"
#import "string_inbox_ticket.h"
#import "InboxTicketReplyViewController.h"
#import "InboxTicketDetailAttachment.h"
#import "GalleryViewController.h"
#import "UserContainerViewController.h"
#import "Tokopedia-Swift.h"

NSString *const cellIdentifier = @"ResolutionCenterDetailCellIdentifier";

@interface InboxTicketDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    ResolutionCenterDetailCellDelegate,
    GalleryViewControllerDelegate
>
{
    NSString *_nextPageUri;
    UIRefreshControl *_refreshControl;
    NoResultView *_noResult;
    
    NSMutableArray<NSMutableArray *> *_messages;
    NSInteger _page;
    InboxTicketTicket *_ticketInformation;
    InboxTicketDetail *_ticketDetail;

    BOOL _canLoadMore;
    
    NSIndexPath *_selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;

@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (strong, nonatomic) IBOutlet UIView *loadMoreView;

@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (weak, nonatomic) IBOutlet UIView *ticketClosedView;

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoiceNumberLabel;

@end

@implementation InboxTicketDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.inboxTicket) {
        [self setTitleView];
    }
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:emptyView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    [self configureRefreshControl];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
    
    _messages = [NSMutableArray new];
    _page = 0;
    
    if (self.inboxTicket || self.inboxTicketId) {
        [self requestDetailTicket];
    }
    
    self.replyButton.layer.cornerRadius = 2;
    self.loadMoreButton.layer.cornerRadius = 2;
    
    _canLoadMore = NO;
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appendTicketFromNotification:)
                                                 name:TKPDInboxAddNewTicket
                                               object:nil];
    
    _tableView.estimatedRowHeight = 100.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)requestDetailTicket{
    
    if (_messages.count == 0) {
        self.tableView.tableFooterView = _tableFooterView;
        [_indicatorView startAnimating];
    }
    
    [InboxTicketRequest fetchDetailTicket:[self inboxTicketId] isLoadMore:_canLoadMore page:_page onSuccess:^(InboxTicketResultDetail * data) {
        
        [self loadTicketsData:data];
        [self setTitleView];
        [self setCategoryView];
        self.tableView.hidden = NO;
        
    } onFailure:^{
        [self requestFailed];
    }];
}

-(void)requestFailed{
    if (_page > 0) {
        _page = _page - 1;
    }
    
    [_loadMoreButton setTitle:@"Lihat Sebelumnya" forState:UIControlStateNormal];
}

- (void)showRefreshControl {
    [_refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
}

- (void)updateTicket:(InboxTicketList *)inboxTicket {
    self.inboxTicket = inboxTicket;
    
    if (inboxTicket) {
        _ticketDetail = nil;
        _ticketInformation = nil;
        _canLoadMore = NO;
        _page = 0;
        
        self.view.hidden = NO;
        
        [_loadMoreButton setTitle:@"Lihat Sebelumnya" forState:UIControlStateNormal];
        
        [self setTitleView];
        
        [self showRefreshControl];
        
        [self requestDetailTicket];
    }
    else {
        self.navigationItem.titleView = nil;
        self.view.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Inbox Ticket Detail Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTitleView {
    NSString *ticketID = [NSString stringWithFormat:@"No Tiket : %@", _ticketInformation.ticket_id?:self.inboxTicket.ticket_id];
    NSString *status;
    if ([_ticketInformation.ticket_status?:self.inboxTicket.ticket_status isEqualToString:@"1"]) {
        status = @"Dalam Proses";
    } else {
        status = @"Ditutup";
    }

    NSString *title = [NSString stringWithFormat:@"%@\nStatus : %@", ticketID?:@"", status?:@""];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont title1ThemeMedium]
                           range:NSMakeRange(0, ticketID.length)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    label.numberOfLines = 2;
    label.font = [UIFont microTheme];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.attributedText = attributedText;
    
    self.navigationItem.titleView = label;
}

- (void)setCategoryView {
    NSString *category = _ticketInformation.ticket_category?:self.inboxTicket.ticket_category;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont smallTheme],
                                 NSParagraphStyleAttributeName  : style,
                                 };
    
    NSMutableAttributedString *categoryAttributedString = [[NSMutableAttributedString alloc] initWithString:category?:@""];
    [categoryAttributedString addAttributes:attributes range:NSMakeRange(0, category.length)];
    
    self.categoryLabel.attributedText = categoryAttributedString;
    [self.categoryLabel sizeToFit];
    
    CGSize maximumLabelSize = CGSizeMake(320, CGFLOAT_MAX);
    
    CGFloat width = self.view.frame.size.width - 30;
    CGRect categoryLabelSize = [categoryAttributedString boundingRectWithSize:CGSizeMake(width, 10000)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      context:nil];
    
    NSString *invoice = _ticketInformation.ticket_invoice_ref_num;
    if (![invoice isEqualToString:@"0"] ) {
        self.invoiceTitleLabel.hidden = NO;
        
        self.invoiceNumberLabel.text = invoice;
        self.invoiceNumberLabel.hidden = NO;
        [self.invoiceNumberLabel sizeToFit];
        
        CGSize invoiceLabelSize = [invoice sizeWithFont:[UIFont largeTheme]
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect frame = self.tableHeaderView.frame;
        // 20 magin top and bottom
        frame.size.height = categoryLabelSize.size.height + invoiceLabelSize.height + 83;
        self.tableHeaderView.frame = frame;
    } else {
        CGRect frame = self.tableHeaderView.frame;
        // 20 magin top and bottom
        frame.size.height = categoryLabelSize.size.height + 48;
        self.tableHeaderView.frame = frame;
        
        self.invoiceTitleLabel.hidden = YES;
        self.invoiceNumberLabel.hidden = YES;
    }
    self.tableView.tableHeaderView = _tableHeaderView;
    self.tableView.contentInset = UIEdgeInsetsZero;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.inboxTicket.ticket_show_more_messages) {
        return [_messages count];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.inboxTicket.ticket_show_more_messages) {
        if (section == 0) {
            return [[_messages objectAtIndex:0] count];
        } else {
            return [[_messages objectAtIndex:1] count];
        }
    } else {
        return _messages.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResolutionCenterDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [ResolutionCenterDetailCell newCell];
        cell.delegate = self;
    }
    
    InboxTicketDetail *ticket;
    if (self.inboxTicket.ticket_show_more_messages) {
        ticket = [[_messages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        ticket = _messages[indexPath.row];
    }

    [cell setViewModel:ticket.viewModel];

    cell.indexPath = indexPath;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIColor *orangeColor = [UIColor colorWithRed:255.f/255.f green:243.f/255.f blue:224.f/255.f alpha:1];
        cell.buyerView.backgroundColor = orangeColor;
    } else {
        UIColor *lightGrayColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
        cell.buyerView.backgroundColor = lightGrayColor;
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.inboxTicket.ticket_show_more_messages && section == 0 && _canLoadMore) {
        return _loadMoreView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.inboxTicket.ticket_show_more_messages && section == 0 && _canLoadMore) {
        return _loadMoreView.frame.size.height;
    } else {
        return 0;
    }
}

-(NSString *)inboxTicketId{
    if (_canLoadMore){
        return _inboxTicket.ticket_id?:_inboxTicketId;
    } else {
        return _inboxTicket.ticket_inbox_id?:_inboxTicketId;
    }
}

- (void)loadTicketsData:(InboxTicketResultDetail *)data {
    if (!_ticketInformation) {
        _ticketInformation = data.ticket;
    }
    
    self.inboxTicket.ticket_show_more_messages = YES;
    
    self.tableView.sectionHeaderHeight = 0;
    
    if (_canLoadMore) {
        self.tableView.sectionFooterHeight = 0;
    }
    
    if(_ticketDetail == nil) {
        _ticketDetail = [InboxTicketDetail new];
        _ticketDetail.ticket_detail_user_name = _ticketInformation.ticket_first_message_name;
        _ticketDetail.ticket_detail_user_image = _ticketInformation.ticket_first_message_image;
        _ticketDetail.ticket_detail_message = _ticketInformation.ticket_first_message;
        _ticketDetail.ticket_detail_create_time = _ticketInformation.ticket_create_time;
        _ticketDetail.ticket_detail_attachment = _ticketInformation.ticket_attachment;
        
        NSString *ticketCategoryId = self.inboxTicket.ticket_category_id;
        if ([ticketCategoryId isEqualToString:@"0"]) {
            _ticketDetail.ticket_detail_is_cs = @"1";
        } else {
            _ticketDetail.ticket_detail_is_cs = @"0";
        }
    }
    
    NSMutableArray *tickets = [NSMutableArray new];
    for (InboxTicketDetail *message in data.ticket_reply.ticket_reply_data) {
        [tickets addObject:message];
    }
    
    if (_canLoadMore && [_messages[1] count] > 2)
    {
        //append new ticket
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tickets.count)];
        [_messages[1] insertObjects:tickets atIndexes:indexSet];
    }
    else
    {
        //replace the old ticket with the new one
        NSArray *array = @[@[_ticketDetail], tickets];
        _messages = [NSMutableArray arrayWithArray:array];
    }
    
    // Ticket not closed
    if ([_ticketInformation.ticket_status isEqualToString:@"1"]) {
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            [self showView:_buttonsView];
        }
    }
    
    // Ticket closed
    else if ([_ticketInformation.ticket_status isEqualToString:@"2"]) {
        
        // Ticket closed and replied by cs
        if ([_ticketInformation.ticket_is_replied boolValue]) {
            
            // Ticket closed, replied, not yet rate the ticket
            if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
                
                [self hideAllView];
            }
        } else {
            // Ticket closed without cs reply the ticket
            [self showView:_ticketClosedView];
        }

    }
    
    [_loadMoreButton setTitle:@"Lihat Sebelumnya" forState:UIControlStateNormal];
    
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
    
    [_indicatorView stopAnimating];
    
    [_refreshControl endRefreshing];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        NSInteger total = [_ticketInformation.ticket_total_message integerValue];
        self.inboxTicket.ticket_total_message = [NSString stringWithFormat:@"%ld", (long)total];
        self.inboxTicket.ticket_status = _ticketInformation.ticket_status;
        self.inboxTicket.ticket_read_status = _ticketInformation.ticket_read_status;
        [self.delegate updateInboxTicket:self.inboxTicket];
    }

    if (_page == 0) {
        if (_messages[1].count < [data.ticket_reply.ticket_reply_total_data integerValue]){
            _canLoadMore = YES;
        }
    } else {
        if (_page < [data.ticket_reply.ticket_reply_total_page integerValue]){
            _canLoadMore = YES;
        } else {
            _canLoadMore = NO;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDInboxTicketReceiveData object:nil];
}

#pragma mark - Cell delegate

- (void)goToImageViewerIndex:(NSInteger)index atIndexPath:(NSIndexPath *)indexPath {
    _selectedIndexPath = indexPath;
    
    GalleryViewController *gallery = [[GalleryViewController alloc] initWithPhotoSource:self withStartingIndex:index usingNetwork:YES];
    gallery.canDownload = YES;
    [self.navigationController presentViewController:gallery animated:YES completion:nil];
}

- (void)goToShopOrProfileIndexPath:(NSIndexPath *)indexPath {
}

- (void)tapCellButton:(UIButton *)sender atIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - Actions

- (IBAction)didTouchUpReplyButton:(UIButton *)sender {
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    InboxTicketList *newTicket = [InboxTicketList new];
    newTicket.ticket_id = _ticketInformation.ticket_id;
    newTicket.ticket_status = _ticketInformation.ticket_status;
    controller.inboxTicket = self.inboxTicket?:newTicket;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

- (IBAction)didTouchUpLoadMoreButton:(UIButton *)sender {
    [sender setTitle:@"Memuat..." forState:UIControlStateNormal];
    _page++;
    [self requestDetailTicket];
}

#pragma mark - GalleryPhoto Delegate

- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery {
    InboxTicketDetail *ticket;
    if (self.inboxTicket.ticket_show_more_messages) {
        ticket = [[_messages objectAtIndex:_selectedIndexPath.section] objectAtIndex:_selectedIndexPath.row];
    } else {
        ticket = _messages[_selectedIndexPath.row];
    }
    return ticket.ticket_detail_attachment.count;
}

- (NSString *)photoGallery:(GalleryViewController *)gallery urlForPhotoSize:(GalleryPhotoSize)size atIndex:(NSUInteger)index {
    InboxTicketDetail *ticket;
    if (self.inboxTicket.ticket_show_more_messages) {
        ticket = [[_messages objectAtIndex:_selectedIndexPath.section] objectAtIndex:_selectedIndexPath.row];
    } else {
        ticket = _messages[_selectedIndexPath.row];
    }
    InboxTicketDetailAttachment *attachment = [ticket.ticket_detail_attachment objectAtIndex:index];
    return attachment.img_link;
}

#pragma mark - Methods

- (void)showView:(UIView *)view {
    [self hideAllView];

    // Show preferd button and update table bottom margin
    view.hidden = NO;
    self.tableBottomConstraint.constant = view.frame.size.height;
    
    // Reload table appearance
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}

- (void)hideAllView {
    // Hide all buttons
    self.buttonsView.hidden = YES;
    self.ticketClosedView.hidden = YES;
}

- (void)refreshView {
    _canLoadMore = NO;
    _ticketInformation = nil;
    _page = 0;
    [self requestDetailTicket];
}

- (void)configureRefreshControl {
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [_refreshControl setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin)];
    [[_refreshControl.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 20, 20)];
    [self.tableView addSubview:_refreshControl];
}

- (void)appendTicketFromNotification:(NSNotification *)notification {
    InboxTicketDetail *ticket = [notification object];
    [_messages[1] addObject:ticket];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDInboxTicketReceiveData object:nil];
    
    [self.tableView reloadData];
}

@end
