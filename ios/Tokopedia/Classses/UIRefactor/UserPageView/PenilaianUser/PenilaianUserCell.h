//
//  PenilaianUserCell.h
//  Tokopedia
//
//  Created by Tokopedia on 7/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PenilaianUserCell : UITableViewCell
{
    IBOutlet UILabel *lblPositif1, *lblPositif6, *lblPositif12, *lblNetral1, *lblNetral6, *lblNetral12, *lblBad1, *lblBad6, *lblBad12;
    IBOutlet UIProgressView *progressSmile, *progressNetral, *progressSad;
    IBOutlet UILabel *lblSmileCount, *lblNetralCount, *lblSadCount;
    
    IBOutlet NSLayoutConstraint *constLblWidthSmile, *constLblWidthSad, *constLblWidthNetral;
}

- (void)setPositif1:(NSString *)strText;
- (void)setPositif6:(NSString *)strText;
- (void)setPositif12:(NSString *)strText;
- (void)setNetral1:(NSString *)strText;
- (void)setNetral6:(NSString *)strText;
- (void)setNetral12:(NSString *)strText;
- (void)setBad1:(NSString *)strText;
- (void)setBad6:(NSString *)strText;
- (void)setBad12:(NSString *)strText;


- (void)setProgressSmileCount:(NSString *)strValue;
- (void)setProgressSadCount:(NSString *)strValue;
- (void)setProgressNetralCount:(NSString *)strValue;
- (void)setWidthLabel;
@end
