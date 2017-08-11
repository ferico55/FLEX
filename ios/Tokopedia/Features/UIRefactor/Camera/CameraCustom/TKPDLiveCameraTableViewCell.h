//
//  TKPDLiveCameraTableViewCell.h
//  Tokopedia
//
//  Created by Harshad Dange on 06/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKPDLiveCameraTableViewCell : UICollectionViewCell

- (void)startLiveVideo;
- (void)stopLiveVideo;
- (void)restartCaptureSession;
- (void)freezeCapturedContent;

@end
