//
//  ProfileBiodataViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"

#import "ProfileInfo.h"
#import "ProfileBiodataViewController.h"

#import "ProfileBiodataCell.h"
#import "ProfileBiodataShopCell.h"

@interface ProfileBiodataViewController ()<UITableViewDataSource, UITableViewDelegate, ProfileBiodataShopCellDelegate>
{
    BOOL _isnodatashop;
    
    ProfileInfo *_profileinfo;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@end

@implementation ProfileBiodataViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodatashop = YES;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _table.tableFooterView = _footer;
    
    // add notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil];

}

#pragma mark  What will be the height of the section, Make it dynamic

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_isnodatashop) {
        if (indexPath.section == 0) {
            //height shop
            return 200;
        }
        else
            //height biodata
            return 200;
    }
    else
        //height biodata
        return 200;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isnodatashop)return 2;
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    // Configure the cell...
    if (!_isnodatashop) {
        if (indexPath.section == 0) {
            NSString *cellid = kTKPDPROFILEBIODATACELLIDENTIFIER;
            cell = (ProfileBiodataShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ProfileBiodataShopCell newcell];
                ((ProfileBiodataShopCell*)cell).delegate = self;
            }
            ((ProfileBiodataShopCell*)cell).labelname.text = _profileinfo.result.shop_info.shop_name;
            ((ProfileBiodataShopCell*)cell).labellocation.text = _profileinfo.result.shop_info.shop_location;
            ((ProfileBiodataShopCell*)cell).rateaccuracy.starscount = _profileinfo.result.shop_stats.shop_accuracy_rate;
            ((ProfileBiodataShopCell*)cell).rateservice.starscount = _profileinfo.result.shop_stats.shop_service_rate;
            ((ProfileBiodataShopCell*)cell).ratespeed.starscount = _profileinfo.result.shop_stats.shop_speed_rate;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_profileinfo.result.user_info.user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            
            UIImageView *thumb = ((ProfileBiodataShopCell*)cell).thumb;
            UIActivityIndicatorView *act = ((ProfileBiodataShopCell*)cell).act;
            
            thumb = [UIImageView circleimageview:thumb];
            
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [act startAnimating];
            
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                [act stopAnimating];
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
            }];

            return cell;
        }
        if (indexPath.section == 1) {
            NSString *cellid = kTKPDPROFILEBIODATASHOPCELLIDENTIFIER;
            cell = (ProfileBiodataCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ProfileBiodataCell newcell];
                [self ProfileBiodataShopCell:cell withtableview:tableView];
            }
            return cell;
        }
    }
    else
    {
        if (indexPath.section == 0) {
            NSString *cellid = kTKPDPROFILEBIODATASHOPCELLIDENTIFIER;
            cell = (ProfileBiodataShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ProfileBiodataCell newcell];
            }
            [self ProfileBiodataShopCell:cell withtableview:tableView];
            return cell;
        }
    }
    return cell;
}

-(void)ProfileBiodataShopCell:(UITableViewCell*)cell withtableview:(UITableView*)tableView
{
    ((ProfileBiodataCell*)cell).labelbirth.text = @"-";
    ((ProfileBiodataCell*)cell).labelgender.text = @"-";
    ((ProfileBiodataCell*)cell).labelhobbies.text = _profileinfo.result.user_info.user_hobbies?:@"-";
}

#pragma mark - Cell Delegate
-(void)ProfileBiodataShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    
}

#pragma mark - Notification
- (void)updateView:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    _profileinfo = userinfo;
    _isnodatashop = ((_profileinfo.result.shop_info)||(_profileinfo.result.shop_stats))?NO:YES;
    [_table reloadData];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
