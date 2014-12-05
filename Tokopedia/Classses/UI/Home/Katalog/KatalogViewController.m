//
//  KatalogViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "katalog.h"
#import "KatalogViewCell.h"
#import "KatalogViewController.h"

@interface KatalogViewController ()
{
    NSMutableArray *_product;
    NSMutableDictionary *_paging;
    NSString *_query;
    
    BOOL _isnodata;
    
    NSInteger _page;
    NSInteger _limit;
    
    //__weak AFHTTPRequestOperation *_request;
}

@property (strong, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footerview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *headersectionview;

@end

@implementation KatalogViewController

#pragma mark - Initialization
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
    
    UIBarButtonItem * barbutton;
    NSBundle* bundle = [NSBundle mainBundle];
    //UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"navigation-chevron" ofType:@"png"]];
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
    //    UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    barbutton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //}
    //else
    //    barbutton = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    //
    //[barbutton setTag:10];
    //self.navigationItem.leftBarButtonItem = barbutton;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _product = [NSMutableArray new];
    _paging = [NSMutableDictionary new];
    
    _limit = kTKPDKATALOG_LIMITPAGE;
    
    [self setDataQuery:_data];
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    _isnodata = NO;
    
    //[self request:YES withrefreshControl:nil];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    
    [_table addSubview:refresh];
    
    _table.tableHeaderView = _headerview;
    
}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem* btn = (UIBarButtonItem*)sender;
        
        switch (btn.tag) {
            case 10:
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            default:
                break;
        }
    }
    else if([sender isKindOfClass:[UIButton class]])
    {
        UIButton *btn = (UIButton*)sender;

        switch (btn.tag) {
            case 10:
                
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}


#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDPRODUCTLISTHOTLIST_NODATAENABLE
    return _isnodata ? 1 : _product.count;
#else
    return _isnodata ? 0 : _product.count;
#endif
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDKATALOGCELL_IDENTIFIER;
		
		cell = (KatalogViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [KatalogViewCell newcell];
			//((KatalogViewCell*)cell).delegate = self;
		}
		
		if (_product.count > indexPath.row) {
            
            NSArray *product = _product;
            
            ((KatalogViewCell*)cell).data = @{kTKPDKATALOG_DATAINDEXPATHKEY: indexPath, kTKPDKATALOG_DATACOLUMNSKEY: product[indexPath.row]};
            
		}
        
	} else {
		static NSString *CellIdentifier = kTKPDKATALOG_STANDARDTABLEVIEWCELLIEDNTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = kTKPDKATALOG_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDKATALOG_NODATACELLDESCS;
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
		
        NSString *urinext = [_paging objectForKey:kTKPDKATALOG_APIURINEXTDATA];
        if (urinext != NULL && ![urinext isEqualToString:@""]) {
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            //[self request:NO withrefreshControl:nil];
        }
	}
}

#pragma mark - Properties
-(void)setDataQuery:(NSDictionary *)data
{
    if (data) {
        NSDictionary *column = [_data objectForKey:@"column"];
        _query = [column objectForKey:@"title"];
    }
}

#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    _page = 1;

}



@end
