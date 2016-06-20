//
//  RejectReasonProductDescriptionViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectReasonProductDescriptionViewController.h"
#import "TKPDTextView.h"

@interface RejectReasonProductDescriptionViewController ()<UIScrollViewDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UIButton *emptyStockButton;
@property (strong, nonatomic) IBOutlet TKPDTextView *productDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;

@end

@implementation RejectReasonProductDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                       target:self action:@selector(doneButtonClicked:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [_scrollView setScrollEnabled:YES];
    _scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1000);
    _scrollViewHeight.constant = [UIScreen mainScreen].bounds.size.height;
    _productDescriptionTextView.delegate = self;
    
    _productName.text = _orderProduct.product_name;
    _productPrice.text = _orderProduct.product_price;
    
    if(_orderProduct.emptyStock){
        [_emptyStockButton setBackgroundColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1]];
        [_emptyStockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_emptyStockButton setBackgroundColor:[UIColor whiteColor]];
        [_emptyStockButton setTitleColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1] forState:UIControlStateNormal];
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_orderProduct.product_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_productImage setContentMode:UIViewContentModeScaleAspectFill];
    [_productImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [self.productImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.productImage setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.productImage setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
    }];

}

-(IBAction)doneButtonClicked:(id)sender{
    [self.delegate didChangeProductDescription:_orderProduct.product_description withEmptyStock:_orderProduct.emptyStock];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)emptyStockButtonClicked:(id)sender {
    if(!_orderProduct.emptyStock){
        [_emptyStockButton setBackgroundColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1]];
        [_emptyStockButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _orderProduct.emptyStock = YES;
    }else{
        [_emptyStockButton setBackgroundColor:[UIColor whiteColor]];
        [_emptyStockButton setTitleColor:[UIColor colorWithRed:0.699 green:0.699 blue:0.699 alpha:1] forState:UIControlStateNormal];
        _orderProduct.emptyStock = NO;
    }
}

#pragma mark - TextView Delegate

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, _productDescriptionTextView.frame.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, _productDescriptionTextView.frame.origin.y+kbSize.height );
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
