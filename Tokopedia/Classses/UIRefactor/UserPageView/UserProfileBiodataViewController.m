//
//  UserProfileBiodataViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "UserProfileBiodataViewController.h"
#import "UserPageHeader.h"
#import "ProfileInfo.h"
#import "ProfileBiodataShopCell.h"
#import "ProfileBiodataCell.h"

#import "detail.h"

@interface UserProfileBiodataViewController () <UserPageHeaderDelegate, ProfileBiodataShopCellDelegate, UIScrollViewDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *fakeStickyTab;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation UserProfileBiodataViewController {
    ProfileInfo *_profile;
    UserPageHeader *_userHeader;
    BOOL _isnodatashop;
    BOOL isNotMyBiodata;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userHeader = [UserPageHeader new];
    _userHeader.delegate = self;
    _userHeader.data = _data;

    _header = _userHeader.view;
    _table.tableHeaderView = _header;
    _table.tableFooterView = _footer;
    _table.delegate = self;
    
    [self initNotification];
    
    UIView *btmGreenLine = (UIView *)[_header viewWithTag:19];
    [btmGreenLine setHidden:NO];
    _stickyTab = [(UIView *)_header viewWithTag:18];
    
    // add notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateView:) name:kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY object:nil];
    [nc addObserver:self selector:@selector(updateProfilePicture:) name:kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Profile - Profile Information";
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInfoProfileScroll:)
                                                 name:@"updateInfoProfileScroll" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UserPageHeader Delegate
- (void)didReceiveProfile:(ProfileInfo *)profile {
    _profile = profile;
    [_table reloadData];
}

- (void)didLoadImage:(UIImage *)image {
    
}

- (id)didReceiveNavigationController {
    return nil;
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}



#pragma mark  What will be the height of the section, Make it dynamic

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_isnodatashop) {
        if (indexPath.section == 0) {
            //height shop
            return 130;
        }
        else
            //height biodata
            return 120;
    }
    else
        //height biodata
        return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_isnodatashop) {
        if(isNotMyBiodata)
            return 1;
        else
            return 2;
    }
    else return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 40)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.view.frame.size.width, 40)];
    titleLabel.font = [UIFont fontWithName:@"GothamBook" size:13];
    if(section == 0 ) {
        if(_profile.result.shop_info) {
            titleLabel.text = kTKPDTITLE_SHOP_INFO;
            [headerView addSubview:titleLabel];
            return headerView;
        } else {
            return nil;
        }

    } else if (section == 1) {
        titleLabel.text = KTKPDTITLE_BIODATA;
        [headerView addSubview:titleLabel];
        return headerView;
    }
    
    return nil;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_profile.result.shop_info) {
        if(section == 0) {
            return 0;
        }
    }

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
                ((ProfileBiodataShopCell *)cell).labelname.userInteractionEnabled = YES;
                [((ProfileBiodataShopCell *)cell).labelname addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionGoToUserProfile:)]];
            }
            ((ProfileBiodataShopCell*)cell).labelname.text = _profile.result.shop_info.shop_name;
            
            [((ProfileBiodataShopCell*)cell).buttonName setTitle:_profile.result.shop_info.shop_name forState:UIControlStateNormal];
            
            ((ProfileBiodataShopCell*)cell).labellocation.text = _profile.result.shop_info.shop_location;
            ((ProfileBiodataShopCell*)cell).rateaccuracy.starscount = _profile.result.shop_stats.shop_accuracy_rate;
            ((ProfileBiodataShopCell*)cell).rateservice.starscount = _profile.result.shop_stats.shop_service_rate;
            ((ProfileBiodataShopCell*)cell).ratespeed.starscount = _profile.result.shop_stats.shop_speed_rate;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_profile.result.shop_info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            
            UIImageView *thumb = ((ProfileBiodataShopCell*)cell).thumb;
            UIActivityIndicatorView *act = ((ProfileBiodataShopCell*)cell).act;
            
            thumb = [UIImageView circleimageview:thumb];
            
            thumb.image = nil;
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            [act startAnimating];
            
            [thumb setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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
    ((ProfileBiodataCell*)cell).labelbirth.text = _profile.result.user_info.user_birth?:@"-";
    ((ProfileBiodataCell*)cell).labelhobbies.text = (_profile.result.user_info.user_hobbies == nil || [_profile.result.user_info.user_hobbies isEqualToString:@"0"])?@"-":_profile.result.user_info.user_hobbies;
}


#pragma mark - Method
- (void)actionGoToUserProfile:(id)sender
{
    //    if(self.navigationController.viewControllers.count > 1) {
    //        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3] animated:YES];
    //    }
}

#pragma mark - Cell Delegate
-(void)ProfileBiodataShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    
}

#pragma mark - Notification
- (void)updateView:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    _profile = userinfo;
    _isnodatashop = ((_profile.result.shop_info)||(_profile.result.shop_stats))?NO:YES;
    [_table reloadData];
}

- (void)updateProfilePicture:(NSNotification *)notification
{
    UIImage *profilePicture = [notification.userInfo objectForKey:@"profile_img"];
    _userHeader.profileImage.image = profilePicture;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isFakeStickyVisible = scrollView.contentOffset.y > (_header.frame.size.height - _stickyTab.frame.size.height);
    
    if(isFakeStickyVisible) {
        _fakeStickyTab.hidden = NO;
    } else {
        _fakeStickyTab.hidden = YES;
    }
    [self determineOtherScrollView:scrollView];
}

- (void)determineOtherScrollView:(UIScrollView *)scrollView {
    NSDictionary *userInfo = @{@"y_position" : [NSNumber numberWithFloat:scrollView.contentOffset.y]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteShopScroll" object:nil userInfo:userInfo];
}


- (void)updateInfoProfileScroll:(NSNotification *)notification
{
    id userinfo = notification.userInfo;
    float ypos;
    if([[userinfo objectForKey:@"y_position"] floatValue] < 0) {
        ypos = 0;
    } else {
        ypos = [[userinfo objectForKey:@"y_position"] floatValue];
    }
    
    CGPoint cgpoint = CGPointMake(0, ypos);
    _table.contentOffset = cgpoint;
    
}


@end
