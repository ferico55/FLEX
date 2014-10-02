//
//  CatalogSellerViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "sortfiltershare.h"

#import "Catalog.h"

#import "SortViewController.h"
#import "FilterViewController.h"

#import "DetailProductViewController.h"

#import "CatalogSellerViewController.h"
#import "CatalogSellerHeaderView.h"
#import "CatalogSellerCell.h"

@interface CatalogSellerViewController ()<UITableViewDelegate, UITableViewDataSource,CatalogSellerCellDelegate>
{
    NSMutableArray *_shops;
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

- (IBAction)tap:(id)sender;

@end

#pragma mark - Catalog Seller View
@implementation CatalogSellerViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _shops = [NSMutableArray new];
    
    NSArray *shops = [_data objectForKey:kTKPDDETAIL_DATASHOPSKEY]?:@[];
    
    [_shops addObjectsFromArray:shops];
    
    if (_shops>0) {
        _isnodata = NO;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Tableview Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 96;
}

#pragma mark - Tableview Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _shops.count;
#else
    return _isnodata ? 0 : _shops.count;
#endif
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    CatalogShops *shops = _shops[section];
#ifdef kTKPDPRODUCTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : shops.product_list.count;
#else
    return _isnodata ? 0 : shops.product_list.count;
#endif
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CatalogShops *shops = _shops[section];
    
    CatalogSellerHeaderView *v = [CatalogSellerHeaderView newview];
    v.namelabel.text = shops.shop_name;
    v.locationlabel.text = shops.shop_location;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shops.shop_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = v.thumb;
    
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    return v;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDCATALOGSELLERCELL_IDENTIFIER;
		
		cell = (CatalogSellerCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [CatalogSellerCell newcell];
			((CatalogSellerCell*)cell).delegate = self;
		}
        
        CatalogShops *shops = _shops[indexPath.section];
        if (shops.product_list.count>indexPath.row){
            ((CatalogSellerCell*)cell).namelabel.text = [shops.product_list[indexPath.row]objectForKey:kTKPDDETAILCATALOG_APIPRODUCTNAMEKEY];
            ((CatalogSellerCell*)cell).pricelabel.text = [shops.product_list[indexPath.row]objectForKey:kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY];
            ((CatalogSellerCell*)cell).conditionlabel.text = [shops.product_list[indexPath.row]objectForKey:kTKPDDETAILCATALOG_APIPRODUCTCONDITIONKEY];
            ((CatalogSellerCell*)cell).product_id = [[shops.product_list[indexPath.row]objectForKey:kTKPDDETAILCATALOG_APIPRODUCTIDKEY] integerValue];
        }
        
	} else {
		static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIEDNTIFIER;
		
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

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                // Action Urutkan Button
                SortViewController *vc = [SortViewController new];
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:kTKPDFILTER_DATATYPEDETAILCATALOGVIEWKEY};
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 11:
            {
                // Action Filter Button
                FilterViewController *vc = [FilterViewController new];
                vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:kTKPDFILTER_DATATYPEDETAILCATALOGVIEWKEY};
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 12:
            {
                // action share button
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Cell Delegate
-(void)CatalogSellerCell:(UITableViewCell *)cell
{
    DetailProductViewController *vc = [DetailProductViewController new];
    vc.data = @{kTKPDDETAIL_APIPRODUCTIDKEY : @(((CatalogSellerCell*)cell).product_id)};
    [self.navigationController pushViewController:vc animated:YES];
}


@end
