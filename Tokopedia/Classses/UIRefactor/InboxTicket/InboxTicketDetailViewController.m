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
#import "GalleryViewController.h"
#import "UserContainerViewController.h"

NSString *const cellIdentifier = @"ResolutionCenterDetailCellIdentifier";

@interface InboxTicketDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TokopediaNetworkManagerDelegate,
    ResolutionCenterDetailCellDelegate,
    GalleryViewControllerDelegate
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
    NSInteger *_page;
    InboxTicketTicket *_ticketInformation;
    InboxTicketDetail *_ticketDetail;

    BOOL _isLoadingMore;
    
    NSIndexPath *_selectedIndexPath;
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

@property (strong, nonatomic) IBOutlet UIView *reopenTicketAfterReplyView;
@property (weak, nonatomic) IBOutlet UILabel *reopenTicketAfterReplyTitle;
@property (weak, nonatomic) IBOutlet UIButton *yesCloseButton;
@property (weak, nonatomic) IBOutlet UIButton *replyAfterCSButton;
@property (weak, nonatomic) IBOutlet UIButton *cloesAfterCSButton;

@property (strong, nonatomic) IBOutlet UIView *automaticCloseView;
@property (weak, nonatomic) IBOutlet UILabel *automaticCloseTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *automaticCloseRatingNoButton;
@property (weak, nonatomic) IBOutlet UIButton *automaticCloseRatingYesButton;
@property (weak, nonatomic) IBOutlet UIButton *automaticCloseReopenButton;

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
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = 1;

    if (self.inboxTicket || self.inboxTicketId) {
        [_networkManager doRequest];
    }

    _ratingNetworkManager = [TokopediaNetworkManager new];
    _ratingNetworkManager.delegate = self;
    _ratingNetworkManager.tagRequest = 2;
    
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
    
    self.reopenTicketAfterReplyTitle.attributedText = [[NSAttributedString alloc] initWithString:self.reopenTicketAfterReplyTitle.text attributes:ratingTitleAttributes];

    self.automaticCloseTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.automaticCloseTitleLabel.text attributes:ratingTitleAttributes];
    
    self.replyButton.layer.cornerRadius = 2;
    self.closeTicketButton.layer.cornerRadius = 2;
    self.yesButton.layer.cornerRadius = 2;
    self.noButton.layer.cornerRadius = 2;
    self.loadMoreButton.layer.cornerRadius = 2;
    self.lastCloseButton.layer.cornerRadius = 2;
    self.lastReplyButton.layer.cornerRadius = 2;
    self.yesCloseButton.layer.cornerRadius = 2;
    self.replyAfterCSButton.layer.cornerRadius = 2;
    self.cloesAfterCSButton.layer.cornerRadius = 2;
    self.automaticCloseRatingNoButton.layer.cornerRadius = 2;
    self.automaticCloseRatingYesButton.layer.cornerRadius = 2;
    self.automaticCloseReopenButton.layer.cornerRadius = 2;
    
    _isLoadingMore = NO;
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        self.inboxTicket.ticket_read_status = @"2";
        [self.delegate updateInboxTicket:_inboxTicket];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:TKPDInboxTicketLoadData
                                               object:nil];
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
        _isLoadingMore = NO;
        
        self.view.hidden = NO;
        
        [_loadMoreButton setTitle:@"Lihat Semua" forState:UIControlStateNormal];
        
        [self setTitleView];
        
        [self showRefreshControl];
        
        [_networkManager doRequest];
    }
    else {
        self.navigationItem.titleView = nil;
        self.view.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                           value:[UIFont boldSystemFontOfSize: 16.0f]
                           range:NSMakeRange(0, ticketID.length)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize: 11.0f];
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
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:13],
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
        
        CGSize invoiceLabelSize = [invoice sizeWithFont:FONT_GOTHAM_BOOK_14
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
    
    NSString *message = ticket.ticket_detail_message;
    if ([ticket.ticket_detail_new_rating isEqualToString:@"1"]) {
        message = [NSString stringWithFormat:@"%@\n\nMemberikan Penilaian : Membantu", ticket.ticket_detail_message];
    } else if ([ticket.ticket_detail_new_rating isEqualToString:@"2"]) {
        message = [NSString stringWithFormat:@"%@\n\nMemberikan Penilaian : Tidak Membantu", ticket.ticket_detail_message];
    }
    
    CGRect paragraphRect = [message boundingRectWithSize:CGSizeMake(300.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont fontWithName:@"GothamBook" size:14]} context:nil];

    height = cellRowHeight + paragraphRect.size.height;
    
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
    if (self.inboxTicket.ticket_show_more_messages && section == 0 && !_isLoadingMore) {
        return _loadMoreView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.inboxTicket.ticket_show_more_messages && section == 0 && !_isLoadingMore) {
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
                           API_LIST_TICKET_ID_KEY     : _inboxTicket.ticket_id?:_inboxTicketId
                           };
        } else {
            dictionary = @{
                           API_ACTION_KEY             : API_GET_INBOX_TICKET_DETAIL,
                           API_TICKET_INBOX_ID_KEY    : _inboxTicket.ticket_inbox_id?:_inboxTicketId,
                           };
        }
    } else {
        
        if ([_ticketInformation.ticket_status isEqualToString:@"1"] &&
            ![_ticketInformation.ticket_respond_status isEqualToString:@"0"] &&
            [_ticketInformation.ticket_is_replied boolValue]) {
            dictionary = @{
                           API_ACTION_KEY           : API_ACTION_GIVE_RATING,
                           API_LIST_TICKET_ID_KEY   : _inboxTicket.ticket_id,
                           API_RATE_KEY             : _rating?@"1":@"0",
                           API_NEW_TICKET_STATUS_KEY    : @"1",
                           };
        } else {
            dictionary = @{
                           API_ACTION_KEY           : API_ACTION_GIVE_RATING,
                           API_LIST_TICKET_ID_KEY   : _inboxTicket.ticket_id,
                           API_RATE_KEY             : _rating?@"1":@"0",
                           };
        }
        
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
                                                       API_LIST_TICKET_UPDATE_BY_NAME_KEY,
                                                       API_LIST_TICKET_TOTAL_MESSAGE_KEY,
                                                       API_LIST_TICKET_INVOICE_REF_NUM_KEY]];
        
        [statusMapping addRelationshipMappingWithSourceKeyPath:kTKPD_APIRESULTKEY mapping:resultMapping];
        
        [resultMapping addRelationshipMappingWithSourceKeyPath:API_TICKET_REPLY_KEY mapping:replyMapping];
        [resultMapping addRelationshipMappingWithSourceKeyPath:API_TICKET_KEY mapping:ticketMapping];
        [ticketMapping addRelationshipMappingWithSourceKeyPath:API_LIST_TICKET_ATTACHMENT_KEY mapping:attachmentMapping];
        
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
        [self setTitleView];
        [self setCategoryView];
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

        [self showView:_ratingResultView];

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
    
    self.tableView.hidden = NO;
}

- (void)loadTicketsData:(RKMappingResult *)mappingResult {
    DetailInboxTicket *response = [mappingResult.dictionary objectForKey:@""];
    
    if (!_ticketInformation) {
        _ticketInformation = response.result.ticket;
        if ([_ticketInformation.ticket_status isEqualToString:@"2"] && //CLOSED
            ![_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            if ([_ticketInformation.ticket_total_message integerValue] >= 2) {
                self.inboxTicket.ticket_show_more_messages = YES;
            }
        } else {
            if ([response.result.ticket_reply.ticket_reply_total_data integerValue] > 2) {
                self.inboxTicket.ticket_show_more_messages = YES;
            }
        }
    }

    self.tableView.sectionHeaderHeight = 0;
    
    if (_isLoadingMore) {
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
    for (InboxTicketDetail *message in response.result.ticket_reply.ticket_reply_data) {
        [tickets addObject:message];
    }
    
    if (self.inboxTicket.ticket_show_more_messages) {
        NSArray *array = @[@[_ticketDetail], tickets];
        _messages = [NSMutableArray arrayWithArray:array];
    } else {
        _messages = [NSMutableArray arrayWithArray:@[_ticketDetail]];
        [_messages addObjectsFromArray:tickets];
    }
    
    // Ticket not closed
    if ([_ticketInformation.ticket_status isEqualToString:@"1"]) {
        
        if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
            [self showView:_buttonsView];
        } else {
            if ([_ticketInformation.ticket_is_replied boolValue]) {
                // Right now disable all open ticket
                 [self showView:_reopenTicketAfterReplyView];
            } else {
                // Show reopen ticket
                 [self showView:_reopenTicketView];
            }
        }
    }
    
    // Ticket closed
    else if ([_ticketInformation.ticket_status isEqualToString:@"2"]) {
        
        // Ticket closed and replied by cs
        if ([_ticketInformation.ticket_is_replied boolValue]) {
            
            // Ticket closed, replied, not yet rate the ticket
            if ([_ticketInformation.ticket_respond_status isEqualToString:@"0"]) {
                
                if ([_ticketInformation.ticket_show_reopen_btn boolValue]) {
                    // Show automatic closed ticket information
                    [self showView:_automaticCloseView];
                } else {
                    // Show rating view
                    [self showView:_ratingView];
                }
                
            }
            
            // Ticket closed, replied, rated the ticket
            else if ([_ticketInformation.ticket_respond_status isEqualToString:@"1"] ||
                     [_ticketInformation.ticket_respond_status isEqualToString:@"2"]) {
                
                // Ticket closed, rated the ticket, but still can open ticket
                if ([_ticketInformation.ticket_show_reopen_btn boolValue]) {
                    
                    // Show reopen ticket
                     [self showView:_reopenTicketView];

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
                     [self showView:_reopenTicketView];
                } else {
                    [self showTicketRating:_ticketInformation];
                }
            } else {
                // Ticket closed without cs reply the ticket
                [self showView:_ticketClosedView];
            }
            
        }

    }
    
    [self.tableView reloadData];
    self.tableView.tableFooterView = nil;
    
    [_indicatorView stopAnimating];
    
    [_refreshControl endRefreshing];
    
    if ([self.delegate respondsToSelector:@selector(updateInboxTicket:)]) {
        NSInteger total = [_ticketInformation.ticket_total_message integerValue];
        self.inboxTicket.ticket_total_message = [NSString stringWithFormat:@"%d", total];
        self.inboxTicket.ticket_status = _ticketInformation.ticket_status;
        self.inboxTicket.ticket_read_status = _ticketInformation.ticket_read_status;
        [self.delegate updateInboxTicket:self.inboxTicket];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDInboxTicketReceiveData object:nil];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (void)showTicketRating:(InboxTicketTicket *)ticket {

    [self showView:_ratingResultView];
    
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

- (IBAction)didTouchUpCloseButton:(UIButton *)sender {
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    InboxTicketList *newTicket = [InboxTicketList new];
    newTicket.ticket_id = _ticketInformation.ticket_id;
    newTicket.ticket_status = _ticketInformation.ticket_status;
    controller.inboxTicket = self.inboxTicket?:newTicket;
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
    _yesButton.hidden = YES;
    _noButton.hidden = YES;
    _ratingActivityIndicator.hidden = NO;
    [_ratingActivityIndicator startAnimating];
    [_ratingNetworkManager doRequest];
}

- (IBAction)didTouchLastCloseButton:(UIButton *)sender {
    InboxTicketReplyViewController *controller = [InboxTicketReplyViewController new];
    controller.inboxTicket = self.inboxTicket;
    controller.isCloseTicketForm = YES;
    controller.rating = @"2";
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}
- (IBAction)didTouchReopenButton:(UIButton *)sender {
    [self showView:_buttonsView];
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
    self.ratingView.hidden = YES;
    self.ticketClosedView.hidden = YES;
    self.reopenTicketView.hidden = YES;
    self.reopenTicketAfterReplyView.hidden = YES;
    self.ratingResultView.hidden = YES;
    self.automaticCloseView.hidden = YES;
}

- (void)refreshView {
    _isLoadingMore = NO;
    _ticketInformation = nil;
    [_networkManager doRequest];
}

- (void)configureRefreshControl {
    _refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [_refreshControl setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin)];
    [[_refreshControl.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, 20, 20)];
    [self.tableView addSubview:_refreshControl];
}

@end
