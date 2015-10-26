//
//  InboxResolutionCenterComplainViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "ShopBadgeLevel.h"
#import "CMPopTipView.h"
#import "string_inbox_message.h"
#import "NavigateViewController.h"

#import "InboxResolutionCenterComplainViewController.h"
#import "InboxResolutionCenterComplainCell.h"
#import "InboxResolutionCenterObjectMapping.h"
#import "FilterComplainViewController.h"

#import "ResolutionCenterDetailViewController.h"
#import "TxOrderStatusViewController.h"

#import "GeneralTableViewController.h"

#import "ReputationDetail.h"
#import "ResolutionAction.h"

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "ShopReputation.h"
#import "SmileyAndMedal.h"

#import "TagManagerHandler.h"

#define DATA_FILTER_PROCESS_KEY @"filter_process"
#define DATA_FILTER_READ_KEY @"filter_read"
#define DATA_FILTER_SORTING_KEY @"filter_sorting"

#define DATA_SELECTED_RESOLUTION_KEY @"selected_resolution"
#define DATA_SELECTED_INDEXPATH_RESOLUTION_KEY @"seleted_indexpath_resolution"

#define TAG_REQUEST_LIST 10
#define TAG_REQUEST_CANCEL_COMPLAIN 11

@interface InboxResolutionCenterComplainViewController ()<
    UITabBarControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    SmileyDelegate,
    GeneralTableViewControllerDelegate,
    ResolutionCenterDetailViewControllerDelegate,
    InboxResolutionCenterComplainCellDelegate,
    LoadingViewDelegate,
    CMPopTipViewDelegate,
    TokopediaNetworkManagerDelegate>
{
    NavigateViewController *_navigate;
    NSMutableArray *_list;
    NSString *_URINext;
    BOOL _isNodata;
    UIRefreshControl *_refreshControl;
    NSInteger _page;
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_dataInput;

    CMPopTipView *cmPopTitpView;
    InboxResolutionCenterObjectMapping *_mapping;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectManagerCancelComplain;
    __weak RKManagedObjectRequestOperation *_requestCancelComplain;
    
    NSMutableArray *_allObjectCancelComplain;
    
    BOOL _isFirstAppear;
    
    TokopediaNetworkManager *_networkManager;
    TokopediaNetworkManager *_networkManagerCancelComplain;
    
    NSDictionary *_objectCancelComplain;
    
    LoadingView *_loadingView;
    
    NSIndexPath *_selectedDetailIndexPath;
    
    TAGContainer *_gtmContainer;
}
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation InboxResolutionCenterComplainViewController

-(instancetype)init{
    _list = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _navigate = [NavigateViewController new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [InboxResolutionCenterObjectMapping new];
    _allObjectCancelComplain = [NSMutableArray new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManagerCancelComplain = [TokopediaNetworkManager new];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _networkManager.tagRequest = TAG_REQUEST_LIST;
    _networkManager.delegate = self;
    
    _networkManagerCancelComplain.tagRequest = TAG_REQUEST_CANCEL_COMPLAIN;
    _networkManagerCancelComplain.delegate = self;

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kembali" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    backBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshRequest)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    if (_isMyComplain) {
        _tableView.tableHeaderView = _headerView;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];

    _tableView.estimatedRowHeight = 70.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self refreshRequest];
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
    TagManagerHandler *gtmHandler = [TagManagerHandler new];
    [gtmHandler pushDataLayer:@{@"user_id" : [_userManager getUserId]}];
}

-(TAGContainer *)gtmContainer
{
    if (!_gtmContainer) {
        _gtmContainer = [TagManagerHandler getContainer];
    }
    return _gtmContainer;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

-(void)setFilterReadIndex:(NSInteger)filterReadIndex
{
    [_dataInput setObject:ARRAY_FILTER_UNREAD[filterReadIndex] forKey:DATA_FILTER_READ_KEY];
    if (_filterReadIndex != filterReadIndex) {
        _filterReadIndex = filterReadIndex;
        [self refreshRequest];
   }
}

-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    NSString *filterProcess = [_dataInput objectForKey:DATA_FILTER_PROCESS_KEY];
    NSString *filterSort = [_dataInput objectForKey:DATA_FILTER_SORTING_KEY];
    
    if (button.tag == 10) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Urutkan";
        controller.delegate = self;
        controller.senderIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        controller.objects = ARRAY_FILTER_SORT;
        controller.selectedObject = filterSort ?: ARRAY_FILTER_SORT[0];
        [self.navigationController pushViewController:controller animated:YES];
    }
    if (button.tag == 11) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = @"Filter";
        controller.delegate = self;
        controller.senderIndexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        controller.objects = ARRAY_FILTER_PROCESS;
        controller.selectedObject = filterProcess?:ARRAY_FILTER_PROCESS[0];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (button.tag == 12) {
        //Status Pemesanan
        TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
        vc.action = @"get_tx_order_status";
        vc.viewControllerTitle = @"Status Pemesanan";
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (button.tag == 13) {
        //Daftar Transaksi
        TxOrderStatusViewController *vc =[TxOrderStatusViewController new];
        vc.action = @"get_tx_order_list";
        vc.viewControllerTitle = @"Daftar Transaksi";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate General View Controller
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 10) {
        [_dataInput setObject:object forKey:DATA_FILTER_SORTING_KEY];
    }
    if (indexPath.row == 11) {
        [_dataInput setObject:object forKey:DATA_FILTER_PROCESS_KEY];
    }
    
    [self refreshRequest];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isNodata ? 0 : _list.count;
}

-(void)finishComplain:(InboxResolutionCenterList *)resolution atIndexPath:(NSIndexPath *)indexPath
{
    [self refreshRequest];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    InboxResolutionCenterComplainCell* cell = nil;
    NSString *cellID = INBOX_RESOLUTION_CENTER_MY_COMPLAIN_CELL_IDENTIFIER;
    
    cell = (InboxResolutionCenterComplainCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [InboxResolutionCenterComplainCell newCell];
        cell.delegate = self;
        [cell.viewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamMedium" size:13.0f]];
    }
    
    ResolutionDetail *resolution = ((InboxResolutionCenterList*)_list[indexPath.row]).resolution_detail;
    cell.viewLabelUser.text = _isMyComplain?resolution.resolution_shop.shop_name:resolution.resolution_customer.customer_name;
    
    //Set reputation score
    cell.btnReputation.tag = indexPath.row;
    
    if(resolution.resolution_by.by_customer == 1)
        [SmileyAndMedal generateMedalWithLevel:resolution.resolution_shop.shop_reputation.reputation_badge_object.level withSet:resolution.resolution_shop.shop_reputation.reputation_badge_object.set withImage:cell.btnReputation isLarge:NO];
    else {
        if(resolution.resolution_customer.customer_reputation.no_reputation!=nil && [resolution.resolution_customer.customer_reputation.no_reputation isEqualToString:@"1"]) {
            [cell.btnReputation setTitle:@"" forState:UIControlStateNormal];
            [cell.btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_neutral_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        }
        else {
            [cell.btnReputation setTitle:[NSString stringWithFormat:@" %@%%", resolution.resolution_customer.customer_reputation.positive_percentage] forState:UIControlStateNormal];
            [cell.btnReputation setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_smile_small" ofType:@"png"]] forState:UIControlStateNormal];
        }
    }
    
    //Set user label
//    if([resolution.resolution_by.user_label isEqualToString:CPenjual]) {
//        [cell.viewLabelUser setColor:CTagPenjual];
//    }
//    else if([resolution.resolution_by.user_label isEqualToString:CPembeli]) {
//        [cell.viewLabelUser setColor:CTagPembeli];
//    }
//    else if([resolution.resolution_by.user_label isEqualToString:CAdministrator]) {
//        [cell.viewLabelUser setColor:CTagAdministrator];
//    }
//    else if([resolution.resolution_by.user_label isEqualToString:CPengguna]) {
//        [cell.viewLabelUser setColor:CTagPengguna];
//    }
//    else {
//        [cell.viewLabelUser setColor:-1];//-1 is set to empty string
//    }
    [cell.viewLabelUser setLabelBackground:resolution.resolution_by.user_label];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_isMyComplain?resolution.resolution_shop.shop_image:resolution.resolution_customer.customer_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = cell.buyerProfileImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:request
                 placeholderImage:_isMyComplain?[UIImage imageNamed:@"icon_default_shop.jpg"]:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnosti c pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    NSInteger lastSolutionType = [resolution.resolution_last.last_solution integerValue];
    NSString *lastSolution;
    
    if (lastSolutionType == SOLUTION_REFUND) {
        lastSolution = [NSString stringWithFormat:@"Pengembalian dana kepada pembeli sebesar %@",resolution.resolution_last.last_refund_amt_idr];
    }
    else if (lastSolutionType == SOLUTION_RETUR) {
        lastSolution = [NSString stringWithFormat:@"Tukar barang sesuai pesanan"];
    }
    else if (lastSolutionType == SOLUTION_RETUR_REFUND) {
        lastSolution = [NSString stringWithFormat:@"Pembelian barang dan dana sebesar %@",resolution.resolution_last.last_refund_amt_idr];
    }
    else if (lastSolutionType == SOLUTION_SELLER_WIN) {
        lastSolution = [NSString stringWithFormat:@"Pengembalian dana penuh"];
    }
    else if (lastSolutionType == SOLUTION_SEND_REMAINING) {
        lastSolution = [NSString stringWithFormat:@"Kirimkan sisanya"];
    }
    else
        lastSolution = @"";
    
    cell.invoiceDateLabel.text = resolution.resolution_dispute.dispute_update_time;
    cell.invoiceNumberLabel.text = resolution.resolution_order.order_invoice_ref_num;
    [cell.lastStatusLabel setCustomAttributedText:lastSolution];
    cell.disputeStatus = resolution.resolution_dispute.dispute_status;
    cell.buyerOrSellerLabel.text = _isMyComplain?@"Pembelian dari":@"Pembelian oleh";
    cell.indexPath = indexPath;
    
    cell.unreadBorderView.hidden = (((InboxResolutionCenterList*)_list[indexPath.row]).resolution_read_status == 2)?YES:NO;
    cell.unreadIconImageView.hidden = cell.unreadBorderView.hidden;
    
    [cell.warningLabel setCustomAttributedText:[[self gtmContainer] stringForKey:GTMKeyComplainNotifString]?:@""];
    cell.warningLabel.hidden = !(resolution.resolution_dispute.dispute_30_days == 1);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return 227;
    }
    return UITableViewAutomaticDimension;

}


#pragma mark - Cell Delegate
-(void)goToInvoiceAtIndexPath:(NSIndexPath *)indexPath
{
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    [_navigate navigateToInvoiceFromViewController:self withInvoiceURL:resolution.resolution_detail.resolution_order.order_pdf_url];
}

-(void)goToShopOrProfileAtIndexPath:(NSIndexPath *)indexPath
{
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    if (_isMyComplain)
    {
        //gotoshop
        [_navigate navigateToShopFromViewController:self withShopID:(resolution.resolution_detail.resolution_shop.shop_id)?:@""];
    }
    else
    {
        //gotoProfile
        NSArray *query = [[[NSURL URLWithString:resolution.resolution_detail.resolution_customer.customer_url] path] componentsSeparatedByString: @"/"];
        [_navigate navigateToProfileFromViewController:self withUserID:[query objectAtIndex:2]?:@""];
        
    }
}


-(void)showImageAtIndexPath:(NSIndexPath *)indexPath
{
    [self goToShopOrProfileAtIndexPath:indexPath];
//    InboxResolutionCenterList *resolution = _list[indexPath.row];
//
//    NSString *imageURLString = @"";
//    if (_isMyComplain)
//        imageURLString = resolution.resolution_detail.resolution_shop.shop_image;
//    else
//        imageURLString = resolution.resolution_detail.resolution_customer.customer_image;
//
//    [_navigate navigateToShowImageFromViewController:self withImageURLStrings:@[imageURLString] indexImage:0];
}

-(void)goToResolutionDetailAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedDetailIndexPath = indexPath;
    InboxResolutionCenterList *resolution = _list[indexPath.row];
    NSString *resolutionID = [resolution.resolution_detail.resolution_last.last_resolution_id stringValue];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (![resolution isEqual:_detailViewController.resolution]) {
            [_detailViewController replaceDataSelected:resolution indexPath:indexPath resolutionID:resolutionID];
        }
    }
    else
    {
        ResolutionCenterDetailViewController *vc = [ResolutionCenterDetailViewController new];
        vc.indexPath = indexPath;
        vc.resolution = resolution;
        vc.resolutionID = [resolution.resolution_detail.resolution_last.last_resolution_id stringValue];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    ((InboxResolutionCenterList*)_list[indexPath.row]).resolution_read_status = 2; //status resolution become read
     [_tableView reloadData];
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedDetailIndexPath = indexPath;
    
    [self goToResolutionDetailAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isNodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"%ld", (long)row);
        
        if (_URINext != NULL && ![_URINext isEqualToString:@"0"] && _URINext != 0) {
            [_networkManager doRequest];
        }
    }
}

#pragma mark - Method
- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.leftPopUp = YES;
    cmPopTitpView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}

#pragma mark - Cell Delegate
- (void)actionReputation:(id)sender {
    ResolutionDetail *resolution = ((InboxResolutionCenterList*)_list[((UIView *) sender).tag]).resolution_detail;
    
    
    
    
    
    
    
    
    if(resolution.resolution_by.by_customer == 1) {
        if(resolution.resolution_shop.shop_reputation.tooltip!=nil && resolution.resolution_shop.shop_reputation.tooltip.length>0)
            [self initPopUp:resolution.resolution_shop.shop_reputation.tooltip withSender:sender withRangeDesc:NSMakeRange(0, 0)];
    }
    else {
        if(! (resolution.resolution_customer.customer_reputation.no_reputation!=nil && [resolution.resolution_customer.customer_reputation.no_reputation isEqualToString:@"1"])) {
            int paddingRightLeftContent = 10;
            UIView *viewContentPopUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (CWidthItemPopUp*3)+paddingRightLeftContent, CHeightItemPopUp)];
            
            SmileyAndMedal *tempSmileyAndMedal = [SmileyAndMedal new];
            [tempSmileyAndMedal showPopUpSmiley:viewContentPopUp andPadding:paddingRightLeftContent withReputationNetral:resolution.resolution_customer.customer_reputation.neutral withRepSmile:resolution.resolution_customer.customer_reputation.positive withRepSad:resolution.resolution_customer.customer_reputation.negative withDelegate:self];
            
            //Init pop up
            cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:viewContentPopUp];
            cmPopTitpView.delegate = self;
            cmPopTitpView.backgroundColor = [UIColor whiteColor];
            cmPopTitpView.animation = CMPopTipAnimationSlide;
            cmPopTitpView.dismissTapAnywhere = YES;
            cmPopTitpView.leftPopUp = YES;
            
            UIButton *button = (UIButton *)sender;
            [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
        }
    }
}

-(void)refreshRequest
{
    _page = 1;
    [_networkManager doRequest];
}

#pragma mark - Delegate
-(void)shouldCancelComplain:(InboxResolutionCenterList *)resolution atIndexPath:(NSIndexPath*)indexPath
{
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:resolution forKey:DATA_SELECTED_RESOLUTION_KEY];
    [object setObject:indexPath forKey:DATA_SELECTED_INDEXPATH_RESOLUTION_KEY];
    _objectCancelComplain = [object copy];
    [_networkManagerCancelComplain doRequest];
}

#pragma mark - Request

-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_LIST) {
        return [self objectManagerList];
    }
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN) {
        return [self objectManagerCancelComplain];
    }
    
    return nil;
}


-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_LIST) {
        NSString *filterProcess = [_dataInput objectForKey:DATA_FILTER_PROCESS_KEY];
        NSString *filterRead = ARRAY_FILTER_UNREAD[_filterReadIndex];
        NSString *filterSort = [_dataInput objectForKey:DATA_FILTER_SORTING_KEY];
        
        NSString *status = @"";
        NSString *unread = @"";
        NSString *sortType = @"";
        
        if ([filterProcess isEqualToString:ARRAY_FILTER_PROCESS[0]])
            status = @"0";
        else if([filterProcess isEqualToString:ARRAY_FILTER_PROCESS[1]])
            status = @"1";
        else if ([filterProcess isEqualToString:ARRAY_FILTER_PROCESS[2]])
            status = @"2";
        
        if ([filterRead isEqualToString:ARRAY_FILTER_UNREAD[0]])
            unread = @"0";
        else if([filterRead isEqualToString:ARRAY_FILTER_UNREAD[1]])
            unread = @"1";
        else if ([filterRead isEqualToString:ARRAY_FILTER_UNREAD[2]])
            unread = @"2";
        
        if ([filterSort isEqualToString:ARRAY_FILTER_SORT[0]])
            sortType = @"2";
        else if([filterSort isEqualToString:ARRAY_FILTER_SORT[1]])
            sortType = @"1";
        
        NSDictionary* param = @{API_ACTION_KEY : ACTION_GET_RESOLUTION_CENTER,
                                API_COMPLAIN_TYPE_KEY : _isMyComplain?@(0):@(1),
                                API_STATUS_KEY : status,
                                API_UNREAD_KEY : unread,
                                API_SORT_KEY :sortType,
                                API_PAGE_KEY :@(_page)
                                };
        return param;
    }
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN) {
        InboxResolutionCenterList *resolution = [_objectCancelComplain objectForKey:DATA_SELECTED_RESOLUTION_KEY];
        NSDictionary* param = @{API_ACTION_KEY : ACTION_CANCEL_RESOLUTION,
                                API_RESOLUTION_ID_KEY : resolution.resolution_detail.resolution_last.last_resolution_id?:@""
                                };
        return param;
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_LIST) {
        return API_PATH_INBOX_RESOLUTION_CENTER;
    }
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN) {
        return API_PATH_ACTION_RESOLUTION_CENTER;
    }
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_LIST)
    {
        InboxResolutionCenter *order = stat;
        return order.status;
    }
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN) {
        ResolutionAction *resolution = stat;
        return resolution.status;
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_LIST) {
        _tableView.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN)
    {
        InboxResolutionCenterList *resolution = [_objectCancelComplain objectForKey:DATA_SELECTED_RESOLUTION_KEY];
        [_list removeObject:resolution];
        [_tableView reloadData];
        [_allObjectCancelComplain addObject:_objectCancelComplain];
    }
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_LIST) {
        [self requestSuccessList:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN) {
        [self requestSuccessCancelComplain:successResult withOperation:operation];
    }

}

-(void)requestSuccessList:(id)successResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    InboxResolutionCenter *order = stat;
    BOOL status = [order.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(order.message_error)
        {
            NSArray *array = order.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
            [alert show];
        }
        else{
            if (_page == 1) {
                [_list removeAllObjects];
            }
            
            if (order.result.list.count >0) {
                [_list addObjectsFromArray:order.result.list];
                _isNodata = NO;
                _URINext =  order.result.paging.uri_next;
                NSURL *url = [NSURL URLWithString:_URINext];
                NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
                
                NSMutableDictionary *queries = [NSMutableDictionary new];
                [queries removeAllObjects];
                for (NSString *keyValuePair in querry)
                {
                    NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                    NSString *key = [pairComponents objectAtIndex:0];
                    NSString *value = [pairComponents objectAtIndex:1];
                    
                    [queries setObject:value forKey:key];
                }
                
                _page = [[queries objectForKey:API_PAGE_KEY] integerValue];
                _tableView.tableFooterView = nil;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && _page <= 1) {
                    NSIndexPath *indexPath = _selectedDetailIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0];
                    InboxResolutionCenterList *resolution = _list[indexPath.row];
                    NSString *resolutionID = [resolution.resolution_detail.resolution_last.last_resolution_id stringValue];
                    if (![resolution isEqual:_detailViewController.resolution]) {
                        [_detailViewController replaceDataSelected:resolution indexPath:indexPath resolutionID:resolutionID];
                    }
                }
            }
            else
            {
                NoResultView *noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 103)];
                _tableView.tableFooterView = noResultView;
            }
            
            [_tableView reloadData];
        }
    }
    [_refreshControl endRefreshing];
    [_act stopAnimating];
}

-(void)requestSuccessCancelComplain:(id)successResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];
    ResolutionAction *resolution = stat;
    BOOL status = [resolution.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if(resolution.message_error)
        {
            [self requestFailureCancelComplain:_objectCancelComplain];
        }
        else if (resolution.result.is_success == 1) {
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:resolution.message_status?:@[@"Anda telah berhasil membatalkan komplain."] delegate:self];
            [alert show];
            [_allObjectCancelComplain removeObject:_objectCancelComplain];
            [[NSNotificationCenter defaultCenter] postNotificationName:DID_CANCEL_COMPLAIN_NOTIFICATION_NAME object:nil];
        }
        else
        {
            [self requestFailureCancelComplain:_objectCancelComplain];
        }
    }
    else
    {
        [self requestFailureCancelComplain:_objectCancelComplain];
    }
    
    [self requestProcessCancelComplain];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_LIST) {
        [_refreshControl endRefreshing];
        [_act stopAnimating];
        _tableView.tableFooterView = _loadingView;
    }
    if (tag == TAG_REQUEST_CANCEL_COMPLAIN) {
        [self requestFailureCancelComplain:_objectCancelComplain];
        [self requestProcessCancelComplain];
    }

}

-(void)pressRetryButton
{
    [_act startAnimating];
    [_networkManager doRequest];
}

-(void)requestFailureCancelComplain:(NSDictionary*)object
{
    InboxResolutionCenterList *resolution = [object objectForKey:DATA_SELECTED_RESOLUTION_KEY];
    NSIndexPath *indexPathResolution = [object objectForKey:DATA_SELECTED_INDEXPATH_RESOLUTION_KEY];
    [_list insertObject:resolution atIndex:indexPathResolution.row];
    [_allObjectCancelComplain removeObject:object];
    [_tableView reloadData];
}

-(void)requestProcessCancelComplain
{
    if (_allObjectCancelComplain.count>0) {
        _objectCancelComplain = [_allObjectCancelComplain firstObject];
        [_networkManagerCancelComplain doRequest];
    }
}

#pragma mark - Object Manager

-(RKObjectManager*)objectManagerList
{
    _objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[InboxResolutionCenter class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[InboxResolutionCenterResult class]];
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[InboxResolutionCenterList class]];
    [listMapping addAttributeMappingsFromArray:@[API_RESOLUTION_READ_STATUS_KEY]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIURINEXTKEY:kTKPD_APIURINEXTKEY,
                                                        }];
    RKObjectMapping *resolutionDetailMapping = [RKObjectMapping mappingForClass:[ResolutionDetail class]];
    
    RKObjectMapping *resolutionLastMapping = [_mapping resolutionLastMapping];
    RKObjectMapping *resolutionOrderMapping = [_mapping resolutionOrderMapping];
    RKObjectMapping *resolutionByMapping = [_mapping resolutionByMapping];
    RKObjectMapping *resolutionShopMapping = [_mapping resolutionShopMapping];
    RKObjectMapping *resolutionCustomerMapping = [_mapping resolutionCustomerMapping];
    RKObjectMapping *resolutionDisputeMapping = [_mapping resolutionDisputeMapping];
    
    
    RKObjectMapping *reviewUserReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [reviewUserReputationMapping addAttributeMappingsFromArray:@[CPositivePercentage,
                                                                 CNoReputation,
                                                                 CNegative,
                                                                 CNeutral,
                                                                 CPositif]];
    
    
    RKObjectMapping *shopReputationMapping = [RKObjectMapping mappingForClass:[ShopReputation class]];
    [shopReputationMapping addAttributeMappingsFromArray:@[CToolTip,
                                                           CReputationBadge,
                                                           CReputationScore,
                                                           CScore,
                                                           CMinBadgeScore]];
    
    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];

    [resolutionShopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopReputation toKeyPath:CShopReputation withMapping:shopReputationMapping]];
    [resolutionCustomerMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CCustomerReputation toKeyPath:CCustomerReputation withMapping:reviewUserReputationMapping]];
    
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    
    RKRelationshipMapping *listRel =[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                toKeyPath:kTKPD_APILISTKEY
                                                                              withMapping:listMapping];
    
    RKRelationshipMapping *pagingRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY
                                                                                   toKeyPath:kTKPD_APIPAGINGKEY
                                                                                 withMapping:pagingMapping];
    
    RKRelationshipMapping *resolutionDetailRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_DETAIL_KEY
                                                                                             toKeyPath:API_RESOLUTION_DETAIL_KEY
                                                                                           withMapping:resolutionDetailMapping];
    
    RKRelationshipMapping *resolutionLastRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_LAST_KEY
                                                                                           toKeyPath:API_RESOLUTION_LAST_KEY
                                                                                         withMapping:resolutionLastMapping];
    
    RKRelationshipMapping *resolutionOrderRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_ORDER_KEY
                                                                                            toKeyPath:API_RESOLUTION_ORDER_KEY
                                                                                          withMapping:resolutionOrderMapping];
    
    RKRelationshipMapping *resolutionByRel= [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_BY_KEY
                                                                                        toKeyPath:API_RESOLUTION_BY_KEY
                                                                                      withMapping:resolutionByMapping];
    
    RKRelationshipMapping *resolutionShopRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_SHOP_KEY
                                                                                           toKeyPath:API_RESOLUTION_SHOP_KEY
                                                                                         withMapping:resolutionShopMapping];
    
    RKRelationshipMapping *resolutionCustomerRel= [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_CUSTOMER_KEY
                                                                                              toKeyPath:API_RESOLUTION_CUSTOMER_KEY
                                                                                            withMapping:resolutionCustomerMapping];
    
    RKRelationshipMapping *resolutionDisputeRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_RESOLUTION_DISPUTE_KEY
                                                                                              toKeyPath:API_RESOLUTION_DISPUTE_KEY
                                                                                            withMapping:resolutionDisputeMapping];
    
    
    [shopReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CReputationBadge toKeyPath:CReputationBadgeObject withMapping:shopBadgeMapping]];
    [statusMapping addPropertyMapping:resultRel];
    
    [resultMapping addPropertyMapping:listRel];
    [resultMapping addPropertyMapping:pagingRel];
    
    [listMapping addPropertyMapping:resolutionDetailRel];
    
    [resolutionDetailMapping addPropertyMapping:resolutionLastRel];
    [resolutionDetailMapping addPropertyMapping:resolutionOrderRel];
    [resolutionDetailMapping addPropertyMapping:resolutionByRel];
    [resolutionDetailMapping addPropertyMapping:resolutionShopRel];
    [resolutionDetailMapping addPropertyMapping:resolutionCustomerRel];
    [resolutionDetailMapping addPropertyMapping:resolutionDisputeRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_INBOX_RESOLUTION_CENTER
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}


-(RKObjectManager*)objectManagerCancelComplain
//-(void)configureRestKitCancelComplain
{
    _objectManagerCancelComplain = [RKObjectManager sharedClient];
    
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
    
    [_objectManagerCancelComplain addResponseDescriptor:responseDescriptor];
    
    return _objectManagerCancelComplain;
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManagerCancelComplain.delegate = nil;
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}


#pragma mark - CMPopTipView Delegate
- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}

#pragma mark - Smiley Delegate
- (void)actionVote:(id)sender {
    [self dismissAllPopTipViews];
}
@end
