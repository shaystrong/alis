//
//  CameraDelegate.h
//  ALIS
//
//  Created by Strong, Shadrian B. on 10/15/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureOutput.h> // Allows us to use AVCaptureVideoDataOutputSampleBufferDelegate

@interface CameraDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@end