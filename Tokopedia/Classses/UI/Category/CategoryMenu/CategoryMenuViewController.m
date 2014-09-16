//
//  CategoryMenuViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DBManager.h"
#import "category.h"
#import "CategoryMenuViewCell.h"
#import "CategoryMenuViewController.h"

@interface CategoryMenuViewController () <CategoryMenuViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *menu;

@end

@implementation CategoryMenuViewController{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /** create new **/
    _paging = [NSMutableDictionary new];
    _menu = [NSMutableArray new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    if (self.navigationController.viewControllers.count==1) {
        img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
            UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        }
        else
            barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        
        [barbutton1 setTag:11];
        self.navigationItem.rightBarButtonItem = barbutton1;
    }
    
    /** set max data per page request **/
    _limit = kTKPDCATEGORYRESULT_LIMITPAGE;
    
    /** set inset table for different size**/
    //if (is4inch) {
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 120;
    //    _table.contentInset = inset;
    //}
    //else{
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 240;
    //    _table.contentInset = inset;
    //}
    
    _table.delegate = self;
    _table.dataSource = self;
    
    /** Set isnull value (title and icon for category) **/
    NSInteger parentid = [[_data objectForKey:@"d_id"]integerValue];
    NSArray *data = [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%d\" order by weight",parentid]];
    
    [_menu addObjectsFromArray:data];
    
    /** ceck is have a child or not **/
    for (int i = 0 ; i<_menu.count; i++) {
        NSInteger childparentid = [_menu[i][@"id"]integerValue];
        NSArray * data= [[DBManager getSharedInstance]LoadDataQueryDepartement:[NSString stringWithFormat:@"select d_id,name,tree from ws_department where parent=\"%d\" order by weight",childparentid]];
        if (data == nil || data.count == 0) {
            [_menu[i] setObject:@(YES) forKey:@"isnullchild"];
        }
        else
            [_menu[i] setObject:@(NO) forKey:@"isnullchild"];
    }
    /** **/
    
    if (_menu.count > 0) {
        _isnodata = NO;
    }
    
    /** adjust refresh control **/
    //[self request:YES withrefreshControl:nil];
    //UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    //refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    //[refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    //[_hotlisttable addSubview:refresh];
    
    //[self configureRestKit];
    //[self loadVenues];
    
    
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    
    [_menu removeAllObjects];
    [_paging removeAllObjects];
    [_table reloadData];
    //static dispatch_once_t onceToken;
    
    //dispatch_once (&onceToken, ^{
    //[self request:YES withrefreshControl:refresh];
    //});
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                if (self.navigationController.viewControllers.count>1) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                break;
            }
            case 11:
            {
                CategoryMenuViewController *vc = [CategoryMenuViewController new];
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
#ifdef kTKPDmenuLISTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _menu.count;
#else
    return _isnodata ? 0 : _menu.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDCATEGORYRESULTVIEWCELL_IDENTIFIER;
		
		cell = (CategoryMenuViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [CategoryMenuViewCell newcell];
			((CategoryMenuViewCell*)cell).delegate = self;
		}

        ((CategoryMenuViewCell*)cell).data = @{kTKPDCATEGORY_DATAINDEXPATHKEY: indexPath, kTKPDCATEGORY_DATACOLUMNSKEY: _menu[indexPath.row]};
        
	} else {
		static NSString *CellIdentifier = kTKPDCATEGORY_STANDARDTABLEVIEWCELLIEDNTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
        
		cell.textLabel.text = kTKPDCATEGORY_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDCATEGORY_NODATACELLDESCS;
	}
	
	return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
		
        if (_urinext != NULL && ![_urinext isEqualToString:@""]) {
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            //[self request:NO withrefreshControl:nil];
        }
	}
}


#pragma mark - Cell Delegate
-(void)CategoryMenuViewCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath{
    if([[_menu[indexpath.row] objectForKey:@"isnullchild"] isEqual:@(0)]){
        CategoryMenuViewController *vc = [CategoryMenuViewController new];
        vc.data = @{kTKPDCATEGORY_DATADIDKEY:[_menu[indexpath.row] objectForKey:@"id"]};
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        NSArray *array = [self.navigationController viewControllers];
        [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
    }
}

@end
