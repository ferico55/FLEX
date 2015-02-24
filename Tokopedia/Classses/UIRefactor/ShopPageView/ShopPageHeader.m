//
//  ContainerViewController.m
//  PageViewControllerExample
//
//  Created by Mani Shankar on 29/08/14.
//  Copyright (c) 2014 makemegeek. All rights reserved.
//

#import "ShopPageHeader.h"
#import "ShopDescriptionView.h"
#import "ShopStatView.h"


@interface ShopPageHeader () <UIScrollViewDelegate> {
    ShopDescriptionView *_descriptionView;
    ShopStatView *_statView;
}

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end




@implementation ShopPageHeader

@synthesize data = _data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setHeaderShopPage:)
                                                 name:@"setHeaderShopPage"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _shopImageView.layer.cornerRadius = _shopImageView.frame.size.width/2;
    _shopImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _shopImageView.layer.borderWidth = 3.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNotificationCenter];
    
    _descriptionView = [ShopDescriptionView newView];
    [self.scrollView addSubview:_descriptionView];
    
    _statView = [ShopStatView newView];
    [self.scrollView addSubview:_statView];
    
    self.scrollView.hidden = YES;
    self.scrollView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeaderData {
    [_shopNameLabel setText:_shop.result.info.shop_name];
    // Set cover image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_cover]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_coverImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        
        _coverImageView.image = image;
        _coverImageView.hidden = NO;

        
#pragma clang diagnostic pop
    } failure:nil];
    
    //set shop image
    NSURLRequest* requestAvatar = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_shopImageView setImageWithURLRequest:requestAvatar placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        
        _shopImageView.image = image;
        _shopImageView.hidden = NO;
        
        
#pragma clang diagnostic pop
    } failure:nil];
    
}

- (void)setHeaderShopPage:(NSNotification*)notification {
    id userinfo = notification.userInfo;
    
    _shop = userinfo;
    [self setHeaderData];
    
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}





@end
