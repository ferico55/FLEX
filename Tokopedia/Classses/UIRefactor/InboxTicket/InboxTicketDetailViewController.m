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
#import "RatingResponse.h"
#import "InboxTicketDetailAttachment.h"

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
    
    
    RKObjectManager *_objectManager;
    TokopediaNetworkManager *_networkManager;
    
    RKObjectManager *_ratingObjectManager;
    TokopediaNetworkManager *_ratingNetworkManager;
    BOOL _rating;
    
    NSMutableArray *_messages;
    InboxTicketTicket *_ticketInformation;
    InboxTicketDetail *_ticketDetail;

    BOOL _isLoadingMore;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;

@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (strong, nonatomic) IBOutlet UIView *loadMoreView;

@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UIView *ratingResultView;
@property (weak, nonatomic) IBOutlet UILabel *ratingResultTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingResultLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *closeTicketButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ratingActivityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ratingFormBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ratingResultBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *ticketClosedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ticketClosedBottomConstraint;

@property (weak, nonatomic) IBOutlet UIView *reopenTicketView;
@property (weak, nonatomic) IBOutlet UILabel *reopenTicketLabel;

@property (weak, nonatomic) IBOutlet UILabel *ticketClosedLabel;

@property (weak, nonatomic) IBOutlet UIButton *lastReplyButton;
@property (weak, nonatomic) IBOutlet UIButton *lastCloseButton;


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
    _networkManager.tagRequest = 1;
    [_networkManager doRequest];

    _ratingNetworkManager = [TokopediaNetworkManager new];
    _ratingNetworkManager.delegate = self;
    _ratingNetworkManager.tagRequest = 2;

    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    
    self.ratingActivityIndicator.hidden = YES;
    self.ratingActivityIndicator.hidesWhenStopped = YES;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    style.alignment = NSTextAlignmentCenter;
    
    UIFont *gothamBook = [UIFont fontWithName:@"GothamBook" size:13];
    UIFont *gothamMedium = [UIFont fontWithName:@"GothamMedium" size:13];
    
    NSDictionary *ratingAttributes = @{
        NSFontAttributeName             : gothamBook,
        NSParagraphStyleAttributeName   : style
    };
    
    self.ratingLabel.attributedText = [[NSAttributedString alloc] initWithString:self.ratingLabel.text?:@""
                                                                      attributes:ratingAttributes];
    
    NSDictionary *ratingTitleAttributes = @{
        NSFontAttributeName            : gothamMedium,
        NSParagraphStyleAttributeName  : style,
    };

    self.ratingResultTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.ratingResultTitleLabel.text attributes:ratingTitleAttributes];
    
    self.reopenTicketLabel.attributedText = [[NSAttributedString alloc] initWithString:self.reopenTicketLabel.text attributes:ratingTitleAttributes];

    self.ticketClosedLabel.attributedText = [[NSAttributedString alloc] initWithString:self.ticketClosedLabel.text attributes:ratingTitleAttributes];
    
    self.replyButton.layer.cornerRadius = 2;
    self.closeTicketButton.layer.cornerRadius = 2;
    self.yesButton.layer.cornerRadius = 2;
    self.noButton.layer.cornerRadius = 2;
    self.loadMoreButton.layer.cornerRadius = 2;
    self.lastCloseButton.layer.cornerRadius = 2;
    self.lastReplyButton.layer.cornerRadius = 2;
    
    _isLoadingMore = NO;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    CGFloat cellRowHeight = 90;
    CGFloat photoHeight = 74;
    
    InboxTicketDetail *ticket;
    if (self.inboxTicket.ticket_show_more_messages) {
        ticket = [[_messages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        ticket = _messages[indexPath.row];
    }
    
    CGSize maximumLabelSize = CGSizeMake(190,9999);
    CGSize expectedLabelSize = [ticket.ticket_detail_message sizeWithFont:FONT_GOTHAM_BOOK_12
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:NSLineBreakByTruncatingTail];

    height = cellRowHeight + expectedLabelSize.height;
    
    if (ticket.ticket_detail_attachment.count > 0) {
        height += photoHeight;
    }
    
    return height;
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
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.inboxTicket.ticket_show_more_messages && section == 0 && !_isLoadingMore) {
        return _loadMoreView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (!_isLoadingMore && self.inboxTicket.ticket_show_more_messages && section == 0) {
        return _loadMoreView.frame.size.height;
    } else {
        return 0;
    }
}

#pragma mark - Network manager delegate

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *dictionary;
    if (tag == 1) {
        if (_isLoadingMore) {
            dictionary = @{
                           API_ACTION_KEY             : API_GET_INBOX_TICKET_VIEW_MORE,
                           API_LIST_TICKET_ID_KEY     : _inboxTicket.ticket_id
                           };
        } else {
            dictionary = @{
                           API_ACTION_KEY             : API_GET_INBOX_TICKET_DETAIL,
                           API_TICKET_INBOX_ID_KEY    : _inboxTicket.ticket_inbox_id,
                           };
        }
    } else {
        dictionary = @{
                       API_ACTION_KEY           : API_ACTION_GIVE_RATING,
                       API_LIST_TICKET_ID_KEY   : _inboxTicket.ticket_id,
                       API_RATE_KEY             : _rating?@"1":@"0",
                       };
    }
    return dictionary;
}

- (NSString *)getPath:(int)tag {
    NSString *path;
    if (tag == 1) {
        path = API_PATH;
    } else {
        path = API_PATH_ACTION;
    }
    return path;
}

- (id)getObjectManager:(int)tag {
    if (tag == 1) {
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
                                                          API_TICKET_DETAIL_CREATE_TIME_KEY,
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
        
        RKObjectMapping *attachmentMapping = [RKObjectMapping mappingForClass:[InboxTicketDetailAttachment class]];
        [attachmentMapping addAttributeMappingsFromArray:@[
                                                           API_TICKET_DETAIL_IMG_LINK_KEY,
                                                           API_TICKET_DETAIL_IMG_SRC_KEY
                                                           ]];
        
        RKObjectMapping *ticketMapping = [RKObjectMapping mappingForClass:[InboxTicketTicket class]];
        [ticketMapping addAttributeMappingsFromArray:@[API_LIST_TICKET_FIRST_MESSAGE_NAME_KEY,
                                                       API_LIST_TICKET_CREATE_TIME_KEY,
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
        [replyDataMapping addRelationshipMappingWithSourceKeyPath:API_TICKET_DETAIL_ATTACHMENT_KEY mapping:attachmentMapping];

        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                method:RKRequestMethodPOST
                                                                                           pathPattern:API_PATH
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectManager addResponseDescriptor:responseDescriptor];
        
        return _objectManager;
    } else {
        _ratingObjectManager = [RKObjectManager sharedClient];
        
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[RatingResponse class]];
        [statusMapping addAttributeMappingsFromArray:@[
                                                       kTKPD_APISTATUSMESSAGEKEY,
                                                       kTKPD_APIERRORMESSAGEKEY,
                                                       kTKPD_APISTATUSKEY,
                                                       kTKPD_APISERVERPROCESSTIMEKEY,
                                                       ]];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[RatingResult class]];
        [resultMapping addAttributeMappingsFromArray:@[API_TICKET_REPLY_IS_SUCCESS_KEY]];
        
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping]];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                method:RKRequestMethodPOST
                                                                                           pathPattern:API_PATH_ACTION
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_ratingObjectManager addResponseDescriptor:responseDescriptor];
        
        return _ratingObjectManager;
    }
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    DetailInboxTicket *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (void)actionBeforeRequest:(int)tag {
    if (tag == 1) {
        if (_messages.count == 0) {
            self.tableView.tableFooterView = _tableFooterView;
            [_indicatorView startAnimating];
        }
    }
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {

    // action after request ticket detail
    if (tag == 1) {
        [self loadTicketsData:mappingResult];
    }
    
    // action after request give rating
    else if (tag == 2) {
        NSString *rating = _rating?@"Membantu":@"Tidak Membantu";
        NSString *text = [NSString stringWithFormat:@"Penilaian Anda : %@", rating];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        UIFont *font = [UIFont fontWithName:@"GothamMedium" size:12];
        [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(17, rating.length)];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
        
        self.ratingResultLabel.attributedText = attributedString;

        self.ratingResultBottomConstraint.constant = -self.ratingResultView.frame.size.height;
        self.tableBottomConstraint.constant = self.ratingResultView.frame.size.height;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        
        self.buttonsView.hidden = YES;
        self.ratingView.hidden = YES;
        self.ticketClosedView.hidden = YES;
        self.ratingResultView.hidden = NO;

        [_ratingActivityIndicator stopAnimating];

        [UIView animateWithDuration:0.2 animations:^{
            self.ratingFormBottomConstraint.constant = -self.ratingView.frame.size.height;
        } completion:^(BOOL finished) {
            self.ratingView.hidden = YES;
            [UIView animateWithDuration:0.2 animations:^{
                self.ratingResultBottomConstraint.constant = 0;
            }];
        }];
    }
}

- (void)loadTicketsData:(RKMappingResult *)mappingResult {
    DetailInboxTicket *response = [mappingResult.dictionary objectForKey:@""];
    
    _ticketInformation = response.result.ticket;
    
    if (!_ticketDetail) {
        _ticketDetail = [InboxTicketDetail new];
        _ticketDetail = [InboxTicketDetail new];
        _ticketDetail.ticket_detail_user_name = _ticketInformation.ticket_first_message_name;
        _ticketDetail.ticket_detail_user_image = _ticketInformation.ticket_first_message_image;
        _ticketDetail.ticket_detail_message = _ticketInformation.ticket_first_message;
        _ticketDetail.ticket_detail_create_time = _ticketInformation.ticket_create_time;
        _ticketDetail.ticket_detail_is_cs = @"0";
    }
    
    if (self.inboxTicket.ticket_show_more_messages) {
        NSArray *array = @[@[_ticketDetail], response.result.ticket_reply.ticket_reply_data];
        _messages = [NSMutableArray arrayWithArray:array];
    } else {
        _messages = [NSMutableArray arrayWithArray:@[_ticketDetail]];
        [_messages addObjectsFromArray:response.result.ticket_reply.ticket_reply_data];
    }
    
    // Ticket not closed
    if ([_ticketInformation.ticket_status isEqualToString:@"1"]) {
        
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            self.buttonsView.hidden = NO;
            self.ratingView.hidden = YES;
            self.ticketClosedView.hidden = YES;
            self.reopenTicketView.hidden = YES;
            self.ratingResultView.hidden = YES;
            CGFloat buttonsViewHeight = 50;
            self.tableBottomConstraint.constant = buttonsViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        } else {
            // Show reopen ticket
            self.reopenTicketView.hidden = NO;
            self.ratingView.hidden = YES;
            self.buttonsView.hidden = YES;
            self.ticketClosedView.hidden = YES;
            self.ratingResultView.hidden = YES;
            CGFloat ratingViewHeight = 120;
            self.tableBottomConstraint.constant = ratingViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
    }
    
    // Ticket closed
    else if ([_ticketInformation.ticket_status isEqualToString:@"2"]) {
        
        // Ticket closed and replied by cs
        if ([_ticketInformation.ticket_is_replied boolValue]) {
            
            // Ticket closed, replied, not yet rate the ticket
            if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
                
                // Show rating view
                self.ratingView.hidden = NO;
                self.buttonsView.hidden = YES;
                self.ticketClosedView.hidden = YES;
                self.reopenTicketView.hidden = YES;
                self.ratingResultView.hidden = YES;
                CGFloat ratingViewHeight = 120;
                self.tableBottomConstraint.constant = ratingViewHeight;
                [self.tableView reloadData];
                [self.tableView layoutIfNeeded];
            }
            
            // Ticket closed, replied, rated the ticket
            else if ([_ticketInformation.ticket_respond_status isEqualToString:@"1"] ||
                     [_ticketInformation.ticket_respond_status isEqualToString:@"2"]) {
                
                // Ticket closed, rated the ticket, but still can open ticket
                if ([_ticketInformation.ticket_show_reopen_btn boolValue]) {
                    
                    // Show reopen ticket
                    self.reopenTicketView.hidden = NO;
                    self.ratingView.hidden = YES;
                    self.buttonsView.hidden = YES;
                    self.ticketClosedView.hidden = YES;
                    self.ratingResultView.hidden = YES;
                    CGFloat ratingViewHeight = 120;
                    self.tableBottomConstraint.constant = ratingViewHeight;
                    [self.tableView reloadData];
                    [self.tableView layoutIfNeeded];
                    
                } else {
                    [self showTicketRating:_ticketInformation];
                }
            }
            
        } else {
            
            // Ticket closed, replied, rated the ticket
            if ([_ticketInformation.ticket_respond_status isEqualToString:@"1"] ||
                [_ticketInformation.ticket_respond_status isEqualToString:@"2"]) {
                
                if ([_ticketInformation.ticket_show_reopen_btn boolValue]) {
                    // Show reopen ticket
                    self.reopenTicketView.hidden = NO;
                    self.ratingView.hidden = YES;
                    self.buttonsView.hidden = YES;
                    self.ticketClosedView.hidden = YES;
                    self.ratingResultView.hidden = YES;
                    CGFloat ratingViewHeight = 120;
                    self.tableBottomConstraint.constant = ratingViewHeight;
                    [self.tableView reloadData];
                    [self.tableView layoutIfNeeded];
                } else {
                    [self showTicketRating:_ticketInformation];
                }
            } else {
                // Ticket closed without cs reply the ticket
                self.ticketClosedView.hidden = NO;
                self.ratingView.hidden = YES;
                self.buttonsView.hidden = YES;
                self.reopenTicketView.hidden = YES;
                self.ratingResultView.hidden = YES;
                CGFloat ratingViewHeight = 84;
                self.tableBottomConstraint.constant = ratingViewHeight;
                [self.tableView reloadData];
                [self.tableView layoutIfNeeded];
            }
            
        }

    }
    
    
   
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
    
    [_indicatorView stopAnimating];
    
    [_refreshControl endRefreshing];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (void)showTicketRating:(InboxTicketTicket *)ticket {
    self.buttonsView.hidden = YES;
    self.ratingView.hidden = YES;
    self.ticketClosedView.hidden = YES;
    self.reopenTicketView.hidden = YES;
    self.ratingResultView.hidden = NO;

    CGFloat ratingResultViewHeight = 105;
    self.tableBottomConstraint.constant = ratingResultViewHeight;
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    
    NSString *rating;
    // rating 1 == good, 2 == bad
    if ([ticket.ticket_respond_status isEqualToString:@"1"]) {
        rating = @"Membantu";
    } else if ([ticket.ticket_respond_status isEqualToString:@"2"]) {
        rating = @"Tidak Membantu";
    }
    NSString *text = [NSString stringWithFormat:@"Penilaian Anda : %@", rating];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    UIFont *font = [UIFont fontWithName:@"GothamMedium" size:12];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(17, rating.length)];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    self.ratingResultLabel.attributedText = attributedString;
}

#pragma mark - Ticket Reply delegate

- (void)successReplyInboxTicket:(InboxTicketDetail *)reply {
    NSInteger row;
    NSInteger section;
    if (self.inboxTicket.ticket_show_more_messages) {
        [[_messages objectAtIndex:1] addObject:reply];
        row = [[_messages objectAtIndex:1] count] - 1;
        section = 1;
    } else {
        [_messages addObject:reply];
        row = _messages.count - 1;
        section = 0;
    }

    [self.tableView reloadData];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        NSInteger total = [self.inboxTicket.ticket_total_message integerValue] + 1;
        self.inboxTicket.ticket_total_message = [NSString stringWithFormat:@"%d", total];
        self.inboxTicket.ticket_status = @"2";
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
}

- (void)successReplyInboxTicket:(InboxTicketDetail *)reply withRating:(NSString *)rating {
    if ([_ticketInformation.ticket_is_replied boolValue]) {
        _ticketInformation.ticket_show_reopen_btn = @"1";
        _ticketInformation.ticket_respond_status = rating;
        self.inboxTicket.ticket_show_reopen_btn = @"1";
        self.inboxTicket.ticket_respond_status = rating;
        // Ticket closed, replied, not yet rate the ticket
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            // Show rating view
            self.ratingView.hidden = NO;
            self.buttonsView.hidden = YES;
            self.ticketClosedView.hidden = YES;
            self.reopenTicketView.hidden = YES;
            self.ratingResultView.hidden = YES;
            CGFloat ratingViewHeight = 120;
            self.tableBottomConstraint.constant = ratingViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
        
        // Ticket closed, replied, rated the ticket
        else if ([_ticketInformation.ticket_respond_status isEqualToString:@"1"] ||
                 [_ticketInformation.ticket_respond_status isEqualToString:@"2"]) {
            // Show reopen ticket
            self.reopenTicketView.hidden = NO;
            self.ratingView.hidden = YES;
            self.buttonsView.hidden = YES;
            self.ticketClosedView.hidden = YES;
            self.ratingResultView.hidden = YES;
            CGFloat reopenTicketViewHeight = 120;
            self.tableBottomConstraint.constant = reopenTicketViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
    } else {
        
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            self.ticketClosedView.hidden = NO;
            self.buttonsView.hidden = YES;
            self.ratingResultView.hidden = YES;
            self.reopenTicketView.hidden = YES;
            self.ratingView.hidden = YES;
            CGFloat ticketClosedViewHeight = 84;
            self.tableBottomConstraint.constant = ticketClosedViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        } else {
            [self showTicketRating:_ticketInformation];
        }
    }
    
    NSInteger row;
    NSInteger section;
    if (self.inboxTicket.ticket_show_more_messages) {
        [[_messages objectAtIndex:1] addObject:reply];
        row = [[_messages objectAtIndex:1] count] - 1;
        section = 1;
    } else {
        [_messages addObject:reply];
        row = _messages.count - 1;
        section = 0;
    }
    
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        NSInteger total = [self.inboxTicket.ticket_total_message integerValue] + 1;
        self.inboxTicket.ticket_total_message = [NSString stringWithFormat:@"%d", total];
        self.inboxTicket.ticket_status = @"2";
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
}

- (void)successCloseInboxTicket:(InboxTicketDetail *)reply {
    if ([_ticketInformation.ticket_is_replied boolValue]) {
        _ticketInformation.ticket_show_reopen_btn = @"1";
        self.inboxTicket.ticket_show_reopen_btn = @"1";
        // Ticket closed, replied, not yet rate the ticket
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            // Show rating view
            self.ratingView.hidden = NO;
            self.buttonsView.hidden = YES;
            self.ticketClosedView.hidden = YES;
            self.reopenTicketView.hidden = YES;
            self.ratingResultView.hidden = YES;
            CGFloat ratingViewHeight = 120;
            self.tableBottomConstraint.constant = ratingViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
        
        // Ticket closed, replied, rated the ticket
        else if ([_ticketInformation.ticket_respond_status isEqualToString:@"1"] ||
                 [_ticketInformation.ticket_respond_status isEqualToString:@"2"]) {
            // Ticket closed, rated the ticket, but still can open ticket
            if ([_ticketInformation.ticket_show_reopen_btn boolValue]) {
                // Show reopen ticket
                self.reopenTicketView.hidden = NO;
                self.ratingView.hidden = YES;
                self.buttonsView.hidden = YES;
                self.ticketClosedView.hidden = YES;
                self.ratingResultView.hidden = YES;
                CGFloat ratingViewHeight = 120;
                self.tableBottomConstraint.constant = ratingViewHeight;
                [self.tableView reloadData];
                [self.tableView layoutIfNeeded];
            } else {
                [self showTicketRating:_ticketInformation];
            }
        }
    } else {
        self.ticketClosedView.hidden = NO;
        self.buttonsView.hidden = YES;
        self.ratingResultView.hidden = YES;
        self.reopenTicketView.hidden = YES;
        self.ratingView.hidden = YES;
        CGFloat ratingViewHeight = 84;
        self.tableBottomConstraint.constant = ratingViewHeight;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
    }
    
    NSInteger row;
    NSInteger section;
    if (self.inboxTicket.ticket_show_more_messages) {
        [[_messages objectAtIndex:1] addObject:reply];
        row = [[_messages objectAtIndex:1] count] - 1;
        section = 1;
    } else {
        [_messages addObject:reply];
        row = _messages.count - 1;
        section = 0;
    }
    
    [self.tableView reloadData];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        NSInteger total = [self.inboxTicket.ticket_total_message integerValue] + 1;
        self.inboxTicket.ticket_total_message = [NSString stringWithFormat:@"%d", total];
        self.inboxTicket.ticket_status = @"2";
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
}

- (void)successCloseInboxTicket:(InboxTicketDetail *)reply withRating:(NSString *)rating {
    if ([_ticketInformation.ticket_is_replied boolValue]) {
        _ticketInformation.ticket_show_reopen_btn = @"1";
        _ticketInformation.ticket_respond_status = rating;
        self.inboxTicket.ticket_show_reopen_btn = @"1";
        self.inboxTicket.ticket_respond_status = rating;
        // Ticket closed, replied, not yet rate the ticket
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            // Show rating view
            self.ratingView.hidden = NO;
            self.buttonsView.hidden = YES;
            self.ticketClosedView.hidden = YES;
            self.reopenTicketView.hidden = YES;
            self.ratingResultView.hidden = YES;
            CGFloat ratingViewHeight = 120;
            self.tableBottomConstraint.constant = ratingViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        }
        
        // Ticket closed, replied, rated the ticket
        else if ([_ticketInformation.ticket_respond_status isEqualToString:@"1"] ||
                 [_ticketInformation.ticket_respond_status isEqualToString:@"2"]) {
            [self showTicketRating:_ticketInformation];
        }
    } else {
        
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            self.ticketClosedView.hidden = NO;
            self.buttonsView.hidden = YES;
            self.ratingResultView.hidden = YES;
            self.reopenTicketView.hidden = YES;
            self.ratingView.hidden = YES;
            CGFloat ticketClosedViewHeight = 84;
            self.tableBottomConstraint.constant = ticketClosedViewHeight;
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
        } else {
            [self showTicketRating:_ticketInformation];            
        }
    }
    
    NSInteger row;
    NSInteger section;
    if (self.inboxTicket.ticket_show_more_messages) {
        [[_messages objectAtIndex:1] addObject:reply];
        row = [[_messages objectAtIndex:1] count] - 1;
        section = 1;
    } else {
        [_messages addObject:reply];
        row = _messages.count - 1;
        section = 0;
    }
    
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        NSInteger total = [self.inboxTicket.ticket_total_message integerValue] + 1;
        self.inboxTicket.ticket_total_message = [NSString stringWithFormat:@"%d", total];
        self.inboxTicket.ticket_status = @"2";
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
}

#pragma mark - Cell delegate

- (void)goToImageViewerIndex:(NSInteger)index atIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)goToShopOrProfileIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tapCellButton:(UIButton *)sender atIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Actions

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

- (IBAction)didTouchUpCloseButton:(UIButton *)sender {
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    controller.inboxTicket = self.inboxTicket;
    controller.delegate = self;
    controller.isCloseTicketForm = YES;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

- (IBAction)didTouchUpLoadMoreButton:(UIButton *)sender {
    [sender setTitle:@"Memuat..." forState:UIControlStateNormal];
    _isLoadingMore = YES;
    [_networkManager doRequest];
}

- (IBAction)didTouchUpRatingYesButton:(UIButton *)sender {
    _rating = YES;
    _yesButton.hidden = YES;
    _noButton.hidden = YES;
    _ratingActivityIndicator.hidden = NO;
    [_ratingActivityIndicator startAnimating];
    [_ratingNetworkManager doRequest];
}

- (IBAction)didTouchUpRatingNoButton:(UIButton *)sender {
    _rating = NO;
    [_ratingNetworkManager doRequest];
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    controller.inboxTicket = self.inboxTicket;
    controller.delegate = self;
    controller.rating = @"2";
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

- (IBAction)didTouchLastCloseButton:(UIButton *)sender {
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    controller.inboxTicket = self.inboxTicket;
    controller.delegate = self;
    controller.isCloseTicketForm = YES;
    controller.rating = @"2";
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

#pragma mark - Methods

- (void)refreshView {
    [_networkManager doRequest];
}

@end
