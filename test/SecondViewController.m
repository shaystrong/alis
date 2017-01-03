//
//  SecondViewController.m
//  test
//
//  Created by Strong, Shadrian B. on 7/22/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import "SecondViewController.h"
#import <Social/Social.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"

#import "ArchiveTableViewController.h"
@interface SecondViewController ()
@property (nonatomic) NSArray *myArray;

@end

@implementation SecondViewController
//@synthesize aerosolOpticalDepth;
//@synthesize mapView;
@synthesize pngUse;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.AOD.text= [NSString stringWithFormat: @"%f", self.aodText];
    self.AIRMASS.text= [NSString stringWithFormat: @"%f", (double)self.airMass];
    self.timeNow.text=self.timeText;
    self.AQI.text = self.aqiText;
    //0 - 11 g, 12 - 23 g, 24-35 g,36-41 y,42-47 o,48-53 o,54-58 r, 59-64 r, 65-70 purple, >=71 black
    //self.AQI.textColor
    UIImage *image = [UIImage imageNamed: _pngUseGraphic];
    [pngUse setImage:image];
    self.aodRAWnum.text = [NSString stringWithFormat: @"%f",self.aodRawText];
    
}
- (IBAction)didSave:(id)sender
{
   // NSError *error;
    //NSString * string3 = ['log' stringByAppendingString:[string2 stringByAppendingString:@" Adding a third string."]];


    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyyMMdd_hhmmss"];
    NSLog(@"%@",[DateFormatter stringFromDate:[NSDate date]]);
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[DateFormatter stringFromDate:[NSDate date]]];//  @"log.txt"];
    //[NSArray arrayWithObjects: @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil]

    // Write to the file
    //[NSArray arrayWithObjects: @self.AOD.text, @self.AIRMASS.text,@self.timeNow.text,@self.AQI.text,@self.aodRAWnum.text];
    //[self.AOD.text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
   NSArray *myArray = [NSArray arrayWithObjects:self.AOD.text, self.AIRMASS.text,self.timeNow.text,self.AQI.text,self.aodRAWnum.text, nil];
//  [myArray writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    BOOL success = [myArray writeToFile:filePath atomically:YES];
    NSAssert(success, @"writeToFile failed");
//
    NSLog(@"Observation Saved");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postToFacebook:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Using ALIS, the air quality here is: "];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*- (IBAction)zoomIn:(id)sender {
    MKUserLocation *userLocation = _mapView.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        userLocation.location.coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
}
*/





-(void)prepareForSegue:(UIStoryboardSegue *)segue  sender:(id)sender{
    
    MapViewController *transferViewController = segue.destinationViewController;
    ArchiveTableViewController *transferViewController2 = segue.destinationViewController;
    NSLog(@"prepareForSegue: %@", segue.identifier);
    if([segue.identifier isEqualToString:@"mapSegue"])
    {
        transferViewController.mapAOD=self.AOD.text; //@"0.01"; // &(aerosolOpticalDepth);  //@"-1.0";
        
    }else if([segue.identifier isEqualToString:@"archiveSegue"]){
                transferViewController2.timeObs = self.timeNow.text;
//        + self.aodRAWnum.text ;
        //transferViewController2.timeObs = [self.timeNow.text stringByAppendingString:self.aodRAWnum.text];
        
      }
    
}

@end
