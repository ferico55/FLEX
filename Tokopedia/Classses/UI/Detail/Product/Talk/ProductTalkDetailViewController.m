//
//  ProductTalkDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkDetailViewController.h"
#import "TalkComment.h"
#import "detail.h"
#import "GeneralTalkCommentCell.h"
#import "ProductTalkCommentAction.h"
#import "TKPDSecureStorage.h"
#import "URLCacheController.h"
#import "stringrestkit.h"

@interface ProductTalkDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    BOOL _isnodata;
    NSMutableArray *_list;
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    NSString *_urinext;
    
    NSTimer *_timer;
    NSInteger _page;
    NSInteger _limit;

    NSInteger _requestcount;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSInteger _requestactioncount;
    __weak RKObjectManager *_objectactionmanager;
    __weak RKManagedObjectRequestOperation *_requestaction;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationActionQueue;
    TalkComment *_talkcomment;

    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    NSMutableDictionary *_auth;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UILabel *talkmessagelabel;
@property (weak, nonatomic) IBOutlet UILabel *talkcreatetimelabel;
@property (weak, nonatomic) IBOutlet UILabel *talkusernamelabel;
@property (weak, nonatomic) IBOutlet UILabel *talktotalcommentlabel;
@property (weak, nonatomic) IBOutlet UITextField *talktextfield;
@property (weak, nonatomic) IBOutlet UIImageView *talkuserimage;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UIView *header;

-(void)cancel;
-(void)configureRestKit;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;
-(void)configureActionRestkit;

@end

@implementation ProductTalkDetailViewController

#pragma mark - Initializations
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = kTKPDTITLE_TALK;
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _list = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _operationActionQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _table.tableHeaderView = _header;
    
    _page = 1;
    _auth = [NSMutableDictionary new];
    
    _talktextfield.layer.cornerRadius = 2;
    _talktextfield.layer.borderWidth = 0.5f;
    _talktextfield.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    
    _sendButton.layer.cornerRadius = 2;
    
    //TODO:: Change image
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self setHeaderData:_data];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILPRODUCTTALKDETAIL_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDDETAIL_APIPRODUCTIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TalkCommentList *list = _list[indexPath.row];
    CGSize messageSize = [GeneralTalkCommentCell messageSize:list.comment_message];
    return messageSize.height + 2 * [GeneralTalkCommentCell textMarginVertical];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER;
        
        cell = (GeneralTalkCommentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [GeneralTalkCommentCell newcell];
            ((GeneralTalkCommentCell*)cell).delegate = self;
        }
        
        if (_list.count > indexPath.row) {
            TalkCommentList *list = _list[indexPath.row];
            
            UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
            NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 5.0f;
            NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : style};
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:list.comment_message
                                                                                   attributes:attributes];
            ((GeneralTalkCommentCell *)cell).commentlabel.attributedText = attributedString;
            
            CGFloat commentLabelWidth = ((GeneralTalkCommentCell*)cell).commentlabel.frame.size.width;
            
            [((GeneralTalkCommentCell*)cell).commentlabel sizeToFit];

            CGRect commentLabelFrame = ((GeneralTalkCommentCell*)cell).commentlabel.frame;
            commentLabelFrame.size.width = commentLabelWidth;
            ((GeneralTalkCommentCell*)cell).commentlabel.frame = commentLabelFrame;
                                        
            ((GeneralTalkCommentCell*)cell).user_name.text = list.comment_user_name;
            ((GeneralTalkCommentCell*)cell).create_time.text = list.comment_create_time;
           
            ((GeneralTalkCommentCell*)cell).indexpath = indexPath;
            
            if(list.is_not_delivered) {
                ((GeneralTalkCommentCell*)cell).commentfailimage.hidden = NO;
            } else {
                ((GeneralTalkCommentCell*)cell).commentfailimage.hidden = YES;
            }
        
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.comment_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            UIImageView *user_image = ((GeneralTalkCommentCell*)cell).user_image;
            user_image.image = nil;

            [user_image setImageWithURLRequest:request
                              placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [user_image setImage:image];
            
#pragma clang diagnostic pop
                
            } failure:nil];
        }
        
    } else {
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
        
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            /** called if need to load next page **/
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            [self configureRestKit];
            [self loadData];
        }
    }
}


#pragma mark - Methods
-(void)setHeaderData:(NSDictionary*)data
{
    _talkmessagelabel.text = [data objectForKey:TKPD_TALK_MESSAGE];
	[_talkmessagelabel sizeToFit];

    _talkcreatetimelabel.text = [data objectForKey:TKPD_TALK_CREATE_TIME];
    _talkusernamelabel.text = [data objectForKey:TKPD_TALK_USER_NAME];
    _talktotalcommentlabel.text = [NSString stringWithFormat:@"%@ Comment",[data objectForKey:TKPD_TALK_TOTAL_COMMENT]];
    
    
    NSURL * imageURL = [NSURL URLWithString:[data objectForKey:TKPD_TALK_USER_IMG]];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage * image = [UIImage imageWithData:imageData];
    
    _talkuserimage.image = image;
    _talkuserimage.layer.cornerRadius = _talkuserimage.frame.size.width/2;
    
//    CGFloat newHeaderHeight = _talktotalcommentlabel.frame.size.height + _talktotalcommentlabel.frame.origin.y + 7;
//    CGRect newHeaderFrame = _header.frame;
//    newHeaderFrame.size.height = newHeaderHeight;
//    _header.frame = newHeaderFrame;
//    [_header layoutIfNeeded];
}

#pragma mark - Life Cycle
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
}


#pragma mark - Request and Mapping
-(void) cancel {
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

-(void) configureRestKit{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TalkComment class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TalkCommentResult class]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[TalkCommentList class]];

    [listMapping addAttributeMappingsFromArray:@[
                                                 TKPD_TALK_COMMENT_ID,
                                                 TKPD_TALK_COMMENT_MESSAGE,
                                                 TKPD_COMMENT_ID,
                                                 TKPD_TALK_COMMENT_ISMOD,
                                                 TKPD_TALK_COMMENT_ISSELLER,
                                                 TKPD_TALK_COMMENT_CREATETIME,
                                                 TKPD_TALK_COMMENT_USERIMG,
                                                 TKPD_TALK_COMMENT_USERNAME,
                                                 ]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPAGINGKEY toKeyPath:kTKPDDETAIL_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILTALK_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void) loadData {
    _requestcount++;
    
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETCOMMENTBYTALKID,
                            TKPD_TALK_ID : [_data objectForKey:kTKPDTALKCOMMENT_TALKID]?:@(0),
                            kTKPDDETAIL_APISHOPIDKEY : [_data objectForKey:TKPD_TALK_SHOP_ID]?:@(0),
                            kTKPDDETAIL_APIPAGEKEY : @(_page)
                            };
//    [_cachecontroller getFileModificationDate];
//	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
//	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILTALK_APIPATH parameters:param];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //[_objectmanager getObjectsAtPath:kTKPDDETAILTALK_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [_timer invalidate];
            _timer = nil;
            [_act stopAnimating];
            _table.hidden = NO;
            _isrefreshview = NO;
            [_refreshControl endRefreshing];
            [self requestfailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
//    }else{
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
//        NSLog(@"cache and updated in last 24 hours.");
//        [self requestfailure:nil];
//    }
}

-(void) requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _talkcomment = stats;
    BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (_page <=1 && !_isrefreshview) {
            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
            [_cachecontroller connectionDidFinish:_cacheconnection];
            //save response data
            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        }
        [self requestprocess:object];
    }
}

-(void) requestfailure:(id)object {
    if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachepath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _talkcomment = stats;
            BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            
            _talkcomment = stats;
            BOOL status = [_talkcomment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                NSArray *list = _talkcomment.result.list;
                [_list addObjectsFromArray:list];
                
                _urinext =  _talkcomment.result.paging.uri_next;
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
                
                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                NSLog(@"next page : %d",_page);
                
                
                _isnodata = NO;
                [_table reloadData];
            }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = nil;
            }
        }
    }
}

-(void)requesttimeout {
    [self cancel];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender {
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            default:
            break;
        }
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10: {
                NSInteger lastindexpathrow = [_list count];
                TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                NSDictionary* auth = [secureStorage keychainDictionary];
                _auth = [auth mutableCopy];
                
                TalkCommentList *commentlist = [TalkCommentList new];
                
                commentlist.comment_message =_talktextfield.text;
                commentlist.comment_user_name = [_auth objectForKey:@"full_name"];
                commentlist.comment_user_image = [_auth objectForKey:@"user_image"];
                
                
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd MMMM yyyy, HH:m"];
                NSString *dateString = [dateFormat stringFromDate:today];
                
                commentlist.comment_create_time = [dateString stringByAppendingString:@"WIB"];
                
                [_list insertObject:commentlist atIndex:lastindexpathrow];
                NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                             [NSIndexPath indexPathForRow:lastindexpathrow inSection:0],nil
                                             ];
                
                [_table beginUpdates];
                [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                [_table endUpdates];
                
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastindexpathrow inSection:0];
                [_table scrollToRowAtIndexPath:indexpath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
                
                //connect action to web service
                [self configureActionRestkit];
                [self addProductCommentTalk];
                
                _talktextfield.text = nil;
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Action Send Comment Talk
- (void)configureActionRestkit {
    // initialize RestKit
    _objectactionmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductTalkCommentAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductTalkCommentActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success"}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDACTIONTALK_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectactionmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void)addProductCommentTalk{
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIADDCOMMENTTALK,
                            TKPD_TALK_ID:[_data objectForKey:TKPD_TALK_ID],
                            kTKPDTALKCOMMENT_APITEXT:_talktextfield.text,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]
                            };
    
    _requestactioncount ++;
    _requestaction = [_objectactionmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDACTIONTALK_APIPATH parameters:param];
    
    
    [_requestaction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestactionsuccess:mappingResult withOperation:operation];
        [_table reloadData];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
        
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    }];
    
    [_operationActionQueue addOperation:_requestaction];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

}

- (void)requestactionsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    ProductTalkCommentAction *commentaction = info;
    BOOL status = [commentaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        //if success
        if([commentaction.result.is_success isEqualToString:@"0"]) {
            TalkCommentList *commentlist = _list[_list.count-1];
            commentlist.is_not_delivered = @"1";
        } else {
            NSString *totalcomment = [NSString stringWithFormat:@"%d %@",_list.count, @"Comment"];
            _talktotalcommentlabel.text = totalcomment;
            
            NSDictionary *userinfo;
            userinfo = @{TKPD_TALK_TOTAL_COMMENT:@(_list.count)?:0, kTKPDDETAIL_DATAINDEXKEY:[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTotalComment" object:nil userInfo:userinfo];
            
        }
    }
}

- (void)requestactionfailure:(id)error {
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
