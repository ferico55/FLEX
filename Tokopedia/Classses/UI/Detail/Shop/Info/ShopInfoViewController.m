////
////  ShopInfoViewController.m
////  Tokopedia
////
////  Created by IT Tkpd on 10/6/14.
////  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
////

#import "detail.h"
#import "Shop.h"
#import "Payment.h"
#import "StarsRateView.h"
#import "ShopInfoShipmentCell.h"
#import "ShopInfoPaymentCell.h"
#import "ShopInfoAddressView.h"

#import "ShopFavoritedViewController.h"

#import "ShopInfoViewController.h"

//profile
#import "TKPDTabProfileNavigationController.h"
#import "ProfileBiodataViewController.h"
#import "ProfileContactViewController.h"
#import "ProfileFavoriteShopViewController.h"

//edit shop detail
#import "../Edit/ShopEditViewController.h"

#pragma mark - Shop Info View Controller
@interface ShopInfoViewController()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    Shop *_shop;
    BOOL _isnodata;
    BOOL _isaddressexpanded;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *containerview;

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *labelshopname;
@property (weak, nonatomic) IBOutlet UILabel *labelshoptagline;
@property (weak, nonatomic) IBOutlet UILabel *labelshopdescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonfav;
@property (weak, nonatomic) IBOutlet UIButton *buttonitemsold;
@property (weak, nonatomic) IBOutlet StarsRateView *speedrate;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrate;
@property (weak, nonatomic) IBOutlet StarsRateView *servicerate;
@property (weak, nonatomic) IBOutlet UILabel *labellocation;
@property (weak, nonatomic) IBOutlet UILabel *labellastlogin;
@property (weak, nonatomic) IBOutlet UILabel *labelopensince;
@property (weak, nonatomic) IBOutlet UIButton *buttonofflocation;


@property (weak, nonatomic) IBOutlet UILabel *labelsuccessfulltransaction;
@property (weak, nonatomic) IBOutlet UILabel *labelsold;
@property (weak, nonatomic) IBOutlet UILabel *labeletalase;
@property (weak, nonatomic) IBOutlet UILabel *labeltotalproduct;

@property (weak, nonatomic) IBOutlet UITableView *tableshipment;

@property (weak, nonatomic) IBOutlet UITableView *tablepayment;

@property (weak, nonatomic) IBOutlet UIImageView *thumbowner;
@property (weak, nonatomic) IBOutlet UILabel *nameowner;
@property (weak, nonatomic) IBOutlet UIView *transactionview;
@property (weak, nonatomic) IBOutlet UIView *shipmentview;
@property (weak, nonatomic) IBOutlet UIView *paymentview;
@property (weak, nonatomic) IBOutlet UIView *ownerview;
@property (weak, nonatomic) IBOutlet UIView *addressoffview;
@property (weak, nonatomic) IBOutlet UIView *shopdetailview;
- (IBAction)gesture:(id)sender;

- (IBAction)tap:(id)sender;
@end

@implementation ShopInfoViewController


#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isaddressexpanded = NO;
        self.title = kTKPDTITLE_SHOP_INFO;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollview.delegate = self;
    _scrollview.scrollEnabled = YES;
    CGSize viewsize = _containerview.frame.size;
    [_scrollview setContentSize:viewsize];
    [_scrollview addSubview:_containerview];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    barbutton1.tag = 11;
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    if (auth && ![auth isEqual:[NSNull null]]) {
        if (_shop.result.owner.owner_id == [[auth objectForKey:kTKPD_USERIDKEY]integerValue]) {
            [barbutton1 setEnabled:YES];
            self.navigationItem.rightBarButtonItem = barbutton1;
        }
    }
    else
    {
        [barbutton1 setEnabled:NO];
        [barbutton1 setTintColor: [UIColor clearColor]];
    }
    
    [self setData:_data];
    [_tablepayment reloadData];
    [_tableshipment reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Action
- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                // go to profile
                NSMutableArray *viewcontrollers = [NSMutableArray new];
                /** create new view controller **/
                ProfileBiodataViewController *v = [ProfileBiodataViewController new];
                [viewcontrollers addObject:v];
                ProfileFavoriteShopViewController *v1 = [ProfileFavoriteShopViewController new];
                v1.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(_shop.result.owner.owner_id),
                            kTKPDDETAIL_APISHOPIDKEY:@(_shop.result.info.shop_id),
                            kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]
                            };
                [viewcontrollers addObject:v1];
                ProfileContactViewController *v2 = [ProfileContactViewController new];
                [viewcontrollers addObject:v2];
                // Adjust View Controller
                TKPDTabProfileNavigationController *tapnavcon = [TKPDTabProfileNavigationController new];
                tapnavcon.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(_shop.result.owner.owner_id),
                                   kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                [tapnavcon setViewControllers:viewcontrollers animated:YES];
                [tapnavcon setSelectedIndex:0];
                
                [self.navigationController pushViewController:tapnavcon animated:YES];
                break;
            }
        }
    }
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                //expand location
                _isaddressexpanded = _isaddressexpanded?NO:YES;
                [self setDetailFrame];
                break;
            }
            case 11:
            {
                //favorited button action
                ShopFavoritedViewController *vc = [ShopFavoritedViewController new];
                vc.data = @{kTKPDDETAIL_APISHOPIDKEY : @(_shop.result.info.shop_id),
                            kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                // sold item button action
                NSDictionary *userinfo = @{kTKPDDETAIL_DATAINDEXKEY:@(0)};
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 13:
            {
                // go to pofile shop owner (transparant button)
                NSMutableArray *viewcontrollers = [NSMutableArray new];
                /** create new view controller **/
                ProfileBiodataViewController *v = [ProfileBiodataViewController new];
                [viewcontrollers addObject:v];
                ProfileFavoriteShopViewController *v1 = [ProfileFavoriteShopViewController new];
                v1.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(_shop.result.owner.owner_id),
                            kTKPDDETAIL_APISHOPIDKEY:@(_shop.result.info.shop_id),
                            kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]
                            };
                [viewcontrollers addObject:v1];
                ProfileContactViewController *v2 = [ProfileContactViewController new];
                [viewcontrollers addObject:v2];
                // Adjust View Controller
                TKPDTabProfileNavigationController *tapnavcon = [TKPDTabProfileNavigationController new];
                tapnavcon.data = @{kTKPDFAVORITED_APIUSERIDKEY:@(_shop.result.owner.owner_id),
                                   kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:[NSNull null]};
                [tapnavcon setViewControllers:viewcontrollers animated:YES];
                [tapnavcon setSelectedIndex:0];
                
                [self.navigationController pushViewController:tapnavcon animated:YES];
                break;
            }
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                // back
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                // edit shop
                ShopEditViewController *vc = [ShopEditViewController new];
                vc.data = @{kTKPDDETAIL_DATASHOPSKEY:_shop.result};
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
        
    }
    
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tableshipment) {
        // Table Shipment
#ifdef kTKPDSHOPINFO_NODATAENABLE
        return _isnodata ? 1 : _shop.result.shipment.count;
#else
        return _isnodata ? 0 : _shop.result.shipment.count;
#endif
    }
    else if (tableView == _tablepayment){
        // Table Payment
#ifdef kTKPDSHOPINFO_NODATAENABLE
        return _isnodata ? 1 : _shop.result.payment.count;
#else
        return _isnodata ? 0 : _shop.result.payment.count;
#endif
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    
    if (!_isnodata) {
        if (tableView == _tableshipment) {
            // Table Shipment
        
            NSString *cellid = kTKPDSHOPINFOPAYMENTCELL_IDENTIFIER;
            
            cell = (ShopInfoShipmentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ShopInfoShipmentCell newcell];
            }
            
            if (_shop.result.shipment.count > indexPath.row) {
                
                Shipment *shipment = _shop.result.shipment[indexPath.row];
                ((ShopInfoShipmentCell*)cell).labelshipment.text = shipment.shipment_name;
                NSArray *packages = shipment.shipment_package;
                for (int i = 0; i<packages.count; i++) {
                    ShipmentPackage *package = packages[i];
                    [(UILabel*)((ShopInfoShipmentCell*)cell).packageLabel setText:package.product_name];
                }
            }
        }
        else if (tableView == _tablepayment){
            // Table Payment

            NSString *cellid = kTKPDSHOPINFOPAYMENTCELL_IDENTIFIER;
            
            cell = (ShopInfoPaymentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ShopInfoPaymentCell newcell];
            }
            
            if (_shop.result.payment.count > indexPath.row) {
                
                Payment *payment = _shop.result.payment[indexPath.row];
                ((ShopInfoPaymentCell*)cell).labelpayment.text = payment.payment_name;
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:payment.payment_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                //request.URL = url;
                
                UIImageView *thumb = ((ShopInfoPaymentCell*)cell).image;
                thumb.image = nil;
                //thumb.hidden = YES;	//@prepareforreuse then @reset
                
                //[((ShopInfoPaymentCell*)cell).act startAnimating];
                
                [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    //NSLOG(@"thumb: %@", thumb);
                    [thumb setImage:image];
                    thumb.contentMode = UIViewContentModeScaleAspectFit;
                    
                    //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    //[((ShopInfoPaymentCell*)cell).act stopAnimating];
                }];
            }
        }
    }
    else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
}

#pragma mark - Methods
-(void)setShopInfoData
{
    _labelshopname.text = _shop.result.info.shop_name;
    _labelshoptagline.text = _shop.result.info.shop_tagline;
    _labelshopdescription.text = _shop.result.info.shop_description;
    [_buttonfav setTitle:_shop.result.info.shop_total_favorit forState:UIControlStateNormal];
    [_buttonitemsold setTitle:_shop.result.info.shop_total_favorit forState:UIControlStateNormal];
    _speedrate.starscount = _shop.result.stats.shop_service_rate;
    _accuracyrate.starscount = _shop.result.stats.shop_accuracy_rate;
    _servicerate.starscount = _shop.result.stats.shop_service_rate;
    _labellocation.text = _shop.result.info.shop_location;
    _labellastlogin.text = _shop.result.info.shop_owner_last_login;
    _labelopensince.text = _shop.result.info.shop_open_since;
    _nameowner.text = _shop.result.owner.owner_name;
    NSInteger totallocation = _shop.result.address.count;
    [_buttonofflocation setTitle:[NSString stringWithFormat:@"%d Offline", totallocation] forState:UIControlStateNormal];
    
    _labelsuccessfulltransaction.text = _shop.result.stats.shop_total_transaction;
    _labelsold.text = _shop.result.stats.shop_item_sold;
    _labeletalase.text = _shop.result.stats.shop_total_etalase;
    _labeltotalproduct.text = _shop.result.stats.shop_total_product;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = _thumb;
    thumb.layer.cornerRadius = thumb.frame.size.width/2;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    //[((ShopInfoPaymentCell*)cell).act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
    }];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.owner.owner_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    thumb = _thumbowner;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    //[((ShopInfoPaymentCell*)cell).act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
    }];

}

-(void)setDetailFrame
{
    NSInteger delta = 50;
    
    CGRect frame;
    
    [_labelshopdescription sizeToFit];
    
    frame = _shopdetailview.frame;
    frame.origin.y = _labelshopdescription.frame.size.height + _labelshopdescription.frame.origin.y + 20;
    _shopdetailview.frame = frame;
    
    NSArray * address = _shop.result.address;

    for (int i = 0; i<address.count; i++) {
        if (_isaddressexpanded) {
            ShopInfoAddressView *v = [ShopInfoAddressView newview];
            frame = _addressoffview.frame;
            frame.size.height = v.frame.size.height * address.count;
            
            _addressoffview.frame = frame;
            frame = v.frame;
            frame.origin.y = v.frame.size.height*i;
            [_addressoffview addSubview:v];
            v.frame = frame;
            _addressoffview.hidden = NO;
            [self setAddressDataView:v withData:address[i]];
        }
        else{
            frame = _addressoffview.frame;
            frame.size.height = 0;
            frame.origin.y = _shopdetailview.frame.size.height + _shopdetailview.frame.origin.y ;
            _addressoffview.frame = frame;
            _addressoffview.hidden = YES;
        }
    }
    
    frame = _transactionview.frame;
    frame.origin.y = _addressoffview.frame.size.height + _addressoffview.frame.origin.y ;
    _transactionview.frame = frame;
    
    [_tableshipment layoutIfNeeded];
    CGSize size = _tableshipment.contentSize;
    CGRect tableframe = _tableshipment.frame;
    tableframe.size.height = size.height;
    _tableshipment.frame = tableframe;
    frame = _shipmentview.frame;
    frame.origin.y = _transactionview.frame.size.height + _transactionview.frame.origin.y;
    frame.size.height = size.height + delta;
    _shipmentview.frame = frame;
    
    [_tablepayment layoutIfNeeded];
    size = _tablepayment.contentSize;
    tableframe = _tablepayment.frame;
    tableframe.size.height = size.height;
    _tablepayment.frame = tableframe;
    frame = _paymentview.frame;
    frame.origin.y = _shipmentview.frame.size.height + _shipmentview.frame.origin.y;
    frame.size.height = size.height+ delta;
    _paymentview.frame = frame;
    
    frame = _ownerview.frame;
    frame.origin.y = _paymentview.frame.size.height + _paymentview.frame.origin.y ;
    _ownerview.frame = frame;
    
    frame = _containerview.frame;
    frame.size.height = _ownerview.frame.origin.y + _ownerview.frame.size.height + delta;
   _containerview.frame = frame;
    
    CGSize viewsize = frame.size;
    [_scrollview setContentSize:viewsize];
}

-(void)setAddressDataView:(ShopInfoAddressView*)view withData:(id)data
{
    Address *address = data;
    view.labelname.text = address.location_address_name?:@"-";
    view.labelDistric.text = address.location_district_name?:@"-";
    view.labelcity.text = address.location_district_name?:@"-";
    view.labelprov.text = address.location_province_name?:@"";
    view.labelpostal.text = address.location_postal_code?:@"-";
    view.labelemail.text = address.location_email?:@"-";
    view.labelfax.text = address.location_fax?:@"-";
    view.labelphone.text = address.location_phone?:@"-";
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        _isnodata = NO;
        _shop = [_data objectForKey:kTKPDDETAIL_DATAINFOSHOPSKEY];
        [self setShopInfoData];
        [self setDetailFrame];
    }
}

@end
