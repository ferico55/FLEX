//
//  SettingAddressViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "SettingAddressCell.h"
#import "SettingAddressViewController.h"

@interface SettingAddressViewController ()<UITableViewDataSource, UITableViewDelegate, SettingAddressCellDelegate>
{
    BOOL _isnodata;
    NSMutableArray *_list;
}

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailure:(id)object;
-(void)requestProcess:(id)object;
-(void)requestTimeout;

@end

@implementation SettingAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationItem setTitle:kTKPDPROFILESETTINGADDRESS_TITLE];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDSETTINGADDRESSCELL_IDENTIFIER;
		
		cell = (SettingAddressCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SettingAddressCell newcell];
			((SettingAddressCell*)cell).delegate = self;
		}
        
        //if (_list.count > indexPath.row) {
        //    ListFavoriteShop *list = _list[indexPath.row];
        //    ((ProfileFavoriteShopCell*)cell).label.text = list.shop_name;
        //    ((ProfileFavoriteShopCell*)cell).indexpath = indexPath;
        //    NSString *urlstring = list.shop_image;
        //    
        //    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //    
        //    UIImageView *thumb = (UIImageView*)((ProfileFavoriteShopCell*)cell).thumb;
        //    thumb = [UIImageView circleimageview:thumb];
        //    
        //    thumb.image = nil;
        //    
        //    UIActivityIndicatorView *act = (UIActivityIndicatorView*)((ProfileFavoriteShopCell*)cell).act;
        //    [act startAnimating];
        //    
        //    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        //#pragma clang diagnostic push
        //#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //        //NSLOG(@"thumb: %@", thumb);
        //        [thumb setImage:image];
        //        
        //        [act stopAnimating];
        //#pragma clang diagnostic pop
        //        
        //    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //        [act stopAnimating];
        //    }];
        //}
        
		return cell;
//    } else {
//        static NSString *CellIdentifier = kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER;
//        
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        
//        cell.textLabel.text = kTKPDPROFILE_NODATACELLTITLE;
//        cell.detailTextLabel.text = kTKPDPROFILE_NODATACELLDESCS;
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
//        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
//            /** called if need to load next page **/
//            //NSLog(@"%@", NSStringFromSelector(_cmd));
//            [self configureRestKit];
//            [self loadData];
//        }
	}
}


#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}


#pragma mark - Cell Delegate
-(void)SettingAddressCellDelegate:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{

}

@end
