//
//  InboxTicketDetailViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketDetailViewController.h"
#import "InboxTicket.h"
#import "InboxTicketDetail.h"
#import "InboxTicketResultDetail.h"
#import "InboxTicketReply.h"
#import "InboxTicketTicket.h"
#import "ResolutionCenterDetailCell.h"
#import "string_inbox_ticket.h"

NSString *const cellIdentifier = @"ResolutionCenterDetailCellIdentifier";

@interface InboxTicketDetailViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TokopediaNetworkManagerDelegate
>
{
    NSString *_nextPageUri;
    UIRefreshControl *_refreshControl;
    NoResultView *_noResult;
    
    TokopediaNetworkManager *_networkManager;
    NSMutableArray *_messages;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InboxTicketDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResolutionCenterDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
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

- (id)getObjectManager:(int)tag {
    __weak RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxTicket class]];
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
    
    RKRelationshipMapping *resultRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                            toKeyPath:kTKPD_APIRESULTKEY
                                                                                          withMapping:resultMapping];
    [statusMapping addPropertyMapping:resultRelationship];
    
    RKRelationshipMapping *replyRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_REPLY_KEY
                                                                                           toKeyPath:API_TICKET_REPLY_KEY
                                                                                         withMapping:replyMapping];

    RKRelationshipMapping *ticketRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_KEY
                                                                                            toKeyPath:API_TICKET_KEY
                                                                                          withMapping:ticketMapping];
    
    [resultMapping addPropertyMappingsFromArray:@[replyRelationship, ticketRelationship]];
    
    RKRelationshipMapping *replyDataRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_REPLY_DATA_KEY
                                                                                               toKeyPath:API_TICKET_REPLY_DATA_KEY
                                                                                             withMapping:replyDataMapping];
    [replyDataMapping addPropertyMapping:replyDataRelationship];
    
    return objectManager;
}

@end
