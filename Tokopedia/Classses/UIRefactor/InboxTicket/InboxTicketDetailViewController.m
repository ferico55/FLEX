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

NSString *const cellIdentifier = @"ResolutionCenterDetailCellIdentifier";

@interface InboxTicketDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TokopediaNetworkManagerDelegate,
    InboxTicketReplyDelegate,
    ResolutionCenterDetailCellDelegate
>
{
    NSString *_nextPageUri;
    UIRefreshControl *_refreshControl;
    NoResultView *_noResult;
    
    TokopediaNetworkManager *_networkManager;
    NSMutableArray *_messages;
    
    RKObjectManager *_objectManager;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

@end

@implementation InboxTicketDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *ticketID = [NSString stringWithFormat:@"No Tiket : %@", self.inboxTicket.ticket_id];
    NSString *status;
    if ([self.inboxTicket.ticket_status isEqualToString:@"1"]) {
        status = @"Dalam Proses";
    } else {
        status = @"Ditutup";
    }
    NSString *title = [NSString stringWithFormat:@"%@\n%@ - Status : %@", ticketID, self.inboxTicket.ticket_category, status];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize: 16.0f]
                           range:NSMakeRange(0, ticketID.length)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize: 11.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.attributedText = attributedText;
    
    self.navigationItem.titleView = label;
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:emptyView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _messages = [NSMutableArray new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    [_networkManager doRequest];
    
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    
    self.replyButton.layer.cornerRadius = 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    CGFloat cellRowHeight = 110;
    
    InboxTicketDetail *ticket = _messages[indexPath.row];
    CGSize maximumLabelSize = CGSizeMake(190,9999);
    CGSize expectedLabelSize = [ticket.ticket_detail_message sizeWithFont:FONT_GOTHAM_BOOK_12
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:NSLineBreakByTruncatingTail];

    height = cellRowHeight + expectedLabelSize.height;
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResolutionCenterDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [ResolutionCenterDetailCell newCell];
        cell.delegate = self;
    }

    [cell hideAllViews];
    cell.topMarginConstraint.constant = 5;
    cell.imageConstraintHeight.constant = 0;
    cell.twobuttonConstraintHeight.constant = 0;
    cell.oneButtonConstraintHeight.constant = 0;
    
    InboxTicketDetail *ticket = _messages[indexPath.row];
    [cell setViewModel:ticket.viewModel];
    
    //next page if already last cell
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
            [_networkManager doRequest];
        }
    }
    
    return cell;
}

#pragma mark - Network manager delegate

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *dictionary = @{
                                 API_ACTION_KEY             : API_GET_INBOX_TICKET_DETAIL,
                                 API_TICKET_INBOX_ID_KEY    : _inboxTicket.ticket_inbox_id
                                 };
    return dictionary;
}

- (NSString *)getPath:(int)tag {
    NSString *path = API_PATH;
    return path;
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[DetailInboxTicket class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxTicketResultDetail class]];
    
    RKObjectMapping *replyMapping = [RKObjectMapping mappingForClass:[InboxTicketReply class]];
    [replyMapping addAttributeMappingsFromArray:@[API_TICKET_REPLY_TOTAL_DATA_KEY,
                                                  API_TICKET_REPLY_TOTAL_PAGE_KEY]];

    RKObjectMapping *replyDataMapping = [RKObjectMapping mappingForClass:[InboxTicketDetail class]];
    [replyDataMapping addAttributeMappingsFromArray:@[API_TICKET_DETAIL_ID_KEY,
                                                      API_TICKET_DETAIL_CREATE_TIME_FMT_KEY,
                                                      API_TICKET_DETAIL_USER_NAME_KEY,
                                                      API_TICKET_DETAIL_NEW_RATING_KEY,
                                                      API_TICKET_DETAIL_IS_CS_KEY,
                                                      API_TICKET_DETAIL_USER_URL_KEY,
                                                      API_TICKET_DETAIL_USER_LABEL_ID_KEY,
                                                      API_TICKET_DETAIL_USER_LABEL_KEY,
                                                      API_TICKET_DETAIL_USER_IMAGE_KEY,
                                                      API_TICKET_DETAIL_USER_ID_KEY,
                                                      API_TICKET_DETAIL_NEW_STATUS_KEY,
                                                      API_TICKET_DETAIL_MESSAGE_KEY]];
    
    RKObjectMapping *ticketMapping = [RKObjectMapping mappingForClass:[InboxTicketTicket class]];
    [ticketMapping addAttributeMappingsFromArray:@[API_LIST_TICKET_FIRST_MESSAGE_NAME_KEY,
                                                   API_LIST_TICKET_CREATE_TIME_FMT_KEY,
                                                   API_LIST_TICKET_UPDATE_TIME_FMT_KEY,
                                                   API_TICKET_FIRST_MESSAGE_KEY,
                                                   API_TICKET_SHOW_REOPEN_BTN_KEY,
                                                   API_LIST_TICKET_STATUS_KEY,
                                                   API_LIST_TICKET_READ_STATUS_KEY,
                                                   API_TICKET_USER_LABEL_ID_KEY,
                                                   API_LIST_TICKET_UPDATE_IS_CS_KEY,
                                                   API_LIST_TICKET_INBOX_ID_KEY,
                                                   API_TICKET_USER_LABEL_KEY,
                                                   API_LIST_TICKET_UPDATE_BY_URL_KEY,
                                                   API_LIST_TICKET_CATEGORY_KEY,
                                                   API_LIST_TICKET_TITLE_KEY,
                                                   API_LIST_TICKET_RESPOND_STATUS_KEY,
                                                   API_LIST_TICKET_IS_REPLIED_KEY,
                                                   API_TICKET_FIRST_MESSAGE_IMAGE_KEY,
                                                   API_LIST_TICKET_URL_DETAIL_KEY,
                                                   API_LIST_TICKET_UPDATE_BY_ID_KEY,
                                                   API_LIST_TICKET_ID_KEY,
                                                   API_LIST_TICKET_UPDATE_BY_NAME_KEY]];
    
    [statusMapping addRelationshipMappingWithSourceKeyPath:kTKPD_APIRESULTKEY mapping:resultMapping];
    
    [resultMapping addRelationshipMappingWithSourceKeyPath:API_TICKET_REPLY_KEY mapping:replyMapping];
    [resultMapping addRelationshipMappingWithSourceKeyPath:API_TICKET_KEY mapping:ticketMapping];
    
    [replyMapping addRelationshipMappingWithSourceKeyPath:API_TICKET_REPLY_DATA_KEY mapping:replyDataMapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    DetailInboxTicket *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    DetailInboxTicket *response = [mappingResult.dictionary objectForKey:@""];

    InboxTicketTicket *ticketDetail = response.result.ticket;
    
    InboxTicketDetail *ticket = [InboxTicketDetail new];
    ticket.ticket_detail_user_name = ticketDetail.ticket_first_message_name;
    ticket.ticket_detail_user_image = ticketDetail.ticket_first_message_image;
    ticket.ticket_detail_message = ticketDetail.ticket_first_message;
    ticket.ticket_detail_create_time_fmt = ticketDetail.ticket_create_time_fmt;
    ticket.ticket_detail_is_cs = @"0";
    
    NSMutableArray *messages = [NSMutableArray arrayWithArray:@[ticket]];
    [messages addObjectsFromArray:response.result.ticket_reply.ticket_reply_data];

    _messages = messages;
    
    [self.tableView reloadData];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (IBAction)didTouchUpReplyButton:(UIButton *)sender {
    
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    controller.inboxTicket = self.inboxTicket;
    controller.delegate = self;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

#pragma mark - Ticket Reply delegate

- (void)successReplyInboxTicket:(InboxTicketDetail *)reply {
    NSMutableArray *messages = [NSMutableArray arrayWithArray:_messages];
    [messages addObject:reply];
    _messages = messages;
    [self.tableView reloadData];
    
    NSInteger row = _messages.count - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

#pragma mark - Cell delegate

- (void)goToImageViewerIndex:(NSInteger)index atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)goToShopOrProfileIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tapCellButton:(UIButton *)sender atIndexPath:(NSIndexPath *)indexPath {
    
}

@end
