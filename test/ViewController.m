//
//  ViewController.m
//  test
//
//  Created by Strong, Shadrian B. on 7/12/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageProcessor.h"
#import "UIImage+OrientationFix.h"
#import <CoreLocation/CoreLocation.h>
#import "SecondViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <AssetsLibrary/AssetsLibrary.h>

//@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
//@end

//----for main viewcontroller
double x;
double am;
double PM;
//static void *ExposureDurationContext = &ExposureDurationContext;
//static void *ISOContext = &ISOContext;

@interface ViewController () <CLLocationManagerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, ImageProcessorDelegate>
//extern int x;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//------from 'SpookCam'
//@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (strong, nonatomic) UIImage * workingImage;
//end from SpookCam
//------for adaptive aperature
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGPoint circleCenter;
@property (nonatomic, weak) CAShapeLayer *maskLayer;
@property (nonatomic, weak) CAShapeLayer *circleLayer;
//@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (retain) AVCaptureDevice *videoDevice;
@property (retain) AVCaptureSession *captureSession;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinch;
@property (nonatomic, weak) UIPanGestureRecognizer   *pan;
//end adaptive aperture
@property (nonatomic) UIImagePickerControllerCameraFlashMode flashMode;
//@property(nonatomic, readonly) float minISO;
//@property(nonatomic, readonly) CMTime minExposureDuration;

@end

@implementation ViewController;
@synthesize aerosolOpticalDepth;
@synthesize locationManager=_locationManager;
@synthesize library;
//static float EXPOSURE_MINIMUM_DURATION = 1.0/1000; // Limit exposure duration to a useful range




- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor clearColor];
    // [_captureSession startRunning];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.imageView.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    //self.maskLayer.fillColor =[[UIColor blackColor] CGColor];
    //self.maskLayer.opacity = 0.5;
    //self.maskLayer.backgroundColor=[UIColor clearColor].CGColor;
    // self.maskLayer.opacity = 0.5;
    
    // create shape layer for circle we'll draw on top of image (the boundary of the circle)
    //AVCaptureDevice *videoDevice = [ViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.lineWidth = 5.0;
    circleLayer.fillColor = [[UIColor clearColor] CGColor];
    circleLayer.strokeColor = [[UIColor blackColor] CGColor];
    [self.imageView.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    //self.circleLayer.opacity = 0.5;
    
    // create circle path
    // have user move circle mask to cover sun
    [self updateCirclePathAtLocation:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0) radius:self.view.bounds.size.width * 0.06];
    
    // create pan gesture
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.imageView addGestureRecognizer:pan];
    self.imageView.userInteractionEnabled = YES;
    self.pan = pan;
    
    // create pan gesture
    
    /*UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    self.pinch = pinch;
    
    */
    
    //coordinates
    
    // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
    self.locationManager=[[CLLocationManager alloc] init];
    
    
    //  self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //locationManager = [[CLLocationManager alloc] init];
    //locationManager.delegate = self;
    //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //ocationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    self.library = [[ALAssetsLibrary alloc] init];
    
}

/*-(void)updateDeviceSettings(float focusValue, float isoValue){
}
*/
/*func updateDeviceSettings(focusValue : Float, isoValue : Float) {
    if let device = captureDevice {
        if(device.lockForConfiguration(nil)) {
            device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                //
            })
            
            // Adjust the iso to clamp between minIso and maxIso based on the active format
            let minISO = device.activeFormat.minISO
            let maxISO = device.activeFormat.maxISO
            let clampedISO = isoValue * (maxISO - minISO) + minISO
            
            device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                //
            })
            
            device.unlockForConfiguration()
        }
    }
}
*/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
    //CLLocation *crnLoc = [locations lastObject];
    //float *latitude = crnLoc.coordinate.latitude;
    //float longitude = crnLoc.coordinate.longitude;
    //float altitude = crnLoc.altitude;
    //float speed = crnLoc.speed;
}




- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}



- (void)updateCirclePathAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    self.circleCenter = location;
    self.circleRadius = radius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.circleCenter
                    radius:self.circleRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    self.maskLayer.path = [path CGPath];
    self.circleLayer.path = [path CGPath];
}


- (IBAction)didTouchUpInsideSaveButton:(id)sender
{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"image.png"];
    
    CGFloat scale  = [[self.imageView.window screen] scale];
    CGFloat radius = self.circleRadius * scale;
    CGPoint center = CGPointMake(self.circleCenter.x * scale, self.circleCenter.y * scale);
    
    CGRect frame = CGRectMake(center.x - radius,
                              center.y - radius,
                              radius * 2.0,
                              radius * 2.0);
  
    
    // temporarily remove the circleLayer
    
    CALayer *circleLayer = self.circleLayer;
    [self.circleLayer removeFromSuperlayer];
      ////not sure about htis
    // render the clipped image
    
    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    /*if ([self.imageView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
   
    {
        // if iOS 7, just draw it
        
        [self.imageView drawViewHierarchyInRect:self.imageView.bounds afterScreenUpdates:YES];
    }
    
    else*/
    
        // if pre iOS 7, manually clip it
        
        CGContextAddArc(context, self.circleCenter.x, self.circleCenter.y, self.circleRadius, 0, M_PI * 2.0, YES);
        CGContextClip(context);
        [self.imageView.layer renderInContext:context];
    
   
    
    ////not sure about htis
    // capture the image and close the context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add the circleLayer back
    
    [self.imageView.layer addSublayer:circleLayer];
    
    // crop the image
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    // save the image
    
    NSData *data = UIImagePNGRepresentation(croppedImage);
    
    [data writeToFile:path atomically:YES];
    
    // tell the user we're done
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"Saved" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    
    //UIColor *c = [self getRGBAsFromImage:data atX:0 atY:0 count:1];

    UIImage * myCroppedImage = [UIImage imageWithContentsOfFile:path];
    // don't display -- weird skewing
    self.imageView.image = myCroppedImage;
    // saves cropped view below
    [self.library saveImage:myCroppedImage toAlbum:@"ALIS Data" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
        }
    }];
    [self setupWithImage:myCroppedImage];
    
}




#pragma mark - Gesture recognizers

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint oldCenter;
    CGPoint tranlation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldCenter = self.circleCenter;
    }
    
    CGPoint newCenter = CGPointMake(oldCenter.x + tranlation.x, oldCenter.y + tranlation.y);
    
    [self updateCirclePathAtLocation:newCenter radius:self.circleRadius];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    static CGFloat oldRadius;
    CGFloat scale = [gesture scale];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldRadius = self.circleRadius;
    }
    
    CGFloat newRadius = oldRadius * scale;
    
    [self updateCirclePathAtLocation:self.circleCenter radius:newRadius];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.pan   && otherGestureRecognizer == self.pinch) ||
        (gestureRecognizer == self.pinch && otherGestureRecognizer == self.pan))
    {
        return YES;
    }
    
    return NO;
}

- (void)viewDidUnload
{
    self.library = nil;
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationItem setHidesBackButton:YES animated:NO];
}


- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraFlashMode =UIImagePickerControllerCameraFlashModeOff;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    //self.flashMode = UIImagePickerControllerCameraFlashModeOff;
    //float ISO = picker.activeFormat.minISO;
    //picker.cameraDevice
    //(AVCaptureExposureDurationCurrent,ISO)
    
    [self presentViewController:picker animated:YES completion:^ {
        [picker takePicture];
    }];
}


//- (IBAction)takePhoto:(UIButton *)sender {
   
//}


    //[UIImagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];


/*-(void) updateDeviceSettings(float focusValue, float isoValue) {
 
 device = AVCaptureDevice
    {
 float minISO = device.activeFormat.minISO
 float maxISO = device.activeFormat.maxISO
 
 device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, minISO, completionHandler: { (time) -> Void in})
 
 }
*/ 

#pragma mark UIImagePickerControllerDelegate
 //ARGH THE CULPRIT!!!
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
/*-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   NSString *mediaType = info[UIImagePickerControllerMediaType];
 
    

   [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
      
        _imageView.image = image;
       [self.library saveImage:image toAlbum:@"ALIS Data" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    //else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    //{
        // Code here to support video if enabled
    //}
}*/

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



//SpookCam
- (void)setupWithImage:(UIImage*)image {
    UIImage * fixedImage = [image imageWithFixedOrientation];
    self.workingImage = fixedImage;
    self.imageView.image = fixedImage;
    
    // Commence with processing!
    x = [self logPixelsOfImage:fixedImage];
   // [self logPixelsOfImage:fixedImage];
  //  sumColorOut = self.sumColor
    
}

- (double)logPixelsOfImage:(UIImage*)image  {
    // 1. Get pixels of image
    CGImageRef inputCGImage = [image CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 * pixels;
    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
    
    // 2. Iterate and log!
    NSLog(@"Brightness of image:");
    UInt32 * currentPixel = pixels;
    //UInt32 sumColor = 0;
    double valueToSum=0;
    double sumTest = 0.0;
    for (NSUInteger j = 0; j < height; j++) {
        for (NSUInteger i = 0; i < width; i++) {
            
               
            
            UInt32 color = *currentPixel;
            //double maxx = 270;
            //printf("%3.0f ", (R(color)+G(color)+B(color))/3.0);
            //printf("%3.0f ", (R(color)+G(color)+B(color)));
            double test =(R(color)+G(color)+B(color))/3.0;
           //if(test < maxx) {
             //   valueToSum = 0;
            //               }
            //else{
                valueToSum = test;
           // }

             currentPixel++;
            sumTest = valueToSum + sumTest; //valueToSum + sumTest;
        }
        
        //sumColor = *currentPixel + sumColor;
        //printf("\n");
            }
    NSLog(@"The summed brightness in the aperture is %f.", (double)sumTest); //(unsigned int)sumColor);
    free(pixels);
    return sumTest;
}




double getAOD( double sumTest,  double airMass) {
    

    //3. SBS ALIS 2014
    //Use Brightness to assess solar attenuation
    //3.a
    float correctSunDist = 0;
    float beta = 0;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd MM yyyy"];       //Remove the time part
    NSString *someDate = @"01 01 2014";
    NSString *TodayString = [df stringFromDate:[NSDate date]];
    NSString *TargetDateString = someDate;
    NSTimeInterval time = [[df dateFromString:TargetDateString] timeIntervalSinceDate:[df dateFromString:TodayString]];
    //[df release];
    int days = abs(time / 60 / 60/ 24);
    //NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    // Then use it
    //[dateComps minute];
    //[dateComps hour];
    
    //NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
   // NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    //float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
    //CLLocation *crnLoc = [locations lastObject]
   //tempPos = [[CLLocation alloc] latitude:valueLat longitude:valueLon];
    
//    float latitude = *CLLocationManager.location.coordinate.latitude;
    //float longitude = locManager.location.coordinate.longitude;
    
    beta = 2.0 * M_PI * days / 365.0;
    correctSunDist = 1.00011 + 0.034221 * cos(beta) + 0.001280 * sin(beta) + 0.000719 * cos(2 * beta) + 0.000077 * sin(2 * beta);
    int v_o_550 = 4277.7;   //placeholder
    double aerosolOpticalDepth = (-1 * airMass) * log(sumTest * correctSunDist / v_o_550);
    
#undef R
#undef G
#undef B
    return aerosolOpticalDepth;    
}

double getAirMass(double sumTest,float latitude, float longitude, float altitude) {
 //   CLLocationManager *locationManager;

    float correctSunDist = 0;
    float beta = 0;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd MM yyyy"];       //Remove the time part
    NSString *someDate = @"01 01 2014";
    NSString *TodayString = [df stringFromDate:[NSDate date]];
    NSString *TargetDateString = someDate;
    NSTimeInterval time = [[df dateFromString:TargetDateString] timeIntervalSinceDate:[df dateFromString:TodayString]];
    //[df release];
    int days = abs(time / 60 / 60/ 24);
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
    
    
    beta = 2.0 * M_PI * days / 365.0;
    correctSunDist = 1.00011 + 0.034221 * cos(beta) + 0.001280 * sin(beta) + 0.000719 * cos(2 * beta) + 0.000077 * sin(2 * beta);
    double y = (2 * M_PI / 365) * (days - 1 + ([dateComps hour] -12)/24);
    double eqtime = 229.18 * (0.000075 + 0.001868 * cos(y) - 0.032077 * sin(y) - 0.014615 * cos(2 * y) - 0.040849 * sin(2*y));
    double declin = 0.006918 - 0.399912 * cos(y) + 0.070257 * sin(y) - 0.006758 * cos(2*y) + 0.000907 * sin(2*y) - 0.002697 * cos(3*y)+ 0.00148 * sin(3*y); //radians
    
    double time_offset = eqtime - 4 * longitude + 60 * timeZoneOffset; //Equation of time
    double tst = [dateComps hour] * 60 + [dateComps minute] + time_offset;
    double hourAngle = (tst/4 - 180)*M_PI/180;           //%radians
    double zenithAngle = acos(sin(latitude*M_PI/180) * sin(declin) + cos(latitude*M_PI/180) * cos(declin) * cos(hourAngle));
    //double cosZ = cos(zenithAngle);  //radians
    double meanOzoneHeight = (26 - latitude/10);  //km
    double radiusEarth = 6370; //km
    double corr = 1-(meanOzoneHeight-altitude*0.0003048)/radiusEarth; //unitless
    double airMassOzone = 1.0/cos(asin(corr*sin(zenithAngle)));
    //double airMass = 1.0/cosZ;
    return airMassOzone;
}

double getPM2p5(double aerosolOpticalDepth) {
    double PBL = 0.8;       //km
    double humid = .65;
    double PM2p5 = exp(humid)*0.1*PBL;//exp(humid)*aerosolOpticalDepth*PBL;
    return PM2p5;
}

NSString* getAQI(double PM2p5) {
        NSString *AQIuse=@"ALIS AQI";
    //0 - 11 g, 12 - 23 g, 24-35 g,36-41 y,42-47 o,48-53 o,54-58 r, 59-64 r, 65-70 purple, >=71 black
    if  (PM2p5 <= 35) {
        AQIuse =@"Good";
    }
    if (PM2p5 >=36 &&    PM2p5 <= 41) {
        AQIuse =@"Moderate";
    }
    if (PM2p5 >=42 &&    PM2p5 <= 53) {
        AQIuse =@"Poor";
            }
    if (PM2p5 >=54 &&    PM2p5 <= 64) {
        AQIuse =@"Severe";
        
    }
    if (PM2p5 >=65){
        AQIuse =@"Toxic";
        
    }
    //NSString AQI =  AQIuse;
    return AQIuse;
}

NSString* getAQIGraphic(double PM2p5) {
    NSString *pngUse;
    if  (PM2p5 <= 35) {
        
        if (PM2p5 >=0 &&    PM2p5 <= 11) {
            pngUse = @"green1_bar.png";
        } else if (PM2p5 >=12 &&    PM2p5 <= 23){
            pngUse = @"green2_bar.png";
        } else if (PM2p5 >=24 &&    PM2p5 <= 35){
            pngUse = @"green3_bar.png";
        }
    }
    if (PM2p5 >=36 &&    PM2p5 <= 41) {
        pngUse = @"yellow_bar.png";
    }
    if (PM2p5 >=42 &&    PM2p5 <= 53) {
        if (PM2p5 >=42 &&    PM2p5 <= 47) {
            pngUse = @"orange1_bar.png";
        } else if (PM2p5 >=48 &&    PM2p5 <= 53){
            pngUse = @"orange2_bar.png";
        }
    }
    if (PM2p5 >=54 &&    PM2p5 <= 64) {
        if (PM2p5 >=54 &&    PM2p5 <= 58) {
            pngUse = @"orange3_bar.png";
        } else if (PM2p5 >=59 &&    PM2p5 <= 64){
            pngUse = @"red_bar.png";
        }
    }
    if (PM2p5 >=65){
        if (PM2p5 >=65 &&    PM2p5 <= 70) {
            pngUse = @"purple_bar.png";
        } else if (PM2p5 >=71 ){
            pngUse = @"black_bar.png";
        }
    }
    return pngUse;
    
}


NSString* getTime(double sumTest) {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *TodayString = [df stringFromDate:[NSDate date] ];
    return TodayString;
}


#pragma mark - Protocol Conformance

- (void)imageProcessorFinishedProcessingWithImage:(UIImage *)outputImage {
    self.workingImage = outputImage;
    self.imageView.image = outputImage;
}

//Segue stuff
-(void)prepareForSegue:(UIStoryboardSegue *)segue  sender:(id)sender{
    
    SecondViewController *transferViewController = segue.destinationViewController;

    NSLog(@"prepareForSegue: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"resultsSegue"])
    {
        transferViewController.airMass=getAirMass(x,self.locationManager.location.coordinate.latitude,self.locationManager.location.coordinate.longitude,self.locationManager.location.altitude);
       transferViewController.aodText=getAOD(x,transferViewController.airMass); //@"0.01"; // &(aerosolOpticalDepth);  //@"-1.0";
       transferViewController.aodRawText=x;
       transferViewController.timeText=getTime(x);
        transferViewController.PM2p5 = getPM2p5(getAOD(x,transferViewController.airMass));
        transferViewController.aqiText=getAQI(transferViewController.PM2p5);
        transferViewController.pngUseGraphic =  getAQIGraphic(transferViewController.PM2p5);
    }/*else if([segue.identifier isEqualToString:@"johnSegue"]){
      
    }*/
    
}


@end
