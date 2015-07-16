////
////  ShopInfoViewController.m
////  Tokopedia
////
////  Created by IT Tkpd on 10/6/14.
////  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
////
#import "DetailStatisticViewController.h"
#import "detail.h"
#import "Shop.h"
#import "Payment.h"
#import "StarsRateView.h"
#import "ShopInfoShipmentCell.h"
#import "ShopInfoPaymentCell.h"
#import "ShopInfoAddressView.h"

#import "ShopFavoritedViewController.h"
#import "ShopEditViewController.h"
#import "ShopInfoViewController.h"

//profile
#import "TKPDTabProfileNavigationController.h"
//#import "ProfileBiodataViewController.h"
#import "ProfileContactViewController.h"
#import "ProfileFavoriteShopViewController.h"

#import "NavigateViewController.h"
#import "UserContainerViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface ShopInfoViewController()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    Shop *_shop;
    BOOL _isnodata;
    BOOL _isaddressexpanded;
    NavigateViewController *_navigateController;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *containerview;

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *labelshopname;
@property (weak, nonatomic) IBOutlet UILabel *labelshoptagline;
@property (weak, nonatomic) IBOutlet UILabel *labelshopdescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonfav;
@property (weak, nonatomic) IBOutlet UIButton *buttonitemsold;
@property (weak, nonatomic) IBOutlet UILabel *labellocation;
@property (weak, nonatomic) IBOutlet UILabel *labellastlogin;
@property (weak, nonatomic) IBOutlet UILabel *labelopensince;
@property (weak, nonatomic) IBOutlet UIButton *buttonofflocation;
@property (weak, nonatomic) IBOutlet UIButton *buttonArrowLocation;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avatarIndicator;

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
@property (strong, nonatomic) IBOutlet UIView *addressoffview;
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
    }
    return self;
}



#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Informasi Toko";
    
    _navigateController = [NavigateViewController new];
    
    _scrollview.delegate = self;
    _scrollview.scrollEnabled = YES;
    CGSize viewsize = _containerview.frame.size;
    [_scrollview setContentSize:viewsize];
    [_scrollview addSubview:_containerview];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self setData:_data];
    [_tablepayment reloadData];
    [_tableshipment reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateShopPicture:)
                                                 name:EDIT_SHOP_AVATAR_NOTIFICATION_NAME
                                               object:nil];
    
    //Set Position Btn Lihat Detail Statistic
    CGSize newSize = CGSizeMake(15, 15);
    UIGraphicsBeginImageContext(newSize);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_arrow_right_gray" ofType:@"png"]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [btnLihatDetailStat setImage:tempImage forState:UIControlStateNormal];
    btnLihatDetailStat.imageEdgeInsets = UIEdgeInsetsMake(0, btnLihatDetailStat.bounds.size.width-btnLihatDetailStat.imageView.bounds.size.width-15, 0, 0);
    btnLihatDetailStat.titleEdgeInsets = UIEdgeInsetsMake(0, -btnLihatDetailStat.imageView.bounds.size.width+15, 0, 0);
    
    
    
    //set reputasi and akurasi
    UIFont *boldFont = [UIFont boldSystemFontOfSize:lblReputasi.font.pointSize];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys: boldFont, NSFontAttributeName, lblKecepatan.textColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:lblReputasi.font, NSFontAttributeName, lblKecepatan.textColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", _shop.result.stats.shop_reputation_score, CStringPoin] attributes:attrs];
    [attributedText setAttributes:subAttrs range:NSMakeRange(attributedText.string.length-CStringPoin.length, CStringPoin.length)];
    [lblReputasi setAttributedText:attributedText];
    lblKecepatan.text = [_shop.result.respond_speed.speed_level stringByReplacingOccurrencesOfString:@"Respon" withString:@"Transaksi"];
    
    //Set image speed
    if([_shop.result.respond_speed.badge isEqualToString:CBadgeSpeedGood]) {
        imageSpeed.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_speed_fast" ofType:@"png"]];
    }
    else if([_shop.result.respond_speed.badge isEqualToString:CBadgeSpeedBad]) {
        imageSpeed.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_speed_bad" ofType:@"png"]];
    }
    else if([_shop.result.respond_speed.badge isEqualToString:CBadgeSpeedNeutral]) {
        imageSpeed.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_speed_neutral" ofType:@"png"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
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
                [_navigateController navigateToProfileFromViewController:self withUserID:[NSString stringWithFormat:@"%ld", (long)_shop.result.owner.owner_id]];
                break;
            }
                
            default:
                break;
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
                if (_isaddressexpanded) {
                    _isaddressexpanded = NO;
                    [_buttonArrowLocation setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
                } else {
                    _isaddressexpanded = YES;
                    [_buttonArrowLocation setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateNormal];
                }
                [self setDetailFrame];
                break;
            }
            case 14:
            {
                //expand location
                if (_isaddressexpanded) {
                    _isaddressexpanded = NO;
                    [_buttonArrowLocation setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateNormal];
                } else {
                    _isaddressexpanded = YES;
                    [_buttonArrowLocation setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateNormal];
                }
                [self setDetailFrame];
                break;
            }
            case 11:
            {
                //favorited button action
                ShopFavoritedViewController *vc = [ShopFavoritedViewController new];
                vc.data = @{kTKPDDETAIL_APISHOPIDKEY : _shop.result.info.shop_id?:@"",
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
                NSString *userId = [NSString stringWithFormat:@"%d",_shop.result.owner.owner_id];
                NavigateViewController *navigateController = [NavigateViewController new];
                [navigateController navigateToProfileFromViewController:self withUserID:userId];
                
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
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                ShopEditViewController *vc = [ShopEditViewController new];
                vc.data = @{
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDDETAIL_DATASHOPSKEY : _shop.result?:@{}
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
        
    }
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Table Shipment
    if (tableView == _tableshipment)
    {
        #ifdef kTKPDSHOPINFO_NODATAENABLE
            return _isnodata ? 1 : _shop.result.shipment.count;
        #else
            return _isnodata ? 0 : _shop.result.shipment.count;
        #endif
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tableshipment) {
        // Table Shipment
        NSArray *packages = ((Shipment *)[_shop.result.shipment objectAtIndex:section]).shipment_package;
#ifdef kTKPDSHOPINFO_NODATAENABLE
        return _isnodata ? 1 : packages.count;
#else
        return _isnodata ? 0 : packages.count;
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
            
            Shipment *shipment = _shop.result.shipment[indexPath.section];
            ((ShopInfoShipmentCell*)cell).labelshipment.text = shipment.shipment_name;
            ShipmentPackage *package = [shipment.shipment_package objectAtIndex:indexPath.row];
            ((UILabel*)((ShopInfoShipmentCell*)cell).packageLabel).text = package.product_name;
            
            NSLog(@"\n\n%zd %zd %@\n\n", indexPath.section, indexPath.row, package.product_name);
            
            if (indexPath.row > 0) {
                ((UILabel*)((ShopInfoShipmentCell*)cell).labelshipment).hidden = YES;
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

-(void)updateShopPicture:(NSNotification*)notif
{
    NSDictionary *userInfo = notif.userInfo;
    
    NSString *strAvatar = [userInfo objectForKey:@"file_th"]?:@"";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strAvatar]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_thumb setImageWithURLRequest:request
                          placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                       //NSLOG(@"thumb: %@", thumb);
                                       [_thumb setImage:image];
#pragma clang diagnostic pop
                                   } failure: nil];
}

-(void)setShopInfoData
{
    _labelshopname.text = _shop.result.info.shop_name;
//    _labelshoptagline.text = _shop.result.info.shop_tagline;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:13],
                                 NSParagraphStyleAttributeName  : style
                                 };
    
    NSString *tagline = _shop.result.info.shop_tagline;
    _labelshoptagline.attributedText = [[NSAttributedString alloc] initWithString:tagline
                                                                       attributes:attributes];
    _labelshoptagline.numberOfLines = 0;
    [_labelshoptagline sizeToFit];
    
    _labelshopdescription.text = _shop.result.info.shop_description;
    [_buttonfav setTitle:_shop.result.info.shop_total_favorit forState:UIControlStateNormal];
    [_buttonitemsold setTitle:_shop.result.stats.shop_item_sold forState:UIControlStateNormal];
//    _speedrate.starscount = _shop.result.stats.shop_service_rate;
//    _accuracyrate.starscount = _shop.result.stats.shop_accuracy_rate;
//    _servicerate.starscount = _shop.result.stats.shop_service_rate;
    _labellocation.text = _shop.result.info.shop_location;
    _labellastlogin.text = _shop.result.info.shop_owner_last_login;
    _labelopensince.text = _shop.result.info.shop_open_since;
    _nameowner.text = _shop.result.owner.owner_name;
    NSInteger totallocation = _shop.result.address.count;
    
    [_buttonofflocation setTitle:[NSString stringWithFormat:@"%zd Offline", totallocation] forState:UIControlStateNormal];
    
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
    [_avatarIndicator startAnimating];
    [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        [_avatarIndicator stopAnimating];
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
    }];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.owner.owner_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    thumb = _thumbowner;
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

}

-(void)setDetailFrame
{
    CGFloat height = 0;
    
    [_containerview layoutIfNeeded];
    
    [_labelshopdescription sizeToFit];
    
    height += _labelshopdescription.frame.origin.y + 18;
    
    [_labelshopdescription layoutIfNeeded];
    CGRect shopDetailFrame = _shopdetailview.frame;
    shopDetailFrame.origin.y = height;
    
    if (_isaddressexpanded) {
        
        [_shopdetailview layoutIfNeeded];
        [_addressoffview layoutIfNeeded];
        
        CGFloat totalHeight = 0;
        NSArray * addresses = _shop.result.address;
        for (int i = 0; i < addresses.count; i++) {
            Address *address = [addresses objectAtIndex:i];
            ShopInfoAddressView *addressView = [ShopInfoAddressView newview];
            [self setAddressDataView:addressView withData:address];
            _addressoffview.hidden = NO;
            [_addressoffview addSubview:addressView];

            [addressView layoutIfNeeded];
            CGRect addressFrame = addressView.frame;
            addressFrame.origin.x -= 15;
            addressFrame.origin.y = totalHeight;
            addressFrame.size.height = addressView.horizontalBorder.frame.origin.y;
            addressView.frame = addressFrame;
            
            totalHeight += addressFrame.size.height;
            
        }
        
        CGRect newAddressFrame = _addressoffview.frame;
        newAddressFrame.size.height = totalHeight;
        _addressoffview.frame = newAddressFrame;
        
        shopDetailFrame.size.height += newAddressFrame.size.height;

    } else {
        shopDetailFrame.size.height -= _addressoffview.frame.size.height;
    }
    
    _shopdetailview.frame = shopDetailFrame;
    
    height += _shopdetailview.frame.size.height;

    [_transactionview layoutIfNeeded];
    CGRect transactionViewFrame = _transactionview.frame;
    transactionViewFrame.origin.y = height;
    _transactionview.frame = transactionViewFrame;
    
    height += _transactionview.frame.size.height;

    [_tableshipment layoutIfNeeded];
    CGRect shipmentViewFrame = _shipmentview.frame;
    shipmentViewFrame.origin.y = height;
    NSInteger numberOfShipments = 0;
    for (int i = 0; i < _shop.result.shipment.count; i++) {
        NSArray *packages = ((Shipment *)[_shop.result.shipment objectAtIndex:i]).shipment_package;
        numberOfShipments += packages.count;
    }
    shipmentViewFrame.size.height = (numberOfShipments * 43) + 48;
    _shipmentview.frame = shipmentViewFrame;
    
    height += _shipmentview.frame.size.height;
    
    [_tablepayment layoutIfNeeded];
    CGRect paymentViewFrame = _paymentview.frame;
    paymentViewFrame.origin.y = height;
    NSInteger numberOfPaymets = _shop.result.payment.count;
    paymentViewFrame.size.height = (numberOfPaymets * 43) + 43;
    _paymentview.frame = paymentViewFrame;
    
    height += _paymentview.frame.size.height;
    
    CGRect ownerViewFrame = _ownerview.frame;
    ownerViewFrame.origin.y = height;
    _ownerview.frame = ownerViewFrame;
    
    height += _ownerview.frame.size.height;
    
    CGRect containerViewFrame = _containerview.frame;
    containerViewFrame.size.height = height;
    _containerview.frame = containerViewFrame;
    
    _scrollview.contentSize = CGSizeMake(self.view.frame.size.width, height);
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, -130, 0);

}

-(void)setAddressDataView:(ShopInfoAddressView*)view withData:(id)data
{
    Address *address = data;
    view.labelname.text = (address.location_address == 0) ? @"-" : [NSString convertHTML:address.location_address];
    view.labelDistric.text = (address.location_district_name == 0) ? @"-" : address.location_district_name;
    view.labelcity.text = (address.location_city_name ==0) ? @"-" : address.location_city_name;
    view.labelprov.text = (address.location_province_name ==0) ? @"-" : address.location_province_name;
    view.labelpostal.text = (address.location_postal_code ==0) ? @"-" : address.location_postal_code;
    view.labelemail.text = (address.location_email ==0) ? @"-" : address.location_email;
    view.labelfax.text = ([address.location_fax isEqualToString:@"0"]) ? @"-" : address.location_fax;
    view.labelphone.text = (address.location_phone ==0) ? @"-" : address.location_phone;
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
        
        NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
        NSInteger shop_id = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
        if ([_shop.result.info.shop_id integerValue]==shop_id)
        {
            UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Ubah" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
            [barbutton setTintColor:[UIColor whiteColor]];
            barbutton.tag = 11;
            self.navigationItem.rightBarButtonItem = barbutton;
        }
    }
}



#pragma mark - Method
- (IBAction)actionLihatDetailStatistik:(id)sender {
    DetailStatisticViewController *detailStatisticViewController = [DetailStatisticViewController new];
    detailStatisticViewController.detailShopResult = _shop.result;
    [self.navigationController pushViewController:detailStatisticViewController animated:YES];
}
@end
