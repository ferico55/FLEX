//
//  SwipeMenuViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "home.h"
#import "SwipeMenuViewController.h"

@interface SwipeMenuViewController ()
{
    NSInteger _page;
    
    NSMutableArray *_container;
    NSMutableArray *_button;
    
    /** total view controller at product  **/
    NSInteger _numberOfViews;
}


@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewmenu;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewtop;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation SwipeMenuViewController

+(id)newView{
    NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"SwipeMenuViewController" owner:nil options:nil];
    for (id o in a) {
        if([o isKindOfClass:[self class]]){
            
            return o;
        }
    }
    return nil;
}

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [self AdjustPageActive];
}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    _page = btn.tag-10;
    [self AdjustPageActive];
}

#pragma mark - Memory Management

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollviewmenu) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _page = page;
        [self AdjustPageActive];
    }
}

#pragma mark - methods

-(void)setNavcon:(UINavigationController *)navcon{
    _navcon = navcon;
}

/** create content View to view controller **/
-(void)AdjustViewControllers:(NSArray*)viewcontrollers withtitles:(NSArray*)titles
{
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /** for ios 7 need to set tab bar translucent **/
    if([self.tabBarController.tabBar respondsToSelector:@selector(setTranslucent:)])
    {
        [self.tabBarController.tabBar setTranslucent:NO];
    }
    
    /** for ios 7 need to set automatically adjust scrooll view inset**/
    if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:_scrollviewtop];
    [self.view addSubview:_scrollviewmenu];
    [self.view addSubview:_image];
    
    /** initialization mutable variable **/
    _button = [NSMutableArray new];
    _container = [NSMutableArray new];
    
    _numberOfViews = viewcontrollers.count;
    

    NSInteger widthcontenttop=0;
    
    /** Adjust View to Scrollview **/
    for (int i = 0; i<_numberOfViews; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        UIFont * font = kTKPDHOME_FONTSLIDETITLES;
        button.titleLabel.font = font;
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        CGSize stringSize = [titles[i] sizeWithFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
        CGFloat widthlabel = stringSize.width+10;
        
        button.frame = CGRectMake(widthcontenttop+6,0,widthlabel,(_scrollviewtop.frame.size.height)-30);
        button.tag = i+10;
        
        widthcontenttop +=widthlabel;
        
        [_button addObject:button];
        [_scrollviewtop addSubview:_button[i]];
        [_container addObject:_button[i]];
        
        [_scrollviewmenu addSubview:((UIViewController*)viewcontrollers[i]).view];
        [_container addObject:(UIViewController*)viewcontrollers[i]];
    }
    _scrollviewmenu.contentSize = CGSizeMake(_scrollviewmenu.frame.size.width * _numberOfViews, 0);
    _scrollviewtop.contentSize = CGSizeMake(widthcontenttop+10, 0);
    
    [self AdjustPageActive];
    
}

/** adjust page active behavior **/
-(void)AdjustPageActive
{
    /** reset color button **/
    for (UIButton *btn in _button) {
        [btn setTitleColor:kTKPDHOME_FONTSLIDETITLESCOLOR forState:UIControlStateNormal];
        [btn.titleLabel setFont:kTKPDHOME_FONTSLIDETITLES];
    }
    /** set button active color **/
    UIButton *btn = (UIButton*)_button[_page];
    [btn setTitleColor:kTKPDHOME_FONTSLIDETITLESACTIVECOLOR forState:UIControlStateNormal];
    [btn.titleLabel setFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
    
    /** set menu slide behavior **/
    if (_page>0 && _numberOfViews>2) {
        CGFloat offset = 0;
        UIButton* btn1;
        UIButton* last;
        for (int i = 0; i<=_page-1; i++) {
            btn1 = (UIButton*)_button[i];
            last = (UIButton*)_button[_page-1];
            offset =  offset + (CGFloat)btn1.frame.size.width;
        }
        [_scrollviewtop setContentOffset:CGPointMake(offset-(((CGFloat)btn1.frame.size.width/2+10)*_page), 0) animated:YES];
    }
    else
    {
        [_scrollviewtop setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [_scrollviewmenu setContentOffset:CGPointMake(_scrollviewmenu.frame.size.width*_page, 0) animated:YES];
}

@end
