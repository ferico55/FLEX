/*
 PTSMessagingCell.h
 
 Copyright (C) 2012 pontius software GmbH
 
 This program is free software: you can redistribute and/or modify
 it under the terms of the Createive Commons (CC BY-SA 3.0) license
 */

#define KTKPDMESSAGE_DETAILCELLIDENTIFIER @"InboxMessageDetailCellIdentifier"
#import <UIKit/UIKit.h>

@protocol InboxMessageDetailCellDelegate <NSObject>
@required
-(void)InboxMessageDetailCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface InboxMessageDetailCell : UITableViewCell {

    UIImageView* avatarImageView;
    UILabel* timeLabel;
    UILabel* messageLabel;
    BOOL sent;
    
    @private UIView * messageView;
    @private UIImageView * balloonView;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<InboxMessageDetailCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<InboxMessageDetailCellDelegate> delegate;
#endif

+(id)newcell;

@property (strong,nonatomic) NSDictionary *data;
@property (nonatomic, readonly) UIView * messageView;
@property (nonatomic, readonly) UILabel * messageLabel;
@property (nonatomic, readonly) UILabel * timeLabel;
@property (nonatomic, readonly) UIImageView * avatarImageView;
@property (nonatomic, readonly) UIImageView * balloonView;
@property (assign) BOOL sent;


/**Returns the text margin in horizontal direction.
 @return CGFloat containing the horizontal text margin.
 */
+(CGFloat)textMarginHorizontal;

/**Returns the text margin in vertical direction.
 @return CGFloat containing the vertical text margin.
 */
+(CGFloat)textMarginVertical;

/** Returns the maximum width for a single message. The size depends on the UIInterfaceIdeom (iPhone/iPad). FOR CUSTOMIZATION: To edit the maximum width, edit this method.
 @return CGFloat containing the maximal width.
 */
+(CGFloat)maxTextWidth;

/** Calculates and returns the size of a frame containing the message, that is given as a parameter.
 @param message NSString containing the message string.
 @return CGSize containing the size of the message (w/h).
 */
+(CGSize)messageSize:(NSString*)message;

/**  Returns the ballon-Image for specified conditions.
 @param sent Indicates, wheather the message has been sent or received.
 @param selected Indicates, wheather the cell has been selected.
 FOR CUSTOMIZATION: To edit the image, user your own names in this method.
 */
+(UIImage*)balloonImage:(BOOL)sent isSelected:(BOOL)selected;

/**Initializes the PTSMessagingCell.
 @param reuseIdentifier NSString* containing a reuse Identifier.
 @return Instanze of the initialized PTSMessagingCell.
 */
-(id)initMessagingCellWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
