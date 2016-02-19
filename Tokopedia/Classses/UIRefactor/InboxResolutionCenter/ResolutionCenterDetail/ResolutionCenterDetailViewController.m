//
//  ResolutionCenterDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "ReputationDetail.h"
#import "ResolutionCenterDetailViewController.h"
#import "ResolutionCenterInputViewController.h"
#import "ResolutionInputReceiptViewController.h"
#import "InboxResolutionCenterOpenViewController.h"
#import "InboxResolutionCenterComplainViewController.h"
#import "ShopReputation.h"

#import "NavigateViewController.h"
#import "NavigationHelper.h"

#import "TrackOrderViewController.h"

#import "ResolutionCenterDetailCell.h"
#import "ResolutionCenterSystemCell.h"

#import "ResolutionAction.h"
#import "InboxResolutionCenterObjectMapping.h"

#import "TxOrderStatusDetailViewController.h"

#import "TokopediaNetworkManager.h"

#import "RequestResolutionCenter.h"

#import "SettingAddressViewController.h"
#import "SettingAddressEditViewController.h"

#import "profile.h"
#import "string_settings.h"
#import "AddressFormList.h"
#import "RequestResoInputAddress.h"

#define TAG_ALERT_CANCEL_COMPLAIN 10
#define TAG_CHANGE_SOLUTION 11
#define DATA_SELECTED_SHIPMENT_KEY @"data_selected_shipment"

#define BUTTON_TITLE_ACCEPT_SOLUTION  @"Terima Solusi"
#define BUTTON_TITLE_EDIT_ADDRESS  @"Ubah Alamat"
#define BUTTON_TITLE_APPEAL  @"Naik Banding"
#define BUTTON_TITLE_ACCEPT_ADMIN_SOLUTION @"Terima Solusi Admin"
#define BUTTON_TITLE_INPUT_ADDRESS @"Masukkan Alamat"
#define BUTTON_TITLE_INPUT_RESI @"Masukkan No. Resi"
#define BUTTON_TITLE_EDIT_RESI @"Ubah No. Resi"
#define BUTTON_TITLE_FINISH_COMPLAIN @"Komplain Selesai"
#define BUTTON_TITLE_TRACK @"Lacak"
#define BUTTON_TITLE_CANCEL_COMPLAIN @"Batalkan Komplain"

#define CELL_SYSTEM_HEIGHT 158
#define CELL_DETAIL_HEIGHT 140
#define VIEW_ATTACHMENT_HEIGHT 104
#define VIEW_MARK_HEIGHT 78

@interface ResolutionCenterDetailViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ResolutionCenterDetailCellDelegate,
    UIAlertViewDelegate,
    ResolutionCenterSystemCellDelegate,
    ResolutionCenterInputViewControllerDelegate,
    ResolutionInputReceiptViewControllerDelegate,
    InboxResolutionCenterOpenViewControllerDelegate,
    TokopediaNetworkManagerDelegate,
    RequestResolutionCenterDelegate,
    UISplitViewControllerDelegate,
    SettingAddressViewControllerDelegate,
    SettingAddressEditViewControllerDelegate,
    addressDelegate
>
{
    BOOL _isNodata;
    
    NSMutableArray *_listResolutionConversation;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerEditReceipt;
    __weak RKManagedObjectRequestOperation *_requestEditReceipt;
    
    __weak RKObjectManager *_objectManagerReplay;
    __weak RKManagedObjectRequestOperation *_requestReplay;
    
    __weak RKObjectManager *_objectManagerAction;
    __weak RKManagedObjectRequestOperation *_requestAction;
    
    InboxResolutionCenterObjectMapping *_mapping;
    
    ResolutionDetailConversation *_resolutionDetail;
    
    NSMutableDictionary *_dataInput;
    
    ResolutionConversation *_addedLastConversation;
    
    NavigateViewController *_navigate;
    
    TokopediaNetworkManager *_networkManager;
    
    NSString *_actionRequest;
    
    RequestResolutionCenter *_requestResolutionCenter;
    
    GeneratedHost *_generatedHost;
    AddressFormList *_selectedAddress;
    RequestResoInputAddress *_requestInputAddress;
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
@property (weak, nonatomic) IBOutlet UIView *replayConversationView;
@property (strong, nonatomic) IBOutlet UIView *headerInfoView;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation ResolutionCenterDetailViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isNodata = YES;
    
    _operationQueue = [NSOperationQueue new];
    _mapping = [InboxResolutionCenterObjectMapping new];
    _listResolutionConversation = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _navigate = [NavigateViewController new];
    _requestInputAddress = [RequestResoInputAddress new];
    _requestInputAddress.delegate = self;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
   
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone  || _isNeedRequestListDetail) {
        [self requestWithAction:ACTION_GET_RESOLUTION_CENTER_DETAIL];
    }
    
    _inputConversation.layer.cornerRadius = 2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    _tableView.estimatedRowHeight = 100.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
}


- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}


-(void)setHeaderData
{
    NSString *creatorDispute = _resolutionDetail.resolution_customer.customer_name;//(_resolutionDetail.resolution_by.by_customer == 1)?_resolutionDetail.resolution_shop.shop_name:_resolutionDetail.resolution_customer.customer_name;
    
    _usernameLabel.text = creatorDispute;
    _dateTimeLabel.text = _resolutionDetail.resolution_dispute.dispute_create_time;
    _invoiceLabel.text = _resolutionDetail.resolution_order.order_invoice_ref_num;
    [btnReputation setTitle:_resolutionDetail.resolution_customer.customer_reputation.positive_percentage forState:UIControlStateNormal];
    
    NSString *imageURLString = imageURLString = _resolutionDetail.resolution_customer.customer_image;//(_resolutionDetail.resolution_by.by_customer == 1)?_resolutionDetail.resolution_shop.shop_image:_resolutionDetail.resolution_customer.customer_image;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURLString]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _buyerThumbView;
    thumb.image = nil;
    NSString *placeholderImageName = @"icon_profile_picture.jpeg";
    //if (_resolutionDetail.resolution_by.by_seller == 1)
    //    placeholderImageName = @"icon_default_shop.jpg";
    //else placeholderImageName = @"icon_profile_picture.jpeg";
    
    UIImage *placeholderImage = [UIImage imageNamed:placeholderImageName];
    
    [thumb setImageWithURLRequest:request
                 placeholderImage:placeholderImage
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              [thumb setImage:image];
#pragma clang diagnosti c pop
                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                          }];
    
    _buyerSellerLabel.text = @"Pembeli";//(_resolutionDetail.resolution_by.by_customer == 1)?@"Penjual":@"Pembeli";
    _buyerSellerLabel.backgroundColor = COLOR_BUYER;//(_resolutionDetail.resolution_by.by_customer == 1)?COLOR_SELLER:COLOR_BUYER;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Pusat Resolusi";
    _networkManager.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
    _networkManager.delegate = nil;
}


#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNodata ? 0 : _listResolutionConversation.count;
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
    else if ((conversation.system_flag == 1 && ![conversation.user_name isEqualToString:@"Admin Tokopedia"])||
             conversation.isAddedConversation)
        cell = [self cellSystemResolutionAtIndexPath:indexPath];
    else
        cell = [self cellDetailResolutionAtIndexPath:indexPath];
    
    if ([self isShowTrackAndEditButton:conversation]) {
        ShipmentCourier *selectedShipment = [ShipmentCourier new];
        selectedShipment.shipment_name = conversation.kurir_name;
        selectedShipment.shipment_id = conversation.input_kurir;
        [_dataInput setObject:selectedShipment forKey:DATA_SELECTED_SHIPMENT_KEY];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
        NSInteger rowHeight;
        NSInteger deltaHeightCell = 10;
        
        if (conversation.view_more == 1)
        {
            rowHeight = _loadMoreCell.frame.size.height;
        }
        else if (conversation.system_flag == 1 && ![conversation.user_name isEqualToString:@"Admin Tokopedia"])
        {
            NSInteger cellRowHeight = CELL_SYSTEM_HEIGHT;
            
            ResolutionCenterSystemCell *cell = (ResolutionCenterSystemCell*)[self cellSystemResolutionAtIndexPath:indexPath];
            
            cellRowHeight = [self calculateHeightForConfiguredSizingCell:cell];

            rowHeight = cellRowHeight - cell.twoButtonView.frame.size.height + deltaHeightCell;
            if ([self countShowButton:conversation atIndexPath:indexPath] > 0) {
                rowHeight = cellRowHeight + deltaHeightCell;
            }
        }
        else
        {
            ResolutionCenterDetailCell *cell = (ResolutionCenterDetailCell*)[self cellDetailResolutionAtIndexPath:indexPath];
            NSInteger cellRowHeight = CELL_DETAIL_HEIGHT;
            
            cellRowHeight = [self calculateHeightForConfiguredSizingCell:cell];
            
            rowHeight = cellRowHeight - VIEW_MARK_HEIGHT + deltaHeightCell;
            if ([self countShowButton:conversation atIndexPath:indexPath] > 0) {
                rowHeight = cellRowHeight + cell.oneButtonView.frame.size.height + deltaHeightCell;
            }
            if ([self isShowAttachment:conversation]) {
                rowHeight = cellRowHeight;
            }
            if ([self isShowAttachmentWithButton:conversation]) {
                rowHeight = cellRowHeight + cell.oneButtonView.frame.size.height;
            }
        }
        
        return rowHeight;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (button == _loadMoreButton) {
        [self requestWithAction:ACTION_GET_RESOLUTION_CENTER_DETAIL_LOAD_MORE];
    }
    if (button == _inputConversation) {
        ResolutionCenterInputViewController *vc = [ResolutionCenterInputViewController new];
        vc.resolution = _resolutionDetail;
        vc.lastSolution = [self solutionString:[_listResolutionConversation lastObject]];
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_ALERT_CANCEL_COMPLAIN:
        {
            if (buttonIndex == 1) {
                [_delegate shouldCancelComplain:_resolution atIndexPath:_indexPath];
                if ([_delegate isKindOfClass:[TxOrderStatusDetailViewController class]]) {
                    NSArray *viewControllers = self.navigationController.viewControllers;
                    UIViewController *destinationVC = viewControllers[viewControllers.count-3];
                    [self.navigationController popToViewController:destinationVC animated:YES];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];

                }
            }
        }
            break;
            
        case TAG_CHANGE_SOLUTION:
        {
            if (buttonIndex == 1) {
                [self resolutionOpenIsGotTheOrder:YES];
            }
            else
            {
                [self resolutionOpenIsGotTheOrder:NO];
            }
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Cell Delegate
-(void)tapCellButton:(UIButton *)sender atIndexPath:(NSIndexPath *)indexPath
{
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    switch (sender.tag) {
        case 10:
        case 11:
        case 12:
            [self didTapButton:sender Conversation:conversation];
            break;
        default:
            break;
    }
}

#pragma mark - Cell Delegate
-(void)didTapButton:(UIButton*)sender Conversation:(ResolutionConversation*)conversation
{
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_CANCEL_COMPLAIN]) {
        UIAlertView *cancelComplainAlert = [[UIAlertView alloc]initWithTitle:@"Konfirmasi Pembatalan Komplain" message:@"Apakah Anda yakin ingin membatalkan komplain ini?\nTransaksi akan dinyatakan selesai dan seluruh dana pembayaran akan diteruskan kepada penjual." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya", nil];
        cancelComplainAlert.tag = TAG_ALERT_CANCEL_COMPLAIN;
        [cancelComplainAlert show];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_TRACK]) {
        TrackOrderViewController *vc = [TrackOrderViewController new];
        vc.isShippingTracking = YES;
        vc.shipmentID = conversation.input_kurir;
        vc.shippingRef = conversation.input_resi;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_EDIT_RESI]) {
        ShipmentCourier *selectedShipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY]?:[ShipmentCourier new];
        ResolutionInputReceiptViewController *vc = [ResolutionInputReceiptViewController new];
        vc.action = ACTION_EDIT_RECEIPT;
        vc.delegate = self;
        vc.selectedShipment = selectedShipment;
        vc.conversation = conversation;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_INPUT_RESI]) {
        ShipmentCourier *selectedShipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY]?:[ShipmentCourier new];
        ResolutionInputReceiptViewController *vc = [ResolutionInputReceiptViewController new];
        vc.action = ACTION_INPUT_RECEIPT;
        vc.delegate = self;
        vc.selectedShipment = selectedShipment;
        vc.conversation = conversation;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_INPUT_ADDRESS]) {
        SettingAddressViewController *addressViewController = [SettingAddressViewController new];
        addressViewController.delegate = self;
        addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ADD_RESO),
                                       @"conversation" : conversation
                                       };
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_ACCEPT_ADMIN_SOLUTION]) {
        [self configureRestKitAction];
        [self requestAction:ACTION_ACCEPT_ADMIN_SOLUTION];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_EDIT_ADDRESS]) {
        SettingAddressViewController *addressViewController = [SettingAddressViewController new];
        addressViewController.delegate = self;
        addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_EDIT_RESO),
                                       @"conversation":conversation
                                       };
        [self.navigationController pushViewController:addressViewController animated:YES];
    }
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_ACCEPT_SOLUTION]) {
        [self configureRestKitAction];
        [self requestAction:ACTION_ACCEPT_SOLUTION];
    }
    
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_FINISH_COMPLAIN]) {
        [self configureRestKitAction];
        [self requestAction:ACTION_FINISH_RESOLUTION];
    }
    if ([sender.titleLabel.text isEqualToString:BUTTON_TITLE_APPEAL]) {
        BOOL isGotTheOrder = [_resolutionDetail.resolution_last.last_flag_received boolValue];
        
        //if (isGotTheOrder) {
            [self resolutionOpenIsGotTheOrder:isGotTheOrder];
        //}
        //else
        //{
        //    UIAlertView *alertChangeSolution = [[UIAlertView alloc]initWithTitle:@"Konfirmasi" message:@"Apakah barang telah diterima?\nAnda tidak bisa mengubah menjadi tidak terima barang, setelah Anda konfirmasi terima barang." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya",@"Tidak", nil];
        //    alertChangeSolution.tag = TAG_CHANGE_SOLUTION;
        //    [alertChangeSolution show];
        //}
    }
}

-(void)resolutionOpenIsGotTheOrder:(BOOL)isGotTheOrder
{
    InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
    vc.isGotTheOrder = isGotTheOrder;
    vc.isChangeSolution = YES;
    vc.detailOpenAmount = _resolutionDetail.resolution_order.order_open_amount;
    vc.detailOpenAmountIDR = _resolutionDetail.resolution_order.order_open_amount_idr;
    vc.shippingPriceIDR = _resolutionDetail.resolution_order.order_shipping_price_idr;
    vc.selectedProblem = [self trouble];
    vc.invoice = _resolutionDetail.resolution_order.order_invoice_ref_num;
    vc.delegate = self;
    vc.isCanEditProblem = NO;
    vc.controllerTitle = BUTTON_TITLE_APPEAL;
    NSString *totalRefund = [_resolutionDetail.resolution_last.last_refund_amt stringValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@"."];
    [formatter setGroupingSize:3];
    NSString *num = totalRefund;
    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
    totalRefund = str;
    vc.totalRefund = totalRefund;
    
    if (_resolutionDetail.resolution_by.by_customer == 1) {
        vc.shopName = _resolutionDetail.resolution_shop.shop_name;
        vc.shopPic = _resolutionDetail.resolution_shop.shop_image;
        vc.buyerSellerLabel.text = @"Pembelian dari";
    }
    if (_resolutionDetail.resolution_by.by_seller == 1) {
        vc.shopName = _resolutionDetail.resolution_customer.customer_name;
        vc.shopPic = _resolutionDetail.resolution_customer.customer_image;
        vc.buyerSellerLabel.text = @"Pembelian oleh";
        vc.isActionBySeller = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)goToShopOrProfileIndexPath:(NSIndexPath *)indexPath
{
    ResolutionConversation *conversation = _listResolutionConversation[indexPath.row];
    if(conversation.action_by == ACTION_BY_BUYER)
    {
        //profile
        NSArray *query = [[[NSURL URLWithString:conversation.user_url] path] componentsSeparatedByString: @"/"];
        [_navigate navigateToProfileFromViewController:self withUserID:[query objectAtIndex:2]?:@""];
    }
    else if(conversation.action_by == ACTION_BY_SELLER)
    {
        [_navigate navigateToProfileFromViewController:self withUserID:@""];
    }
    else if(conversation.action_by == ACTION_BY_TOKOPEDIA)
    {

    }
}

-(void)goToImageViewerImages:(NSArray *)images atIndexImage:(NSInteger)index atIndexPath:(NSIndexPath *)indexPath
{ 
    [_navigate navigateToShowImageFromViewController:self withImageDictionaries:images imageDescriptions:@[] indexImage:index];
}

-(void)changeSolution:(NSString *)solutionType troubleType:(NSString *)troubleType refundAmount:(NSString *)refundAmout remark:(NSString *)note photo:(NSString *)photo serverID:(NSString *)serverID isGotTheOrder:(BOOL)isGotTheOrder
{
    [self solutionType:solutionType troubleType:troubleType refundAmount:refundAmout message:note photo:photo serverID:serverID isGotTheOrder:isGotTheOrder];
}

-(NSString *)trouble
{
    NSString *trouble = _resolutionDetail.resolution_last.last_trouble_string?:@"";
//    if ([_resolutionDetail.resolution_last.last_trouble_type isEqual:@(1)]) {
//        trouble = ARRAY_PROBLEM_COMPLAIN[0];
//    }
//    else if ([_resolutionDetail.resolution_last.last_trouble_type isEqual:@(2)]) {
//        trouble = ARRAY_PROBLEM_COMPLAIN[1];
//    }
//    else if ([_resolutionDetail.resolution_last.last_trouble_type isEqual:@(3)]) {
//        trouble = ARRAY_PROBLEM_COMPLAIN[2];
//    }
//    else if ([_resolutionDetail.resolution_last.last_trouble_type isEqual:@(4)]) {
//        trouble = ARRAY_PROBLEM_COMPLAIN[3];
//    }
    return trouble;
}

-(NSString*)solution
{
    NSString *solution = _resolutionDetail.resolution_last.last_solution_string?:@"";
//    if ([_resolutionDetail.resolution_last.last_solution isEqual:@(1)]) {
//        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0];
//    }
//    else if ([_resolutionDetail.resolution_last.last_solution isEqual:@(2)]) {
//        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[1];
//    }
//    else if ([_resolutionDetail.resolution_last.last_solution isEqual:@(3)]) {
//        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2];
//    }
//    else if ([_resolutionDetail.resolution_last.last_solution isEqual:@(4)]) {
//        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[3];
//    }
    return solution;
}

#pragma mark - Resolution Input Receipt View Controller Delegate
- (void)receiptNumber:(NSString*)receiptNumber withShipmentAgent:(ShipmentCourier*)shipmentAgent withAction:(NSString *)action conversation:(ResolutionConversation*)conversation
{
    ShipmentCourier *selectedShipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY];
    if ([shipmentAgent.shipment_name isEqualToString:selectedShipment.shipment_name] &&
        [receiptNumber isEqualToString:conversation.input_resi]) {
    }
    else
    {
        [self configureRestKitEditReceipt];
        [self requestEditReceiptConversation:conversation
                           receiptNumber:receiptNumber
                       withShipmentAgent:shipmentAgent
                              withAction:action];
    }
}

#pragma mark - Resolution Center Input View Controller Delegate
-(void)appealSolution:(NSString *)solutionType refundAmount:(NSString *)refundAmout remark:(NSString *)message photo:(NSString *)photo serverID:(NSString *)serverID
{
    [self requestReplayConversation:message
                              photo:photo?:@""
                           serverID:serverID?:@""
                   editSolutionFlag:NO
                       solutionType:solutionType?:@""
                        troubleType:@""
                       refundAmount:refundAmout?:@""
                           received:([_resolutionDetail.resolution_last.last_flag_received isEqual:@(1)])
                             action:ACTION_APPEAL];
}

-(void)solutionType:(NSString *)solutionType troubleType:(NSString *)troubleType refundAmount:(NSString *)refundAmout message:(NSString *)message photo:(NSString *)photo serverID:(NSString *)serverID isGotTheOrder:(BOOL)isGotTheOrder
{
    [self requestReplayConversation:message?:@""
                              photo:photo?:@""
                           serverID:serverID?:@""
                   editSolutionFlag:YES
                       solutionType:solutionType?:@""
                        troubleType:troubleType?:@""
                       refundAmount:refundAmout?:@""
                           received:isGotTheOrder
                             action:ACTION_REPLY_CONVERSATION];
}

-(void)message:(NSString *)message photo:(NSString *)photo serverID:(NSString *)serverID
{
    [self requestReplayConversation:message?:@""
                              photo:photo?:@""
                           serverID:serverID?:@""
                   editSolutionFlag:NO
                       solutionType:@""
                        troubleType:@""
                       refundAmount:@""
                           received:([_resolutionDetail.resolution_last.last_flag_received isEqual:@(1)])
                             action:ACTION_REPLY_CONVERSATION];
}
-(void)setGenerateHost:(GeneratedHost *)generateHost
{
    _generatedHost = generateHost;
}

-(void)reportResolution
{
    [self configureRestKitAction];
    [self requestAction:ACTION_REPORT_RESOLUTION];
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
    [self adjustActionByLabel:cell.buyerSellerLabel conversation:conversation]; 
    
    if([conversation.show_edit_addr_button integerValue] != 1 && conversation.address)
    {
        cell.markLabel.textColor = COLOR_STATUS_DONE;
    }
    else
        cell.markLabel.textColor = [UIColor blackColor];
    cell.markLabel.text = [NSString convertHTML:[self markConversation:conversation]];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *date = [dateFormatter dateFromString:conversation.time_ago];
    NSString *sinceDateString = [NSString timeLeftSinceDate:date];
    ResolutionConversation *lastConversation = [_listResolutionConversation lastObject];
    cell.timeDateLabel.text = (lastConversation == _addedLastConversation)?_resolutionDetail.resolution_last.last_create_time_str:sinceDateString;
    
    [cell hideAllViews];

    
    UIColor *lastCellColour = [UIColor colorWithRed:255.f/255.f green:243.f/255.f blue:224.f/255.f alpha:1];
    UIColor *buttonCellColour = [UIColor colorWithRed:249.f/255.f green:249.f/255.f blue:249.f/255.f alpha:1];
    
    [cell.markLabel setCustomAttributedText:cell.markLabel.text];
    cell.indexPath = indexPath;
    

    if ([self countShowButton:conversation atIndexPath:indexPath] == 0) {
        cell.oneButtonConstraintHeight.constant = 0;
        cell.twoButtonConstraintHeight.constant = 0;
    }
    else {
        cell.oneButtonConstraintHeight.constant = 44;
        cell.twoButtonConstraintHeight.constant = 44;
        if ([self countShowButton:conversation atIndexPath:indexPath] == 2)
        {
            cell.twoButtonView.hidden = NO;
            [self adjustTwoButtonsTitleConversation:conversation cell:cell];
            
        }
        else if ([self countShowButton:conversation atIndexPath:indexPath] == 1)
        {
            cell.oneButtonView.hidden = NO;
            [self adjustOneButtonTitleConversation:conversation cell:cell];
        }
    }
    
    if (_listResolutionConversation.count>0)
    {
        if (indexPath.row == (_listResolutionConversation.count-1))
        {
            cell.titleView.backgroundColor = lastCellColour;
        }
        else
        {
            cell.titleView.backgroundColor = buttonCellColour;
        }
    }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *createDate = [formatter dateFromString:conversation.time_ago];
    NSString *sinceDateString = [NSString timeLeftSinceDate:createDate];
    cell.timeRemainingLabel.text = sinceDateString;
    cell.markLabel.text = [NSString convertHTML:[self markConversation:conversation]];

    [cell.btnReputation setTitle:_resolutionDetail.resolution_customer.customer_reputation.positive_percentage forState:UIControlStateNormal];
    
    [self adjustActionByLabel:cell.buyerSellerLabel conversation:conversation];
    [cell.markLabel setCustomAttributedText:cell.markLabel.text];
    
    //if (conversation.system_flag == 1) {
    //    //yellow background
    //    cell.markView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:194.0/255.0 alpha:1];
    //}
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:conversation.user_img] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.buyerProfileImageView;
    thumb.image = nil;
    
    UIImage *placeholderImage = (conversation.action_by == ACTION_BY_SELLER)?[UIImage imageNamed:@"icon_default_shop.jpg"]:[UIImage imageNamed:@"icon_profile_picture.jpeg"];
    
    [thumb setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    [cell hideAllViews];
    if ([self isShowAttachment:conversation]) {
        [self adjustAttachmentCell:cell conversation:conversation];
        cell.markAttachmentLabel.text = conversation.remark;
        [cell.markAttachmentLabel setCustomAttributedText:cell.markAttachmentLabel.text];
        cell.atachmentView.hidden = NO;
        cell.isShowAttachment = YES;
    }
    if ([self countShowButton:conversation atIndexPath:indexPath] == 2)
    {
        cell.twoButtonView.hidden = NO;
    }
    else if ([self countShowButton:conversation atIndexPath:indexPath] == 1)
    {
        cell.oneButtonView.hidden = NO;
        UIImage *btnImage;
        if ([self isShowCancelComplainButton:conversation]) {
            [cell.oneButton setTitle:BUTTON_TITLE_CANCEL_COMPLAIN forState:UIControlStateNormal];
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
    
    if ([self countShowButton:conversation atIndexPath:indexPath] == 0)
    {
        cell.twobuttonConstraintHeight.constant = 0;
        cell.oneButtonConstraintHeight.constant = 0;
    }
    else
    {
        cell.twobuttonConstraintHeight.constant = 44.0;
        cell.oneButtonConstraintHeight.constant = 44.0;
    }
    if (![self isShowAttachment:conversation]) {
        cell.imageConstraintHeight.constant = 0;
    }
    else
    {
        cell.imageConstraintHeight.constant = 74.0;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Methods

-(void)adjustTwoButtonsTitleConversation:(ResolutionConversation*)conversation cell:(ResolutionCenterSystemCell*)cell
{
    NSString *title1 = @"";
    NSString *title2 = @"";
    
    if (conversation.isAddedConversation)
    {
        if([_resolutionDetail.resolution_last.last_show_accept_button integerValue] == 1)
        {
            if ([title1 isEqualToString:@""])
                title1 = BUTTON_TITLE_ACCEPT_SOLUTION;
            else
                title2 = BUTTON_TITLE_ACCEPT_SOLUTION;
        }
        if([_resolutionDetail.resolution_last.last_show_appeal_button integerValue] == 1)
        {
            if ([title1 isEqualToString:@""])
                title1 = BUTTON_TITLE_APPEAL;
            else
                title2 = BUTTON_TITLE_APPEAL;
            if([_resolutionDetail.resolution_last.last_show_accept_admin_button integerValue] == 1)
            {
                if ([title1 isEqualToString:@""])
                    title1 = BUTTON_TITLE_ACCEPT_ADMIN_SOLUTION;
                else
                    title2 = BUTTON_TITLE_ACCEPT_ADMIN_SOLUTION;
            }
        }
        if([_resolutionDetail.resolution_last.last_show_input_addr_button integerValue] == 1)
        {
            if ([title1 isEqualToString:@""])
                title1 = BUTTON_TITLE_INPUT_ADDRESS;
            else
                title2 =BUTTON_TITLE_INPUT_ADDRESS;
        }
        if([_resolutionDetail.resolution_last.last_show_input_resi_button integerValue] == 1)
        {
            if ([title1 isEqualToString:@""])
                title1 = BUTTON_TITLE_INPUT_RESI;
            else
                title2 =BUTTON_TITLE_INPUT_RESI;
        }
        if([_resolutionDetail.resolution_last.last_show_finish_button integerValue] == 1)
        {
            if ([title1 isEqualToString:@""])
                title1 = BUTTON_TITLE_FINISH_COMPLAIN;
            else
                title2 = BUTTON_TITLE_FINISH_COMPLAIN;
        }
    }
    else
    {
        if ([self isShowTrackAndEditButton:conversation]) {
            title1 = BUTTON_TITLE_TRACK;
            title2 = BUTTON_TITLE_EDIT_RESI;
        }
    }
    
    [cell.twoButtons[0] setTitle:title1 forState:UIControlStateNormal];
    UIImage *btnImage = [UIImage imageNamed:[self imageNameAtTitleButton:title1]];
    [cell.oneButton setImage:btnImage forState:UIControlStateNormal];
    
    [cell.twoButtons[1] setTitle:title2 forState:UIControlStateNormal];
    btnImage = [UIImage imageNamed:[self imageNameAtTitleButton:title2]];
    [cell.oneButton setImage:btnImage forState:UIControlStateNormal];
}

-(void)adjustOneButtonTitleConversation:(ResolutionConversation*)conversation cell:(ResolutionCenterSystemCell*)cell
{
    NSString *buttonTitle = @"";
    
    if ([conversation.show_edit_addr_button integerValue]==1) {
        buttonTitle = BUTTON_TITLE_EDIT_ADDRESS;
    }
    
    if (conversation.isAddedConversation)
    {
        if([_resolutionDetail.resolution_last.last_show_accept_button integerValue] == 1)
        {
            buttonTitle = BUTTON_TITLE_ACCEPT_SOLUTION;
        }
        if([_resolutionDetail.resolution_last.last_show_appeal_button integerValue] == 1)
        {
            buttonTitle = BUTTON_TITLE_APPEAL;
        }
        if([_resolutionDetail.resolution_last.last_show_finish_button integerValue] == 1)
        {
            buttonTitle = BUTTON_TITLE_FINISH_COMPLAIN;
        }
        if([_resolutionDetail.resolution_last.last_show_input_resi_button integerValue] == 1)
        {
            buttonTitle = BUTTON_TITLE_INPUT_RESI;
        }
        if([_resolutionDetail.resolution_last.last_show_input_addr_button integerValue] == 1)
        {
            buttonTitle = BUTTON_TITLE_INPUT_ADDRESS;
        }
    }
    
    [cell.oneButton setTitle:buttonTitle forState:UIControlStateNormal];
    UIImage *btnImage = [UIImage imageNamed:[self imageNameAtTitleButton:buttonTitle]];
    [cell.oneButton setImage:btnImage forState:UIControlStateNormal];
}


-(void)adjustActionByLabel:(UILabel*)actionByLabel conversation:(ResolutionConversation*)conversation
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

-(void)adjustAttachmentCell:(ResolutionCenterDetailCell*)cell conversation:(ResolutionConversation*)conversation
{
    if (conversation.attachment.count > 0) {
        NSInteger attachmentCount = (conversation.attachment.count>=5)?5:conversation.attachment.count;
        for (int i = 0; i<attachmentCount; i++)
        {
            ResolutionAttachment *attachment = conversation.attachment[i];
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:attachment.real_file_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = cell.attachmentImages[i];
            thumb.image = nil;
            [thumb setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
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

-(BOOL)isNeedAddList
{
    if([_resolutionDetail.resolution_last.last_show_accept_button integerValue] == 1)
        return YES; //accept solution
    
    if([_resolutionDetail.resolution_last.last_show_appeal_button integerValue] == 1)
    {
        return YES; //appeal
        if([_resolutionDetail.resolution_last.last_show_accept_admin_button integerValue] == 1)
            return YES; //accept_solution
    }
    
    if([_resolutionDetail.resolution_last.last_show_finish_button integerValue] == 1)
        return YES; //finish complain
    if([_resolutionDetail.resolution_last.last_show_input_resi_button integerValue] == 1)
        return YES; //input resi
    if([_resolutionDetail.resolution_last.last_show_input_addr_button integerValue] == 1)
        return YES; //input address
    
    return NO;
}

-(BOOL)isShowRecievedSolutionButton:(ResolutionConversation*)conversation
{
    return conversation.isAddedConversation;
}

-(NSInteger)countShowButton:(ResolutionConversation*)conversation atIndexPath:(NSIndexPath*)indexPath
{
    int buttonCount = 0;
    
    if (([self isShowCancelComplainButton:conversation] && indexPath.row == 0)) {
       return 1;
    }
    if ([conversation.show_edit_addr_button integerValue]==1) {
        buttonCount +=1;
    }

    if (conversation.isAddedConversation) {
        if([_resolutionDetail.resolution_last.last_show_accept_button integerValue] == 1)
            buttonCount +=1;
        
        if([_resolutionDetail.resolution_last.last_show_appeal_button integerValue] == 1)
        {
            buttonCount +=1;
            if([_resolutionDetail.resolution_last.last_show_accept_admin_button integerValue] == 1)
                buttonCount +=1;
        }
        if([_resolutionDetail.resolution_last.last_show_finish_button integerValue] == 1)
            buttonCount +=1;
        if([_resolutionDetail.resolution_last.last_show_input_resi_button integerValue] == 1)
            buttonCount +=1;
        if([_resolutionDetail.resolution_last.last_show_input_addr_button integerValue] == 1)
            buttonCount +=1;
    }
    
    return buttonCount;
}

-(void)refreshRequest
{
    [self requestWithAction:ACTION_GET_RESOLUTION_CENTER_DETAIL];
}

#pragma mark - String

-(NSString *)markConversation:(ResolutionConversation*)conversation
{
    NSMutableArray *marks= [NSMutableArray new];
    if (conversation.solution_flag==1)
    {
        [marks addObject:[self problemAndSolutionConversation:conversation]];
    }
    
    [marks addObject:conversation.remark_str?:@""];
    
    if (conversation.input_resi) {
        [marks addObject:[NSString stringWithFormat:@"Nomor Resi : %@ (%@)",conversation.input_resi,conversation.kurir_name]];
    }
    
    NSString *markString = [[marks valueForKey:@"description"] componentsJoinedByString:@"\n"];
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [markString componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    markString = [filteredArray componentsJoinedByString:@" "];

    return markString;
}

-(NSString *)solutionString:(ResolutionConversation*)conversation
{
    NSString *solutionString = conversation.solution_string?:@"";
   
    return solutionString;
}

-(NSString *)problemAndSolutionConversation:(ResolutionConversation*)conversation
{
    NSString *solutionString = [self solutionString:conversation];
    NSString *troubleString = conversation.trouble_string?:@"";

    NSString *returnString;
    if ([troubleString isEqualToString:@""])
        returnString = [NSString stringWithFormat:@"Solusi terakhir yang ditawarkan :\n%@",solutionString];
    else
        returnString = [NSString stringWithFormat:@"%@\nSolusi : %@",troubleString,solutionString];
    
    return returnString;
}

-(NSString *)imageNameAtTitleButton:(NSString*)titleButton
{
    NSString *imageName = @"";
    
    if ([titleButton isEqualToString:BUTTON_TITLE_CANCEL_COMPLAIN]) {
        imageName = @"icon_order_cancel-01.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_TRACK]) {
        imageName = @"icon_track_grey.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_EDIT_RESI]) {
        imageName = @"icon_edit_grey.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_INPUT_RESI]) {
        imageName = @"icon_edit_grey.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_INPUT_ADDRESS]) {
        imageName = @"icon_edit_grey.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_ACCEPT_ADMIN_SOLUTION]) {
        imageName = @"icon_order_check-01.png";
    }
    if ([titleButton isEqualToString:BUTTON_TITLE_EDIT_ADDRESS]) {
        imageName = @"icon_edit_grey.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_ACCEPT_SOLUTION]) {
        imageName = @"icon_order_check-01.png";
    }
    
    if ([titleButton isEqualToString:BUTTON_TITLE_FINISH_COMPLAIN]) {
        imageName = @"icon_order_check-01.png";
    }
    if ([titleButton isEqualToString:BUTTON_TITLE_APPEAL]) {
        imageName = @"icon_order_cancel-01.png";
    }
    
    return imageName;
}

#pragma mark - Request
-(id)getObjectManager:(int)tag
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[ResolutionCenterDetail mapping]
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_INBOX_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    return objectManager;
}

-(NSString *)getPath:(int)tag
{
    return API_PATH_INBOX_RESOLUTION_CENTER;
}

-(NSDictionary *)getParameter:(int)tag
{
    NSString *startTime = @"";
    NSString *lastTime = @"";
    
    ResolutionConversation *lastConversation = [_listResolutionConversation lastObject]?:[ResolutionConversation new];
    if (lastConversation == _addedLastConversation) {
        lastConversation = _listResolutionConversation[_listResolutionConversation.count-2];
    }
    
    if ([_actionRequest isEqualToString:ACTION_GET_RESOLUTION_CENTER_DETAIL_LOAD_MORE]) {
        startTime = ((ResolutionConversation*)_listResolutionConversation[0]).create_time?:@"";
        lastTime = lastConversation.create_time?:@"";
    }
    
    NSDictionary* param = @{API_ACTION_KEY : _actionRequest,
                            API_RESOLUTION_ID_KEY : _resolutionID?:@"",
                            API_START_UPDATE_TIME_KEY :startTime,
                            API_LAST_UPDATE_TIME_KEY :lastTime
                            };
    
    return param;
}

-(void)actionBeforeRequest:(int)tag
{
    
    _tableView.tableFooterView = _footerView;
    [_act startAnimating];
    
    _loadMoreButton.enabled = NO;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    ResolutionCenterDetail *resolution = stat;
    
    return resolution.status;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    ResolutionCenterDetail *resolution = stat;
    
    if(resolution.message_error)
    {
        NSArray *array = resolution.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
        [alert show];
    }
    else{
        
        if ([_actionRequest isEqualToString:ACTION_GET_RESOLUTION_CENTER_DETAIL]) {
            
            [_listResolutionConversation removeAllObjects];
            _resolutionDetail = resolution.result.detail;
            [_listResolutionConversation addObjectsFromArray:resolution.result.detail.resolution_conversation];
            
            if (resolution.result.detail.resolution_can_conversation == 1) {
                _replayConversationView.hidden = NO;
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
            }
            else
            {
                _replayConversationView.hidden = YES;
                _tableView.contentInset = UIEdgeInsetsZero;
            }
            
            if (resolution.result.detail.resolution_can_conversation == 1) {
                _addedLastConversation = [ResolutionConversation new];
                _addedLastConversation.flag_received = [resolution.result.detail.resolution_last.last_flag_received integerValue];
                _addedLastConversation.system_flag = 1;
                _addedLastConversation.action_by = [resolution.result.detail.resolution_last.last_action_by integerValue];
                _addedLastConversation.solution = resolution.result.detail.resolution_last.last_solution;
                _addedLastConversation.solution_flag = 1;
                _addedLastConversation.isAddedConversation = [self isNeedAddList]?YES:NO;
                _addedLastConversation.trouble_type = @(0);
                _addedLastConversation.refund_amt_idr = resolution.result.detail.resolution_last.last_refund_amt_idr;
                _addedLastConversation.solution_string = resolution.result.detail.resolution_last.last_solution_string;
                _addedLastConversation.trouble_string = resolution.result.detail.resolution_last.last_trouble_string;
                [_listResolutionConversation addObject:_addedLastConversation];
            }
            
            _tableView.tableHeaderView = _headerView;
            [self setHeaderData];
        }
        else
        {
            ResolutionConversation *firstConversation = [_listResolutionConversation firstObject];
            ResolutionConversation *lastConversation = [_listResolutionConversation lastObject];
            if (lastConversation == _addedLastConversation) {
                lastConversation = _listResolutionConversation [_listResolutionConversation.count-2];
                [_listResolutionConversation removeAllObjects];
                [_listResolutionConversation addObject:firstConversation];
                [_listResolutionConversation addObjectsFromArray:resolution.result.resolution_conversation];
                [_listResolutionConversation addObject:lastConversation];
                [_listResolutionConversation addObject:_addedLastConversation];
            }
            else
            {
                [_listResolutionConversation removeAllObjects];
                [_listResolutionConversation addObject:firstConversation];
                [_listResolutionConversation addObjectsFromArray:resolution.result.resolution_conversation];
                [_listResolutionConversation addObject:lastConversation];
            }
        }
        
        if (_listResolutionConversation.count >0) {
            _isNodata = NO;
        }
        
        [_tableView reloadData];
    }
    _tableView.tableFooterView = nil;
    [_act stopAnimating];
    _loadMoreButton.enabled = YES;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _headerInfoView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (![_resolutionDetail.resolution_dispute.dispute_split_info isEqualToString:@"0"]) {
            [_infoLabel setCustomAttributedText:_resolutionDetail.resolution_dispute.dispute_split_info];
            return [self findHeightForText:_infoLabel.text havingWidth:_infoLabel.frame.size.width andFont:FONT_GOTHAM_BOOK_18].height;
        }
        return 0;
    }
    return 0;
}

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    _tableView.tableFooterView = nil;
    [_act stopAnimating];
}

-(void)requestWithAction:(NSString*)action
{
    _actionRequest = action;
    [_networkManager doRequest];
}


#pragma mark - Request Action
/**
 Help
 Finish Conversation
 Accept Solution
 Accept Admin Solution
 **/
-(void)cancelRequestAction
{
    [_requestAction cancel];
    _requestAction = nil;
    [_objectManagerAction.operationQueue cancelAllOperations];
    _objectManagerAction = nil;
}

-(void)configureRestKitAction
{
    _objectManagerAction = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ResolutionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ResolutionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    
    [statusMapping addPropertyMapping:resultRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerAction addResponseDescriptor:responseDescriptor];
}

-(void)requestAction:(NSString*)action
{
    if (_requestAction.isExecuting) return;
    
    NSTimer *timer;
    
    NSDictionary* param = @{API_ACTION_KEY : action,
                            API_RESOLUTION_ID_KEY : _resolutionID?:@"",
                            };
    
//#if DEBUG
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID forKey:kTKPD_USERIDKEY];
//    
//    _requestAction = [_objectManagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_RESOLUTION_CENTER parameters:paramDictionary];
//#else
    _requestAction = [_objectManagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_RESOLUTION_CENTER parameters:[param encrypt]];
//#endif
    
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessAction:action mappingResult:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionWithErrorMessage:@[error.localizedDescription]];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessAction:(NSString*)action mappingResult:(RKMappingResult*)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    ResolutionAction *resolution = stat;
    BOOL status = [resolution.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (resolution.result.is_success == 1) {
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:resolution.message_status?:@[@"Sukses"] delegate:self];
            [alert show];
            
            [self refreshRequest];
            
//            if ([action isEqualToString:ACTION_FINISH_RESOLUTION]||
//                [action isEqualToString:ACTION_ACCEPT_SOLUTION] ||
//                [action isEqualToString:ACTION_ACCEPT_ADMIN_SOLUTION] ) {
//                [_delegate finishComplain:_resolution atIndexPath:_indexPath];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
        }
        else
        {
            [self requestFailureActionWithErrorMessage:resolution.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
        }
    }
    else
    {
        [self requestFailureActionWithErrorMessage:@[resolution.status]];
    }
    
    [self requestProcessAction];
}

-(void)requestFailureActionWithErrorMessage:(NSArray*)error
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:error delegate:self];
    [alert show];
    
    [_tableView reloadData];
}

-(void)requestProcessAction
{
    
}

-(void)requestTimeoutAction
{
    [self cancelRequestAction];
}

#pragma mark - Request Edit And Input Receipt
-(void)cancelRequestEditReceipt
{
    [_requestEditReceipt cancel];
    _requestEditReceipt = nil;
    [_objectManagerEditReceipt.operationQueue cancelAllOperations];
    _objectManagerEditReceipt = nil;
}

-(void)configureRestKitEditReceipt
{
    _objectManagerEditReceipt = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ResolutionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ResolutionActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    
    [statusMapping addPropertyMapping:resultRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerEditReceipt addResponseDescriptor:responseDescriptor];
}

-(void)requestEditReceiptConversation:(ResolutionConversation*)conversation receiptNumber:(NSString *)receiptNumber withShipmentAgent:(ShipmentCourier*)shipment withAction:(NSString*)action
{
    if (_requestEditReceipt.isExecuting) return;
    
    NSTimer *timer;

    NSDictionary* param = @{API_ACTION_KEY : action?:@"",
                            API_RESOLUTION_ID_KEY : _resolutionID?:@"",
                            API_SHIPPING_REF_KEY : receiptNumber?:@"",
                            API_SHIPMENT_ID_KEY : shipment.shipment_id?:@"",
                            API_CONVERSATION_ID_KEY : conversation.conversation_id?:@""
                            };
    
//#if DEBUG
//    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
//    NSDictionary* auth = [secureStorage keychainDictionary];
//    
//    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
//    
//    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
//    [paramDictionary addEntriesFromDictionary:param];
//    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
//    [paramDictionary setObject:userID forKey:kTKPD_USERIDKEY];
//    
//    _requestEditReceipt = [_objectManagerEditReceipt appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:API_PATH_ACTION_RESOLUTION_CENTER parameters:paramDictionary];
//#else
    _requestEditReceipt = [_objectManagerEditReceipt appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_PATH_ACTION_RESOLUTION_CENTER parameters:[param encrypt]];
//#endif
    
    [_requestEditReceipt setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessEditReceipt:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureEditReceiptWithErrorMessage:@[error.localizedDescription]];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestEditReceipt];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutEditReceipt) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessEditReceipt:(RKMappingResult*)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    ResolutionAction *resolution = stat;
    BOOL status = [resolution.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (resolution.result.is_success == 1) {
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:resolution.message_status?:@[@"Sukses"] delegate:self];
            [alert show];
            
            [self refreshRequest];
        }
        else
        {
            [self requestFailureActionWithErrorMessage:resolution.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
        }
    }
    else
    {
        [self requestFailureEditReceiptWithErrorMessage:@[resolution.status]];
    }
    
    [self requestProcessEditReceipt];
}

-(void)requestFailureEditReceiptWithErrorMessage:(NSArray*)error
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:error delegate:self];
    [alert show];
    
    [_tableView reloadData];
}

-(void)requestProcessEditReceipt
{
    
}

-(void)requestTimeoutEditReceipt
{
    [self cancelRequestEditReceipt];
}

#pragma mark - Replay Conversation
-(void)requestReplayConversation:(NSString*)message photo:(NSString*)photo serverID:(NSString*)serverID editSolutionFlag:(BOOL)editSolutionFlag solutionType:(NSString*)solution troubleType:(NSString*)trouble refundAmount:(NSString*)refunAmount received:(BOOL)received action:(NSString*)action
{
    NSString *editSolutionFlagString = [NSString stringWithFormat:@"%zd",editSolutionFlag];
    NSString *flagReceivedString = [NSString stringWithFormat:@"%zd",received];
    NSString *solutionString = (!received || [solution isEqualToString:@""])?@"1":solution;
    
    [self requestResolutionCenter].generatedHost = _generatedHost;
    [[self requestResolutionCenter] setParamReplayValidationFromID:_resolutionID?:@"" message:message photos:photo serverID:serverID editSolutionFlag:editSolutionFlagString solution:solutionString refundAmount:refunAmount flagReceived:flagReceivedString troubleType:trouble action:action];
    [[self requestResolutionCenter] doRequestReplay];
}

-(RequestResolutionCenter*)requestResolutionCenter
{
    if (!_requestResolutionCenter) {
        _requestResolutionCenter = [RequestResolutionCenter new];
        _requestResolutionCenter.delegate = self;
    }
    return _requestResolutionCenter;
}

-(void)didSuccessReplay
{
    [self refreshRequest];
}

- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
    if (gesture.view.tag == 10) {
        [_navigate navigateToInvoiceFromViewController:self withInvoiceURL:_resolutionDetail.resolution_order.order_pdf_url];
    }
    else
    {
        if (![NavigationHelper shouldDoDeepNavigation]) {
            return;
        }
        
        if (_resolutionDetail.resolution_by.by_customer == 1) {
            [_navigate navigateToProfileFromViewController:self withUserID:@""];
        }
        else if (_resolutionDetail.resolution_by.by_seller == 1) {
            NSArray *query = [[[NSURL URLWithString:_resolutionDetail.resolution_customer.customer_url] path] componentsSeparatedByString: @"/"];
            [_navigate navigateToProfileFromViewController:self withUserID:[query objectAtIndex:2]?:@""];
            
        }
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

-(void)replaceDataSelected:(InboxResolutionCenterList*)resolution indexPath:(NSIndexPath*)indexPath resolutionID:(NSString*)resolutionID
{
    _resolution = resolution;
    _indexPath = indexPath;
    _resolutionID = resolutionID;
    
    [self requestWithAction:ACTION_GET_RESOLUTION_CENTER_DETAIL];
}


-(void)SettingAddressViewController:(SettingAddressViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    BOOL isEditAddress = ([[viewController.data objectForKey:@"type"] integerValue] == TYPE_ADD_EDIT_PROFILE_EDIT_RESO);

    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    ResolutionConversation *conversation = viewController.data[@"conversation"];

    if (address.address_id == 0) {
        address.address_id = address.addr_id;
    }

    if (conversation.address.address_id == 0) {
        conversation.address.address_id = conversation.address.addr_id;
    }
    
    NSString *oldDataID = @"";
    if (isEditAddress) {
        oldDataID = [NSString stringWithFormat:@"%ld-%@",conversation.address.address_id, conversation.conversation_id];
    }
    _selectedAddress = address;
    NSString *action = @"";
    if (isEditAddress) {
        action = @"edit_address_resolution";
    }
    else
        action = @"input_address_resolution";
    
    [_requestInputAddress setParamInputAddress:_selectedAddress
                                  resolutionID:[_resolutionDetail.resolution_last.last_resolution_id stringValue]
                                     oldDataID:oldDataID
                                 isEditAddress:isEditAddress
                                        action:action];
    
    [_requestInputAddress doRequest];
}

-(void)successAddress:(InboxResolutionCenterList *)resolution successStatus:(NSArray *)successStatus
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:successStatus?:@[@"Anda telah berhasil mengubah alamat"] delegate:self];
    [alert show];
    [self refreshRequest];
}

-(void)failedAddress:(InboxResolutionCenterList *)resolution errors:(NSArray *)errors
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errors delegate:self];
    [alert show];
}

@end
