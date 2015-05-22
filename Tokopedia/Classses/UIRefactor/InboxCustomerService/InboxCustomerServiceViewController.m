//
//  InboxCustomerServiceViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxCustomerServiceViewController.h"
#import "InboxCustomerServiceCell.h"
#import "TokopediaNetworkManager.h"
#import "string_inbox_ticket.h"
#import "InboxTicket.h"
#import "InboxTicketList.h"
#import "InboxTicketPaging.h"
#import "InboxTicketUserInvolve.h"

@interface InboxCustomerServiceViewController () <TokopediaNetworkManagerDelegate> {
    TokopediaNetworkManager *_networkManager;
    NSMutableArray *_tickets;
    NSString *_uriNext;
    NSInteger _page;
}

@end

@implementation InboxCustomerServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 15, 0);
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    _tickets = [NSMutableArray new];
    _uriNext = @"";
    _page = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxCustomerServiceCell *cell = (InboxCustomerServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"InboxCustomerServiceCell"];
    if (cell == nil) {
        cell = [InboxCustomerServiceCell initCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Tokopedia network manager

- (NSDictionary *)getParameter:(int)tag
{
    NSString *status = @"";
    if (_inboxCustomerServiceType == InboxCustomerServiceTypeInProcess) {
        status = @"1";
    } else if (_inboxCustomerServiceType == InboxCustomerServiceTypeClosed) {
        status = @"2";
    }
    
    NSDictionary *dictionary = @{
                                 API_ACTION_KEY : API_GET_INBOX_TICKET,
                                 API_STATUS_KEY : status,
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
                                                        API_LIST_TICKET_UPDATE_BY_NAME_KEY
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
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag{
    InboxTicket *inboxTicket = [mappingResult.dictionary objectForKey:@""];
    [_tickets addObjectsFromArray: inboxTicket.result.list];
    
    if (_tickets.count >0) {
        _uriNext =  inboxTicket.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_uriNext] integerValue];
    }
    
    [self.tableView reloadData];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {

}

@end
