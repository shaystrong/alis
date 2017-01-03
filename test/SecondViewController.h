//
//  SecondViewController.h
//  test
//
//  Created by Strong, Shadrian B. on 7/22/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SecondViewController : UIViewController
@property (strong,nonatomic) IBOutlet UILabel *AOD;
@property (strong,nonatomic) IBOutlet UILabel *Attenuate;
@property (strong,nonatomic) IBOutlet UILabel *AIRMASS;
@property (strong,nonatomic) IBOutlet UILabel *AQI;
@property (strong,nonatomic) IBOutlet UILabel *timeNow;
@property (strong,nonatomic) IBOutlet UILabel *aodRAWnum;
@property (nonatomic, retain) IBOutlet UIImageView *pngUse;



@property (nonatomic)           double aodText;
@property (nonatomic)           double airMass;
@property (nonatomic)           double aodRawText;

@property (strong, nonatomic)  NSString *attenText;
@property (strong, nonatomic)  NSString *aqiText;
@property (strong,nonatomic)   NSString *pngUseGraphic;
@property (strong, nonatomic)  NSString *timeText;
@property (nonatomic)  double PM2p5;
- (IBAction)postToFacebook:(id)sender;

@end
