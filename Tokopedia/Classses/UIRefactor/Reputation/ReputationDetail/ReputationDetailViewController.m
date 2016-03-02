//
//  ReputationDetailViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationDetailViewController.h"

@implementation ReputationDetailViewController

#pragma mark - Initialization
- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _commentLabel.text = @"Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter Comment mantep lebih dari 30 karakter";
    
    _commentReplyLabel.text = @"Reply Comment Aja ini Reply Comment Aja ini Reply Comment Aja ini Reply Comment Aja ini";
    
    [self initNotification];
    [self initTalkInputView];
    [self setCustomMessageHeight];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    _scrollView.contentSize = _contentView.frame.size;
}



-(void)setCustomMessageHeight {
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = NSTextAlignmentJustified;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_commentLabel.text attributes:attributes];
    NSAttributedString *attributedReplyCommentText = [[NSAttributedString alloc] initWithString:_commentReplyLabel.text attributes:attributes];
    
    _commentLabel.attributedText = attributedText;
    _commentReplyLabel.attributedText = attributedReplyCommentText;
    
    //custom label height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [_commentLabel.text sizeWithFont:_commentLabel.font constrainedToSize:maximumLabelSize lineBreakMode:_commentLabel.lineBreakMode];
    
    CGRect newFrame2 = _ratingView.frame;
    newFrame2.origin.y += expectedLabelSize.height - _commentLabel.frame.size.height;
    _ratingView.frame = newFrame2;
    
    CGRect newFrame3 = _commentReply.frame;
    newFrame3.origin.y += expectedLabelSize.height - _commentLabel.frame.size.height;
    _commentReply.frame = newFrame3;
    
    CGRect newFrame4 = _uploadedImageView.frame;
    newFrame4.origin.y += expectedLabelSize.height - _commentLabel.frame.size.height;
    _uploadedImageView.frame = newFrame4;
    
    CGRect newFrame = _commentLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    _commentLabel.frame = newFrame;
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGRect inputFrame = _inputView.frame;
//    inputFrame.origin.y = screenRect.size.height - _inputView.frame.size.height - 65;
//    _inputView.frame = inputFrame;
    
    float y = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - _inputView.frame.size.height;
    [_inputView setFrame:CGRectMake(0, y, _inputView.frame.size.width, _inputView.frame.size.height)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - HPTextview 


- (void) initTalkInputView {
    _growingtextview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 10, 240, 45)];
    //    [_growingtextview becomeFirstResponder];
    _growingtextview.isScrollable = NO;
    _growingtextview.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _growingtextview.layer.borderWidth = 0.5f;
    _growingtextview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _growingtextview.layer.cornerRadius = 5;
    _growingtextview.layer.masksToBounds = YES;
    
    _growingtextview.minNumberOfLines = 1;
    _growingtextview.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _growingtextview.returnKeyType = UIReturnKeyGo; //just as an example
    //    _growingtextview.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    _growingtextview.delegate = self;
    _growingtextview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _growingtextview.backgroundColor = [UIColor whiteColor];
    _growingtextview.placeholder = @"Kirim pesanmu di sini..";
    
    
    [_inputView addSubview:_growingtextview];
    _inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - UITextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _inputView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _inputView.frame = r;
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.view.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height - 50);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    // set views with new info
    self.view.frame = containerFrame;
    
    [_inputView becomeFirstResponder];
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    self.view.backgroundColor = [UIColor clearColor];
    CGRect containerFrame = self.view.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height + 65;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.view.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
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
