/*
 InboxMessageDetailCell.m
 
 Copyright (C) 2012 pontius software GmbH
 
 This program is free software: you can redistribute and/or modify
 it under the terms of the Createive Commons (CC BY-SA 3.0) license
 */

#import "InboxMessageDetailCell.h"
#define CXTimeLabel 60.0f

@implementation InboxMessageDetailCell

@synthesize delegate = _delegate;

static CGFloat textMarginHorizontal = 13.0f;
static CGFloat textMarginVertical = 5.0f;
static CGFloat messageTextSize = 17.0;

@synthesize sent, messageLabel, messageView, timeLabel, avatarImageView, balloonView;

#pragma mark -
#pragma mark Static methods

+(CGFloat)textMarginHorizontal {
    return textMarginHorizontal;
}

+(CGFloat)textMarginVertical {
    return textMarginVertical;
}

+(CGFloat)maxTextWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 220.0f;
    } else {
        return 400.0f;
    }
}

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"messagingCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

+(CGSize)messageSize:(NSString*)message {
    return [message sizeWithFont:[UIFont fontWithName:@"GothamBook" size:messageTextSize] constrainedToSize:CGSizeMake([InboxMessageDetailCell maxTextWidth], CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
}

+(UIImage*)balloonImage:(BOOL)sent isSelected:(BOOL)selected {
    if (sent == YES && selected == YES) {
        return [[UIImage imageNamed:@"balloon_selected_right"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else if (sent == YES && selected == NO) {
        return [[UIImage imageNamed:@"balloon_read_right"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else if (sent == NO && selected == YES) {
        return [[UIImage imageNamed:@"balloon_selected_left"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    } else {
        return [[UIImage imageNamed:@"balloon_read_left"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    }
}

#pragma mark -
#pragma mark Object-Lifecycle/Memory management

-(id)initMessagingCellWithReuseIdentifier:(NSString*)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        /*Selection-Style of the TableViewCell will be 'None' as it implements its own selection-style.*/
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        /*Now the basic view-lements are initialized...*/
        _viewLabelUser = [[ViewLabelUser alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-CXTimeLabel, CHeightUserLabel)];
        [_viewLabelUser setText:[UIColor colorWithRed:10/255.0f green:126/255.0f blue:7/255.0f alpha:1.0f] withFont:[UIFont fontWithName:@"GothamBook" size:12.0f]];
        messageView = [[UIView alloc] initWithFrame:CGRectZero];
        messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        avatarImageView = [UIImageView circleimageview:[[UIImageView alloc] initWithImage:nil]];

        
        /*Message-Label*/
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.font = [UIFont fontWithName:@"GothamBook" size:messageTextSize];

        self.timeLabel.textColor = [UIColor whiteColor];
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        /*Time-Label*/
        self.timeLabel.font = [UIFont fontWithName:@"GothamBook" size:10.0f];;
        self.timeLabel.textColor = [UIColor lightGrayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        /*...and adds them to the view.*/
        [self.messageView addSubview: self.balloonView];
        [self.messageView addSubview: self.messageLabel];
        
        [self.balloonView addSubview:_viewLabelUser];
        [self.contentView addSubview: self.timeLabel];
        [self.contentView addSubview: self.messageView];
        [self.contentView addSubview: self.avatarImageView];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:(231.0/255.0) green:(231.0/255.0) blue:(231.0/255.0) alpha:1.0];
//        self.contentView.backgroundColor = [UIColor greenColor];
        [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width , 500)];
        
        /*...and a gesture-recognizer, for LongPressure is added to the view.*/
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [recognizer setMinimumPressDuration:1.0f];
        [self addGestureRecognizer:recognizer];
    }
    
    return self;
}

- (float)calculateSender:(UIFont *)font withColor:(UIColor *)color withSize:(CGSize)size withText:(NSString *)strText
{
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = color;
    tempLabel.font = font;
    tempLabel.text = strText;
    CGSize tempSize = [tempLabel sizeThatFits:size];
    
    return tempSize.width;
}


#pragma mark -
#pragma mark Layouting

- (void)layoutSubviews {
    [super layoutSubviews];
    /*This method layouts the TableViewCell. It calculates the frame for the different subviews, to set the layout according to size and orientation.*/
    
    /*Calculates the size of the message. */
    CGSize textSize = [InboxMessageDetailCell messageSize:self.messageLabel.text];
    
    /*Calculates the size of the timestamp.*/
    CGSize dateSize = [self.timeLabel.text sizeWithFont:self.timeLabel.font forWidth:[InboxMessageDetailCell maxTextWidth] lineBreakMode:NSLineBreakByClipping];
    
    /*Initializes the different frames , that need to be calculated.*/
    CGRect ballonViewFrame = CGRectZero;
    CGRect messageLabelFrame = CGRectZero;
    CGRect timeLabelFrame = CGRectZero;
    CGRect avatarImageFrame = CGRectZero;
    CGRect rectViewLabelUser = CGRectZero;
    
    if (self.sent == YES) {
        ballonViewFrame = CGRectMake(self.frame.size.width - (textSize.width + 2*textMarginHorizontal), timeLabelFrame.size.height, textSize.width + 2*textMarginHorizontal, textSize.height + 2*textMarginVertical + 5.0f);
        
        
        timeLabelFrame = CGRectMake(self.frame.size.width - dateSize.width - textMarginHorizontal, ballonViewFrame.size.height +5, dateSize.width, dateSize.height);
        
        messageLabelFrame = CGRectMake(self.frame.size.width - (textSize.width + textMarginHorizontal),  ballonViewFrame.origin.y + textMarginVertical, textSize.width, textSize.height);
        
        avatarImageFrame = CGRectMake(self.frame.size.width - 55.0f,  timeLabelFrame.size.height + ballonViewFrame.size.height - 40.0f , 45.0f, 45.0f);
        _viewLabelUser.hidden = YES;
    } else {
        float widthUserLabel = [self calculateSender:_viewLabelUser.getLblText.font withColor:_viewLabelUser.getLblText.textColor withSize:CGSizeMake([InboxMessageDetailCell maxTextWidth], CHeightUserLabel) withText:_viewLabelUser.getLblText.text];
        
        ballonViewFrame = CGRectMake(55.0f, timeLabelFrame.size.height, textSize.width + 2*textMarginHorizontal, textSize.height + 2*textMarginVertical + 5.0f + CHeightUserLabel);
        
        if(ballonViewFrame.size.width < (_viewLabelUser.getLblText.frame.origin.x+widthUserLabel+(2*textMarginHorizontal))) {
            ballonViewFrame.size.width = (_viewLabelUser.getLblText.frame.origin.x+widthUserLabel+(2*textMarginHorizontal));
        }
        
        timeLabelFrame = CGRectMake(CXTimeLabel, ballonViewFrame.size.height +5 , dateSize.width, dateSize.height);
        
        messageLabelFrame = CGRectMake(textMarginHorizontal + 55.0f, CHeightUserLabel + ballonViewFrame.origin.y + textMarginVertical, textSize.width, textSize.height);
        
        
        avatarImageFrame = CGRectMake(5.0f, timeLabelFrame.size.height + ballonViewFrame.size.height - 40.0f, 45.0f, 45.0f);
        
        rectViewLabelUser = CGRectMake(textMarginHorizontal, 6, [InboxMessageDetailCell maxTextWidth], CHeightUserLabel);
        _viewLabelUser.hidden = NO;

    }
    
    self.viewLabelUser.frame = rectViewLabelUser;
    self.balloonView.image = [InboxMessageDetailCell balloonImage:self.sent isSelected:self.selected];
    
    /*Sets the pre-initialized frames  for the balloonView and messageView.*/
    self.balloonView.frame = ballonViewFrame;
    self.messageLabel.frame = messageLabelFrame;
    
    /*If shown (and loaded), sets the frame for the avatarImageView*/
    if (self.avatarImageView.image != nil) {
        self.avatarImageView.frame = avatarImageFrame;
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height /2;
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.borderWidth = 0;
    }
    
    /*If there is next for the timeLabel, sets the frame of the timeLabel.*/
    
    if (self.timeLabel.text != nil) {
        self.timeLabel.frame = timeLabelFrame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    /*Selecting a UIMessagingCell will cause its subviews to be re-layouted. This process will not be animated! So handing animated = YES to this method will do nothing.*/
    [super setSelected:selected animated:NO];
    
    [self setNeedsLayout];
    
    /*Furthermore, the cell becomes first responder when selected.*/
    if (selected == YES) {
        [self becomeFirstResponder];
    } else {
        [self resignFirstResponder];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
}

#pragma mark -
#pragma mark UIGestureRecognizer-Handling

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    /*When a LongPress is recognized, the copy-menu will be displayed.*/
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    if ([self becomeFirstResponder] == NO) {
        return;
    }
    
    UIMenuController * menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.balloonView.frame inView:self];
    
    [menu setMenuVisible:YES animated:YES];
}

-(BOOL)canBecomeFirstResponder {
    /*This cell can become first-responder*/
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    /*Allows the copy-Action on this cell.*/
    if (action == @selector(copy:)) {
        return YES;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

-(void)copy:(id)sender {
    /**Copys the messageString to the clipboard.*/
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.messageLabel.text];
}
@end

