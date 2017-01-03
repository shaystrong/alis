//
//  ViewController.h
//  test
//
//  Created by Strong, Shadrian B. on 7/12/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "CorePlot-CocoaTouch.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
@property (nonatomic) double aerosolOpticalDepth;
@property (nonatomic) float *myLatitude;
@property (strong, nonatomic) CLLocationManager  *locationManager;
@property (strong, atomic) ALAssetsLibrary* library;

//property(weak, nonatomic)  NSObject* AOD;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePhoto:  (UIButton *)sender;
//- (IBAction)selectPhoto:(UIButton *)sender;


@end
