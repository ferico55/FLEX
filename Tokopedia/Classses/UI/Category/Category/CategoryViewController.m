//
//  CategoryViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "category.h"
#import "search.h"
#import "DBManager.h"
#import "CategoryViewController.h"
#import "CategoryViewCell.h"
#import "CategoryResultViewController.h"
#import "TKPDTabNavigationController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

@interface CategoryViewController () <CategoryViewCellDelegate>
{
    NSMutableArray *_category;
}

@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation CategoryViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CategoryViewController" bundle:nibBundleOrNil];
    if (self) {
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** set inset table for different size**/
    //if (is4inch) {
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 150;
    //    _table.contentInset = inset;
    //}
    //else{
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 200;
    //    _table.contentInset = inset;
    //}
    
    /** Initialization variable **/
    _category = [NSMutableArray new];
    
    /** Set title and icon for category **/
    //NSInteger parentid = 0;
   // NSArray *data = [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name from ws_department where parent=\"%d\" order by weight",parentid]];
    NSArray *titles = kTKPDCATEGORY_TITLEARRAY;
    NSArray *dataids = kTKPDCATEGORY_IDARRAY;
    
    for (int i = 0; i<22; i++) {
        NSString * imagename = [NSString stringWithFormat:@"icon_%d",i];
        [_category addObject:@{kTKPDCATEGORY_DATATITLEKEY : titles[i], kTKPDCATEGORY_DATADIDKEY : dataids[i],kTKPDCATEGORY_DATAICONKEY:imagename}];
    }
    
}



#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}


#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //TODO: change to more flexible counting
    return (_category.count+2)/3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    NSString *cellid = kTKPDCATEGORYVIEWCELL_IDENTIFIER;
    
    cell = (CategoryViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [CategoryViewCell newcell];
        ((CategoryViewCell*)cell).delegate = self;
    }
    
    /** Flexible view count **/ //TODO::sederhanakan
    NSInteger countdata;
    if (_category.count > indexPath.row) {
        if (_category.count % 3 == 0 || indexPath.row != ([_category count] - 1) / 3) {
            countdata = 3;
        }
        else {
            countdata = [_category count] % 3;
        }
        
        NSArray *tempArray = [_category objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(indexPath.row* 3, countdata)]];
        
//    NSArray *itemsForView;
//    NSUInteger kItemsPerView = 3;
//    NSUInteger startIndex = indexPath.row * kItemsPerView;
//    NSUInteger count = MIN( _category.count - startIndex, kItemsPerView );
//    if ((_category.count/3) > indexPath.row &&!((_category.count-1)/3+1 == indexPath.row+1))
//        itemsForView = [_category subarrayWithRange: NSMakeRange( startIndex, count)];
//    else if((_category.count-1)/3+1 == indexPath.row+1){
//        if (_category.count%3==0) {
//            itemsForView = [_category subarrayWithRange: NSMakeRange( startIndex, count)];
//        }
//        else if (_category.count%3==2)
//        {
//            itemsForView = [_category subarrayWithRange: NSMakeRange( startIndex, 2)];
//        }
//        else
//            itemsForView = @[_category[_category.count-1]];
//    }
    
    ((CategoryViewCell*)cell).data = @{kTKPDCATEGORY_DATAINDEXPATHKEY: indexPath, kTKPDCATEGORY_DATACOLUMNSKEY: tempArray};
        
	}
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Delegate Cell
-(void)CategoryViewCellDelegateCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    NSInteger index = indexpath.section+3*(indexpath.row);
    
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc1.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *c = [TKPDTabNavigationController new];
    [c setData:@{kTKPDCATEGORY_DATATYPEKEY: @(kTKPDCATEGORY_DATATYPECATEGORYKEY), kTKPDSEARCH_APIDEPARTEMENTIDKEY : [_category[index] objectForKey:kTKPDSEARCH_APIDIDKEY]?:@""}];
    [c setSelectedIndex:0];
    [c setViewControllers:viewcontrollers];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
    [nav.navigationBar setTranslucent:NO];
    [self.navigationController presentViewController:nav animated:YES completion:nil];

    
//    CategoryResultViewController *vc = [CategoryResultViewController new];
//    UINavigationController *nav =[[UINavigationController alloc]initWithRootViewController:vc];
//    [nav.navigationBar setTranslucent:NO];
//    NSInteger index = indexpath.section+3*(indexpath.row);
//    vc.data = @{@"d_id" : _category[index][@"d_id"]};
//    [self.navigationController presentViewController:nav animated:YES completion:^{
//        nil;
//    }];
}

@end
