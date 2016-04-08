//
//  TPLiveCameraView.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPLiveCameraView : UIView

- (void)startLiveVideo;
- (void)stopLiveVideo;
- (void)restartCaptureSession;
- (void)freezeCapturedContent;

@end
