//
//  MapViewController.h
//  ALIS
//
//  Created by Strong, Shadrian B. on 7/31/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
//- (IBAction)changeMapType:(id)sender;
@property (strong, nonatomic)            NSString *mapAOD;

@end
