//
//  ContactUsViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsViewController.h"
#import "TokopediaNetworkManager.h"
#import "ContactUsResponse.h"
#import "TicketCategory.h"
#import "string_contact_us.h"

@interface ContactUsViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TokopediaNetworkManagerDelegate
>
{
    TokopediaNetworkManager *_networkManager;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *contactType;
@property (strong, nonatomic) IBOutlet UITableViewCell *contactTypeIpad;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemDetailCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemSolutionCell;
@property (strong, nonatomic) IBOutlet UIView *typeHeaderView;
@property (strong, nonatomic) IBOutlet UIView *problemHeaderView;
@property (strong, nonatomic) IBOutlet UIView *solutionHeaderView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
//    [_networkManager doRequest];

    self.tableView.tableFooterView = _footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (section == 0) {
        rows = 1;
    } else if (section == 1) {
        rows = 2;
    } else if (section == 2) {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = _contactType;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = _problemCell;
        } else if (indexPath.row == 1) {
            cell = _problemDetailCell;
        }
    } else if (indexPath.section == 2) {
        cell = _problemSolutionCell;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    if (section == 0) {
        view = _typeHeaderView;
    } else if (section == 1) {
        view = _problemHeaderView;
    } else if (section == 2) {
        view = _solutionHeaderView;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = _typeHeaderView.frame.size.height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if (indexPath.section == 0) {
        height = 345;
    } else if (indexPath.section == 1) {
        height = 44;
    } else if (indexPath.section == 2) {
        height = 44;
    }
    return height;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *param = @{@"action" : @"get_tree_ticket_category"};
    return param;
}

- (NSString *)getPath:(int)tag {
    return @"contact-us.pl";
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ContactUsResponse class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ContactUsResult class]];
    
    RKObjectMapping *ticketCategoryMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [ticketCategoryMapping addAttributeMappingsFromArray:@[
                                                           API_TICKET_CATEGORY_NAME_KEY,
                                                           API_TICKET_CATEGORY_TREE_NO_KEY,
                                                           API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                           API_TICKET_CATEGORY_ID_KEY
                                                           ]];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];

    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                  toKeyPath:kTKPD_APILISTKEY
                                                                                withMapping:ticketCategoryMapping]];

    [ticketCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                          toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                        withMapping:ticketCategoryMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"contact-us.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];

    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    ContactUsResponse *inboxTicket = [mappingResult.dictionary objectForKey:@""];
    return inboxTicket.status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    
}

@end
