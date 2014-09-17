//
//  HotlistResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "HotlistDetail.h"
#import "SearchResult.h"
#import "List.h"

#import "home.h"
#import "HotlistResultViewCell.h"
#import "HotlistResultViewController.h"

@interface HotlistResultViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIScrollView *hashtagsscrollview;

@property (nonatomic, strong) NSMutableArray *product;

@end

@implementation HotlistResultViewController
{
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger _viewposition;
    
    //NSMutableArray *_hotlist;
    NSMutableDictionary *_paging;
    NSMutableArray *_buttons;
    NSMutableDictionary *_detailhotlist;
    
    /** url to the next page **/
    NSString *_urinext;
    
    BOOL _isnodata;
    
    UIRefreshControl *_refreshControl;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // set title navigation
    NSString * title = [_data objectForKey:kTKPDHOME_DATATITLEKEY];
    self.navigationItem.title = title;
    
    // create initialitation
    _paging = [NSMutableDictionary new];
    _product = [NSMutableArray new];
    _detailhotlist = [NSMutableDictionary new];
    
    // set max data per page request
    _limit = kTKPDHOMEHOTLISTRESULT_LIMITPAGE;
    
    _page = 1;
    
    /** set inset table for different size**/
    //if (is4inch) {
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 150;
    //    _table.contentInset = inset;
    //}
    //else{
    //    UIEdgeInsets inset = _table.contentInset;
    //    inset.bottom += 240;
    //    _table.contentInset = inset;
    //}
    
    _table.tableHeaderView = _header;
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
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
    
    // adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    [self configureRestKit];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = (_product.count%2==0)?_product.count/2:_product.count/2+1;
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDHOTLISTRESULTVIEWCELL_IDENTIFIER;
		
		cell = (HotlistResultViewCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [HotlistResultViewCell newcell];
			((HotlistResultViewCell*)cell).delegate = self;
		}
		
        /** Flexible view count **/
		NSUInteger indexsegment = indexPath.row * 2;
		NSUInteger indexmax = indexsegment + 2;
		NSUInteger indexlimit = MIN(indexmax, _product.count);
		
		NSAssert(!(indexlimit > _product.count), @"producs out of bounds");
		
		NSUInteger i;
		
		for (i = 0; (indexsegment + i) < indexlimit; i++) {
            List *list = [_product objectAtIndex:indexsegment + i];
            ((UIView*)((HotlistResultViewCell*)cell).viewcell[i]).hidden = NO;
            (((HotlistResultViewCell*)cell).indexpath) = indexPath;
            
            ((UILabel*)((HotlistResultViewCell*)cell).labelprice[i]).text = list.catalog_price?:list.product_price;
            ((UILabel*)((HotlistResultViewCell*)cell).labeldescription[i]).text = list.catalog_name?:list.product_name;
            ((UILabel*)((HotlistResultViewCell*)cell).labelalbum[i]).text = list.shop_name?:@"";
            
            NSString *urlstring = list.catalog_image?:list.product_image;
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
            
            UIImageView *thumb = (UIImageView*)((HotlistResultViewCell*)cell).thumb[i];
            thumb.image = nil;
            
            UIActivityIndicatorView *act = (UIActivityIndicatorView*)((HotlistResultViewCell*)cell).act[i];
            [act startAnimating];
            
            NSLog(@"============================== START GET IMAGE =====================");
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
                
                [act stopAnimating];
                NSLog(@"============================== DONE GET IMAGE =====================");
#pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
                
                NSLog(@"============================== DONE GET IMAGE =====================");
            }];
        }
	} else {
		static NSString *CellIdentifier = kTKPDHOME_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = kTKPDHOME_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDHOME_NODATACELLDESCS;
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
		
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self loadData];
        }
	}
}

#pragma mark - Action View
-(IBAction)tap:(id)sender{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        switch (button.tag) {
            case 10:
                //BACK
                if ([_data objectForKey:kTKPDHOME_DATAISSEARCHHOTLISTKEY]) {
                    //dissmis if parent view controller from search
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                else
                    // pop if parent view controller from hotlist (home)
                    [self.navigationController popViewControllerAnimated:YES];
                break;
                
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        // buttons tag >=20 are tags untuk hashtags
        if (button.tag >=20) {
            
        }
    }
}

#pragma mark - Request + Mapping
- (void)configureRestKit
{
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // initialize RestKit
    RKObjectManager *objectManager =  [RKObjectManager sharedManager];
    
    // setup object mappings
    // Hotlist detail
    RKObjectMapping *hotlistDetailMapping = [RKObjectMapping mappingForClass:[HotlistDetail class]];
    [hotlistDetailMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APISTATUSKEY:kTKPDHOME_APISTATUSKEY, kTKPDHOME_APISERVERPROCESSTIMEKEY:kTKPDHOME_APISERVERPROCESSTIMEKEY}];
    
    // result mapping
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APICOVERIMAGEKEY:kTKPDHOME_APICOVERIMAGEKEY, KTKPDHOME_APIDESCRIPTIONKEY:KTKPDHOME_APIDESCRIPTIONKEY}];
    
    // searchs list mapping
    RKObjectMapping *hotlistMapping = [RKObjectMapping mappingForClass:[List class]];
    [hotlistMapping addAttributeMappingsFromArray:@[kTKPDHOME_APICATALOGIMAGEKEY,kTKPDHOME_APICATALOGNAMEKEY,kTKPDHOME_APICATALOGPRICEKEY,kTKPDHOME_APIPRODUCTPRICEKEY,kTKPDHOME_APIPRODUCTIDKEY,kTKPDHOME_APISHOPGOLDSTATUSKEY,kTKPDHOME_APISHOPLOCATIONKEY,kTKPDHOME_APISHOPNAMEKEY,kTKPDHOME_APIPRODUCTIMAGEKEY,kTKPDHOME_APIPRODUCTNAMEKEY]];
    
    // paging mapping
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDHOME_APIURINEXTKEY:kTKPDHOME_APIURINEXTKEY}];
    
    // hashtags mapping
    RKObjectMapping *hashtagMapping = [RKObjectMapping mappingForClass:[Hashtags class]];
    [hashtagMapping addAttributeMappingsFromArray:@[kTKPDHOME_APIHASHTAGSNAMEKEY, kTKPDHOME_APIHASHTAGSURLKEY]];
    
    // Adjust Relationship
    [hotlistDetailMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIRESULTKEY toKeyPath:kTKPDHOME_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    // result
    RKResponseDescriptor *responseDescriptorResult = [RKResponseDescriptor responseDescriptorWithMapping:hotlistDetailMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLISTRESULT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    // hotlist
    RKResponseDescriptor *responseDescriptorHotlistDetail = [RKResponseDescriptor responseDescriptorWithMapping:hotlistMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLISTRESULT_APIPATH keyPath:kTKPDHOME_APIPATHMAPPINGLISTKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    // paging
    RKResponseDescriptor *responseDescriptorPaging = [RKResponseDescriptor responseDescriptorWithMapping:pagingMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLISTRESULT_APIPATH keyPath:kTKPDHOME_APIPATHMAPPINGPAGINGKEY statusCodes:kTkpdIndexSetStatusCodeOK];
    // hashtags
     RKResponseDescriptor *responseDescriptorHashtags = [RKResponseDescriptor responseDescriptorWithMapping:hashtagMapping method:RKRequestMethodGET pathPattern:kTKPDHOMEHOTLISTRESULT_APIPATH keyPath:kTKPDHOMEHOTLIST_APIHASHTAGSKEYPATH statusCodes:kTkpdIndexSetStatusCodeOK];
    
    // add response description to object manager
    [objectManager addResponseDescriptor:responseDescriptorResult];
    [objectManager addResponseDescriptor:responseDescriptorHotlistDetail];
    [objectManager addResponseDescriptor:responseDescriptorPaging];
    [objectManager addResponseDescriptor:responseDescriptorHashtags];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptorResult.mapping forKey:(responseDescriptorResult.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorHotlistDetail.mapping forKey:(responseDescriptorHotlistDetail.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorPaging.mapping forKey:(responseDescriptorPaging.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptorHashtags.mapping forKey:(responseDescriptorHashtags.keyPath ?: [NSNull null])];
    
    [self loadData];
}


- (void)loadData
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:nil
                                   selector:@selector(requestfailure:)
                                   userInfo:nil
                                    repeats:NO];
    
    NSString *querry =[_data objectForKey:kTKPDHOME_DATAQUERYKEY];
    
	NSDictionary* param = @{
                            //@"auth":@(1),
                            //kTKPDHOME_APIQUERYKEY : querry?:@"",
                            kTKPDHOME_APIQUERYKEY : @"demi-iklan", //TODO::remove dummy data
                            kTKPDHOME_APIPAGEKEY : @(_page),
                            kTKPDHOME_APILIMITPAGEKEY : @(kTKPDHOMEHOTLISTRESULT_LIMITPAGE),
                            };
    
    NSLog(@"============================== GET HOTLIST DETAIL =====================");
    [[RKObjectManager sharedManager] getObjectsAtPath:kTKPDHOMEHOTLISTRESULT_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        [_refreshControl endRefreshing];
        
        NSLog(@"============================== DONE GET HOTLIST DETAIL =====================");
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Has Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alertView show];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_refreshControl endRefreshing];
        
        NSLog(@"============================== DONE GET HOTLIST DETAIL =====================");
    }];
}


-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id info = [result objectForKey:@""];
    HotlistDetail *hotlistdetail = info;
    NSString *statusstring = hotlistdetail.status;
    BOOL status = [statusstring isEqualToString:@"OK"];
    
    if (status) {
        [_product addObjectsFromArray: [result objectForKey:kTKPDHOME_APIPATHMAPPINGLISTKEY]];
        [_detailhotlist addEntriesFromDictionary:result];
        [self setHeaderData:result];
        
        id page =[result objectForKey:kTKPDHOME_APIPATHMAPPINGPAGINGKEY];
        
        if (_product.count >0) {
            
            Paging *paging = page;
            _urinext =  paging.uri_next;
            
            NSURL *url = [NSURL URLWithString:_urinext];
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
            
            _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
            
            NSLog(@"next page : %d",_page);
            
            _isnodata = NO;
        }
    }
 }

-(void)requesttimeout
{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}

-(void)requestfailure:(id)object
{
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.3];
    }
    else
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.3];

    //NSDictionary *userInfo = @{@"count":@(0)};
    //[[NSNotificationCenter defaultCenter] postNotificationName: @"setsegmentcontrol" object:nil userInfo:userInfo];
}

#pragma mark - Methods
-(void)setHeaderData:(NSDictionary*)data
{
    id info = [data objectForKey:@""];
    HotlistDetail *hotlistdetail = info;
    
    NSString *urlstring = hotlistdetail.result.cover_image;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:0.3];
    //request.URL = url;
    
    UIImageView *thumb = _imageview;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [_act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
        [_act stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [_act stopAnimating];
    }];
    
    NSArray *hashtags = [data objectForKey:kTKPDHOMEHOTLIST_APIHASHTAGSKEYPATH];
    [self setHashtagsArray:hashtags];
}

-(void)setHashtagsArray:(NSArray*)array
{

    NSInteger widthcontenttop=0;
    _buttons = [NSMutableArray new];
    
    /** Adjust hashtags to Scrollview **/
    for (int i = 0; i<array.count; i++) {
        Hashtags *hashtags = array[i];
        NSString *name = hashtags.name;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:name forState:UIControlStateNormal];
        UIFont * font = kTKPDHOME_FONTSLIDETITLES;
        button.titleLabel.font = font;
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        CGSize stringSize = [name sizeWithFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
        CGFloat widthlabel = stringSize.width+10;
        
        button.frame = CGRectMake(widthcontenttop,_hashtagsscrollview.frame.size.height/2-10,widthlabel,(_hashtagsscrollview.frame.size.height)-30);
        button.tag = i+20;
        
        widthcontenttop +=widthlabel;
        
        [_buttons addObject:button];
        [_hashtagsscrollview addSubview:_buttons[i]];
    }
    
    _hashtagsscrollview.contentSize = CGSizeMake(widthcontenttop+10, 0);
}


#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    // cancel all request
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    
    // reset object
    [_product removeAllObjects];
    _page = 1;
    [_table reloadData];
    
    // request data
    [self loadData];
}

@end
