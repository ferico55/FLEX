//
//  ResolutionCenterDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterDetailViewController.h"

#import "TrackOrderViewController.h"

#import "ResolutionCenterDetailCell.h"
#import "ResolutionCenterSystemCell.h"

#import "ResolutionAction.h"

#import "InboxResolutionCenterObjectMapping.h"

#define TAG_ALERT_CANCEL_COMPLAIN 10

@interface ResolutionCenterDetailViewController () <UITableViewDelegate, UITableViewDataSource, ResolutionCenterDetailCellDelegate, UIAlertViewDelegate, ResolutionCenterSystemCellDelegate>
{
    BOOL _isNodata;
    NSMutableArray *_listResolutionConversation;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectManagerCancelComplain;
    __weak RKManagedObjectRequestOperation *_requestCancelComplain;
    
    InboxResolutionCenterObjectMapping *_mapping;
    
    ResolutionDetailConversation *_resolutionDetail;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UITableViewCell *loadMoreCell;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *buyerThumbView;
@property (weak, nonatomic) IBOutlet UIButton *inputConversation;

@end

@implementation ResolutionCenterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isNodata = YES;
    
    _operationQueue = [NSOperationQueue new];
    _mapping = [InboxResolutionCenterObjectMapping new];
    _listResolutionConversation = [NSMutableArray new];
    
    _tableView.tableHeaderView = _headerView;
    
    NSString *creatorDispute = (_resolution.resolution_detail.resolution_by.by_seller == 1)?_resolution.resolution_detail.resolution_shop.shop_name:_resolution.resolution_detail.resolution_customer.customer_name;
    
    _usernameLabel.text = creatorDispute;
    _dateTimeLabel.text = _resolution.resolution_detail.resolution_dispute.dispute_create_time;
    _invoiceLabel.text = _resolution.resolution_detail.resolution_order.order_invoice_ref_num;
    
    NSString *imageURLString = (_resolution.resolution_detail.resolution_by.by_seller == 1)?_resolution.resolution_detail.resolution_shop.shop_image:_resolution.resolution_detail.resolution_customer.customer_image;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURLString]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _buyerThumbView;
    thumb.image = nil;
    UIImage *placeholderImage = (_resolution.resolution_detail.resolution_by.by_seller == 1)?[UIImage imageNamed:@"icon_profile_picture.jpeg"]:[UIImage imageNamed:@"icon_default_shop.jpg"];
    
    [thumb setImageWithURLRequest:request
                 placeholderImage:placeholderImage
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                          }];
    
    _buyerSellerLabel.text = (_resolution.resolution_detail.resolution_by.by_seller == 1)?@"Penjual":@"Pembeli";
    _buyerSellerLabel.backgroundColor = (_resolution.resolution_detail.resolution_by.by_seller == 1)?COLOR_SELLER:COLOR_BUYER;
   
    [self configureRestKit];
    [self requestWithAction:ACTION_GET_RESOLUTION_CENTER_DETAIL];
    
    _inputConversation.layer.cornerRadius = 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNodata ? 0 : _listResolutionConversation.count;
}
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button == _loadMoreButton) {
        _objectManager = nil;
        [self configureRestkitConversation];
        [self requestWithAction:ACTION_GET_RESOLUTION_CENTER_DETAIL_LOAD_MORE];
    }
    if (button == _inputConversation) {
        
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    if (conversation.view_more == 1)
    {
        cell = _loadMoreCell;
        NSString *buttonLoadMoreTitle = [NSString stringWithFormat:@"Lihat %@ Pesan Sebelumnya",conversation.left_count?:@"0"];
        [_loadMoreButton setTitle:buttonLoadMoreTitle forState:UIControlStateNormal];
    }
    else if (conversation.system_flag == 1 && ![conversation.user_name isEqualToString:@"Admin Tokopedia"])
        cell = [self cellSystemResolutionAtIndexPath:indexPath];
    else
        cell = [self cellDetailResolutionAtIndexPath:indexPath];

    return cell;
}

#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_ALERT_CANCEL_COMPLAIN:
        {
            if (buttonIndex == 1) {
                //TODO:: Delegate
                [_delegate shouldCancelComplain:_resolution atIndexPath:_indexPath];
                [self.navigationController popViewControllerAnimated:YES];
                //[self configureRestKitCancelComplain];
                //[self requestWithActionCancelComplain:_resolution.resolution_last.last_resolution_id];
            }
        }
            break;
            
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    if (conversation.view_more == 1)
        cell = _loadMoreCell;
    else if (conversation.system_flag == 1 && ![conversation.user_name isEqualToString:@"Admin Tokopedia"])
    {
        cell = [self cellSystemResolutionAtIndexPath:indexPath];
    }
    else
        cell = [self cellDetailResolutionAtIndexPath:indexPath];
    
    NSInteger deltaHeightCell = 5;
    NSInteger rowHeight;
    NSInteger cellRowHeight = 140;
    NSInteger attachmentHeight = 104;
    
    if ([cell isKindOfClass:[ResolutionCenterDetailCell class]])
    {
        ResolutionCenterDetailCell *cellResolution = (ResolutionCenterDetailCell*)cell;
        
        rowHeight = cellRowHeight + deltaHeightCell;
        
        if ([self isShowOneButton:conversation atIndexPath:indexPath] || [self isShowTwoButton:conversation]) {
            rowHeight = cellRowHeight + cellResolution.oneButtonView.frame.size.height + deltaHeightCell;
        }
        if ([self isShowAttachment:conversation]) {
            rowHeight = cellRowHeight + attachmentHeight + deltaHeightCell;
        }
        if ([self isShowAttachmentWithButton:conversation]) {
            rowHeight = cellRowHeight + attachmentHeight + cellResolution.oneButtonView.frame.size.height + deltaHeightCell;
        }
        if ([cellResolution.markLabel.text isEqualToString:@""]) {
            rowHeight = rowHeight - 78;
        }
    }
    else if ([cell isKindOfClass:[ResolutionCenterSystemCell class]])
    {
        ResolutionCenterSystemCell *cellResolution = (ResolutionCenterSystemCell*)cell;
        
        if ([self isShowTrackAndEditButton:conversation]) {
            rowHeight = cellResolution.frame.size.height + cellResolution.twoButtonView.frame.size.height + deltaHeightCell;
        }
    }
    else
    {
        rowHeight = _loadMoreCell.frame.size.height;
    }
    
    return rowHeight;
}

#pragma mark - Cell Delegate
-(void)tapCellButton:(UIButton *)sender atIndexPath:(NSIndexPath *)indexPath
{
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    switch (sender.tag) {
        case 10:
            if ([self isShowCancelComplainButton:conversation] && indexPath.row == 0) {
                UIAlertView *cancelComplainAlert = [[UIAlertView alloc]initWithTitle:@"Konfirmasi Pembatalan Komplain" message:@"Apakah Anda yakin ingin membatalkan komplain ini?\nTransaksi akan dinyatakan selesai dan seluruh dana pembayaran akan diteruskan kepada penjual." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya", nil];
                cancelComplainAlert.tag = TAG_ALERT_CANCEL_COMPLAIN;
                [cancelComplainAlert show];
            }
            break;
        case 11:
            if ([self isShowTrackAndEditButton:conversation]) {
              //Track
                TrackOrderViewController *vc = [TrackOrderViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 12:
            
            break;
        default:
            break;
    }
}


#pragma mark - Table View Cell

-(UITableViewCell *)cellSystemResolutionAtIndexPath:(NSIndexPath*)indexPath
{
    ResolutionCenterSystemCell *cell = nil;
    NSString *cellID = RESOLUTION_CENTER_SYSTEM_CELL_IDENTIFIER;
    
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    
    cell = (ResolutionCenterSystemCell*)[_tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [ResolutionCenterSystemCell newCell];
        cell.delegate = self;
    }
    [self AdjustActionByLabel:cell.buyerSellerLabel conversation:conversation];
    
    cell.markLabel.text = [self mark:conversation];
    
    [cell hideAllViews];
    if ([self isShowTwoButton:conversation])
    {
        cell.twoButtonView.hidden = NO;
    }
    [cell.markLabel multipleLineLabel:cell.markLabel];
    
    return cell;
}

-(UITableViewCell *)cellDetailResolutionAtIndexPath:(NSIndexPath*)indexPath
{
    ResolutionCenterDetailCell* cell = nil;
    NSString *cellID = RESOLUTION_CENTER_DETAIL_CELL_IDENTIFIER;
    
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    
    cell = (ResolutionCenterDetailCell*)[_tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [ResolutionCenterDetailCell newCell];
        cell.delegate = self;
    }
    
    cell.buyerNameLabel.text = conversation.user_name;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setDateFormat:@"yyyy-mm-ddTHH:mm:ssZ"];
    NSDate *createDate = [formatter dateFromString:conversation.time_ago];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:createDate];
    //cell.timeRemainingLabel.text = [[NSDate date] timeIntervalSinceDate:conversation.create_time_wib];
    NSLog(@"Time taken: %f", interval);
    cell.markLabel.text = [self mark:conversation];
    
    
    [self AdjustActionByLabel:cell.buyerSellerLabel conversation:conversation];
    [cell.markLabel multipleLineLabel:cell.markLabel];
    
    if (conversation.system_flag == 1) {
        //TODO:: yellow background
        //cell.backgroundColor = [UIColor yellowColor];
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:conversation.user_img] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.buyerProfileImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    [cell hideAllViews];
    if ([self isShowAttachment:conversation]) {
        [self adjustAttachmentCell:cell conversation:conversation];
        cell.markAttachmentLabel.text = conversation.remark;
        [cell.markAttachmentLabel multipleLineLabel:cell.markAttachmentLabel];
        cell.atachmentView.hidden = NO;
        cell.isShowAttachment = YES;
    }
    if ([self isShowTwoButton:conversation])
    {
        cell.twoButtonView.hidden = NO;
    }
    else if ([self isShowOneButton:conversation atIndexPath:indexPath])
    {
        cell.oneButtonView.hidden = NO;
        UIImage *btnImage;
        if ([self isShowCancelComplainButton:conversation]) {
            [cell.oneButton setTitle:@"Batalkan Komplain" forState:UIControlStateNormal];
            btnImage = [UIImage imageNamed:@"icon_cancel_grey.png"];
            [cell.oneButton setImage:btnImage forState:UIControlStateNormal];
        }
        cell.isShowAttachment = [self isShowAttachment:conversation];
    }
    
    if ([cell.markLabel.text isEqualToString:@""]) {
        cell.isMark = NO;
        CGRect frame = cell.markView.frame;
        frame.size.height = 0;
        cell.markView.frame = frame;
    }
    
    cell.indexPath = indexPath;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Methods


-(void)AdjustActionByLabel:(UILabel*)actionByLabel conversation:(ResolutionConversation*)conversation
{
    NSString *actionByString;
    UIColor *actionByBgColor;
    
    if(conversation.action_by == ACTION_BY_BUYER)
    {
        actionByString = @"Pembeli";
        actionByBgColor = COLOR_BUYER;
    }
    else if(conversation.action_by == ACTION_BY_SELLER)
    {
        actionByString = @"Penjual";
        actionByBgColor = COLOR_SELLER;
    }
    else if(conversation.action_by == ACTION_BY_TOKOPEDIA)
    {
        actionByString = @"Tokopedia";
        actionByBgColor = COLOR_TOKOPEDIA;
    }
    
    actionByLabel.backgroundColor = actionByBgColor;
    actionByLabel.text = actionByString;
}

-(NSString *)mark:(ResolutionConversation*)conversation
{
    NSMutableArray *marks= [NSMutableArray new];
    if (conversation.solution_flag==1)
    {
        [marks addObject:[self problemAndSolutionString:conversation]];
    }
    
    if (![self isShowAttachment:conversation]) {
        [marks addObject:conversation.remark_str];
    }
    
    if ([conversation.remark isEqualToString:@"INPUT_RESI_RESOLUTION_BY_BUYER"]) {
        [marks addObject:[NSString stringWithFormat:@"Nomor Resi :%@ (%@)",conversation.input_resi,conversation.kurir_name]];
    }
    else if([conversation.remark isEqualToString:@"RESOLUTION_CS_FINAL_ANSWER_RETUR"])
    {
    }
    
    NSString *markString = [[marks valueForKey:@"description"] componentsJoinedByString:@"\n"];
    return markString;
}

-(NSString *)problemAndSolutionString:(ResolutionConversation*)conversation
{
    NSInteger lastSolutionType = [conversation.solution integerValue];
    NSString *solutionString;
    if (lastSolutionType == SOLUTION_REFUND) {
        solutionString = [NSString stringWithFormat:@"Pembelian dana kepada pembeli sebesar %@",conversation.refund_amt_idr];
    }
    else if (lastSolutionType == SOLUTION_RETUR) {
        solutionString = [NSString stringWithFormat:@"Tukar barang sesuai pesanan"];
    }
    else if (lastSolutionType == SOLUTION_RETUR_REFUND) {
        solutionString = [NSString stringWithFormat:@"Pembelian barang dan dana sebesar %@",conversation.refund_amt_idr];
    }
    else if (lastSolutionType == SOLUTION_SELLER_WIN) {
        solutionString = [NSString stringWithFormat:@"Pengembalian dana penuh"];
    }
    else if (lastSolutionType == SOLUTION_SEND_REMAINING) {
        solutionString = [NSString stringWithFormat:@"Kirimkan sisanya"];
    }
    
    NSInteger troubleType = [conversation.trouble_type integerValue];
    NSString *troubleString;
    if (conversation.flag_received) {
        if (troubleType == TROUBLE_DIFF_DESCRIPTION) {
            troubleString = ARRAY_PROBLEM_COMPLAIN[0];
        }
        else if (troubleType == TROUBLE_BROKEN) {
            troubleString = ARRAY_PROBLEM_COMPLAIN[1];
        }
        else if (troubleType == TROUBLE_DIFF_QUANTITY) {
            troubleString = ARRAY_PROBLEM_COMPLAIN[2];
        }
        else if (troubleType == TROUBLE_DIFF_CARRIER) {
            troubleString = ARRAY_PROBLEM_COMPLAIN[3];
        }
    }
    else{
        troubleString = @"Produk tidak diterima";
    }
    
    return [NSString stringWithFormat:@"%@\nSolusi : %@",troubleString,solutionString];
}

-(void)adjustAttachmentCell:(ResolutionCenterDetailCell*)cell conversation:(ResolutionConversation*)conversation
{
    if (conversation.attachment.count > 0) {
        NSInteger attachmentCount = (conversation.attachment.count>=5)?5:conversation.attachment.count;
        for (int i = 0; i<attachmentCount; i++)
        {
            ResolutionAttachment *attachment = conversation.attachment[i];
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:attachment.file_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = cell.attachmentImages[i];
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
#pragma clang diagnosti c pop
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
        }
    }
}

-(BOOL)isShowAttachment:(ResolutionConversation*)conversation
{
    if (conversation.attachment.count>0) {
        
        return YES;
    }
    return NO;
}

-(BOOL)isShowAttachmentWithButton:(ResolutionConversation*)conversation
{
    if ([self isShowAttachment:conversation] &&
        [self isShowCancelComplainButton:conversation])
    {
        return YES;
    }
    return NO;
}


-(BOOL)isShowCancelComplainButton:(ResolutionConversation*)conversation
{
    if (_resolutionDetail.resolution_button.button_cancel == 1) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowTrackAndEditButton:(ResolutionConversation*)conversation
{
    if (conversation.show_track_button == 1 &&
        conversation.show_edit_resi_button == 1) {
        return YES;
    }
    return NO;
}

-(BOOL)noExpandedViewCell:(ResolutionConversation*)resolution
{
    if (![self isShowAttachment:resolution]&&
        ![self isShowAttachmentWithButton:resolution]&&
        ![self isShowCancelComplainButton:resolution]) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowOneButton:(ResolutionConversation*)conversation atIndexPath:(NSIndexPath*)indexPath
{
    if ([self isShowCancelComplainButton:conversation] && indexPath.row == 0) {
        return YES;
    }
    return NO;
}

-(BOOL)isShowTwoButton:(ResolutionConversation*)conversation
{
    if ([self isShowTrackAndEditButton:conversation]) {
        return YES;
    }
    return NO;
}

#pragma mark - Request
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

-(void)configureRestKit
{
    _objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ResolutionCenterDetail class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ResolutionCenterDetailResult class]];
    
    RKObjectMapping *resolutionDetailMapping = [RKObjectMapping mappingForClass:[ResolutionDetailConversation class]];
    [resolutionDetailMapping addAttributeMappingsFromArray:@[API_FLAG_CAN_CONVERSATION_KEY,
                                                 API_RESOLUTION_CONFERSATION_COUNT_KEY,
                                                             //API_RESOLUTION_BUTTON_KEY
                                                ]];
    
    RKObjectMapping *resolutionLastMapping = [_mapping resolutionLastMapping];
    RKObjectMapping *resolutionOrderMapping = [_mapping resolutionOrderMapping];
    RKObjectMapping *resolutionButtonMapping = [_mapping resolutionButtonMapping];
    RKObjectMapping *resolutionByMapping = [_mapping resolutionByMapping];
    RKObjectMapping *resolutionShopMapping = [_mapping resolutionShopMapping];
    RKObjectMapping *resolutionCustomerMapping = [_mapping resolutionCustomerMapping];
    RKObjectMapping *resolutionDisputeMapping = [_mapping resolutionDisputeMapping];
    RKObjectMapping *resolutionConversationMapping = [_mapping resolutionConversationMapping];
    RKObjectMapping *resolutionAttachmentMapping = [_mapping resolutionAttachmentMapping];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    
    RKRelationshipMapping *resolutionDetailRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_DETAIL_CONVERSATION_KEY
                                                                                             toKeyPath:API_RESOLUTION_DETAIL_CONVERSATION_KEY
                                                                                           withMapping:resolutionDetailMapping];
    
    RKRelationshipMapping *resolutionAttachmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_ATTACHMENT_KEY
                                                                                             toKeyPath:API_RESOLUTION_ATTACHMENT_KEY
                                                                                           withMapping:resolutionAttachmentMapping];
    
    RKRelationshipMapping *resolutionLastRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_LAST_KEY
                                                                                           toKeyPath:API_RESOLUTION_LAST_KEY
                                                                                         withMapping:resolutionLastMapping];
    
    RKRelationshipMapping *resolutionButtonRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_BUTTON_KEY
                                                                                             toKeyPath:API_RESOLUTION_BUTTON_KEY
                                                                                           withMapping:resolutionButtonMapping];
    
    RKRelationshipMapping *resolutionOrderRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_ORDER_KEY
                                                                                            toKeyPath:API_RESOLUTION_ORDER_KEY
                                                                                          withMapping:resolutionOrderMapping];
    
    RKRelationshipMapping *resolutionByRel= [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_BY_KEY
                                                                                        toKeyPath:API_RESOLUTION_BY_KEY
                                                                                      withMapping:resolutionByMapping];
    
    RKRelationshipMapping *resolutionShopRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_SHOP_KEY
                                                                                           toKeyPath:API_RESOLUTION_SHOP_KEY
                                                                                         withMapping:resolutionShopMapping];
    
    RKRelationshipMapping *resolutionConversationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_CONVERSATION_KEY
                                                                                           toKeyPath:API_RESOLUTION_CONVERSATION_KEY
                                                                                         withMapping:resolutionConversationMapping];
    
    RKRelationshipMapping *resolutionCustomerRel= [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_CUSTOMER_KEY
                                                                                              toKeyPath:API_RESOLUTION_CUSTOMER_KEY
                                                                                            withMapping:resolutionCustomerMapping];
    
    RKRelationshipMapping *resolutionDisputeRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_DISPUTE_KEY
                                                                                              toKeyPath:API_RESOLUTION_DISPUTE_KEY
                                                                                            withMapping:resolutionDisputeMapping];
    
    
    [statusMapping addPropertyMapping:resultRel];
    
    [resultMapping addPropertyMapping:resolutionDetailRel];
    
    [resolutionDetailMapping addPropertyMapping:resolutionLastRel];
    [resolutionDetailMapping addPropertyMapping:resolutionButtonRel];
    [resolutionDetailMapping addPropertyMapping:resolutionOrderRel];
    [resolutionDetailMapping addPropertyMapping:resolutionByRel];
    [resolutionDetailMapping addPropertyMapping:resolutionShopRel];
    [resolutionDetailMapping addPropertyMapping:resolutionCustomerRel];
    [resolutionDetailMapping addPropertyMapping:resolutionDisputeRel];
    [resolutionDetailMapping addPropertyMapping:resolutionConversationRel];
    [resolutionConversationMapping addPropertyMapping:resolutionAttachmentRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_INBOX_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

-(void)configureRestkitConversation
{
    _objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ResolutionCenterDetail class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ResolutionCenterDetailResult class]];
    
    RKObjectMapping *resolutionConversationMapping = [_mapping resolutionConversationMapping];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
        RKRelationshipMapping *resolutionConversationRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_CONVERSATION_KEY
                                                                                                   toKeyPath:API_RESOLUTION_CONVERSATION_KEY
                                                                                                 withMapping:resolutionConversationMapping];
    
    [statusMapping addPropertyMapping:resultRel];
    [resultMapping addPropertyMapping:resolutionConversationRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_INBOX_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

-(void)requestWithAction:(NSString*)action
{
    if (_request.isExecuting) return;
    NSTimer *timer;
    
    NSString *startTime = @"";
    NSString *lastTime = @"";
    
    if ([action isEqualToString:ACTION_GET_RESOLUTION_CENTER_DETAIL_LOAD_MORE]) {
        startTime = ((ResolutionConversation*)_listResolutionConversation[0]).create_time?:@"";
        lastTime = ((ResolutionConversation*)[_listResolutionConversation lastObject]).create_time?:@"";
    }
    
    NSDictionary* param = @{API_ACTION_KEY : action,
                            API_RESOLUTION_ID_KEY : _resolution.resolution_detail.resolution_last.last_resolution_id?:@"",
                            API_START_UPDATE_TIME_KEY :startTime,
                            API_LAST_UPDATE_TIME_KEY :lastTime
                            };
    
    _tableView.tableFooterView = _footerView;
    [_act startAnimating];
    
    _loadMoreButton.enabled = NO;
    
#if DEBUG
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID forKey:kTKPD_USERIDKEY];
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_INBOX_RESOLUTION_CENTER parameters:paramDictionary];
#else
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_INBOX_RESOLUTION_CENTER parameters:[param encrypt]];
#endif
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation withAction:action];
        _loadMoreButton.enabled = YES;
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailure:error withAction:action];
        _loadMoreButton.enabled = YES;
        [timer invalidate];
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation withAction:(NSString*)action
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ResolutionCenterDetail *resolution = stat;
    BOOL status = [resolution.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object withAction:action];
    }
}

-(void)requestFailure:(id)object withAction:(NSString*)action
{
    [self requestProcess:object withAction:action];
}

-(void)requestProcess:(id)object withAction:(NSString*)action
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ResolutionCenterDetail *resolution = stat;

            if(resolution.message_error)
            {
                NSArray *array = resolution.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
            }
            else{
                
                if ([action isEqualToString:ACTION_GET_RESOLUTION_CENTER_DETAIL]) {
                    _resolutionDetail = resolution.result.detail;
                    [_listResolutionConversation addObjectsFromArray:resolution.result.detail.resolution_conversation];
                }
                else
                {
                    ResolutionConversation *firstConversation = [_listResolutionConversation firstObject];
                    ResolutionConversation *lastConversation = [_listResolutionConversation lastObject];
                    [_listResolutionConversation removeAllObjects];
                    [_listResolutionConversation addObject:firstConversation];
                    [_listResolutionConversation addObjectsFromArray:resolution.result.resolution_conversation];
                    [_listResolutionConversation addObject:lastConversation];
                }
                
                if (_listResolutionConversation.count >0) {
                    _isNodata = NO;
                }

                [_tableView reloadData];
            }
        }
        else{
            
            [self cancel];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

@end
