//
//  MapViewController.m
//  ALIS
//
//  Created by Strong, Shadrian B. on 7/31/14.
//  Copyright (c) 2014 ALIS. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = userLocation.coordinate;
    point.title = @"alis AQI";
    point.subtitle = self.mapAOD;
    
    [self.mapView addAnnotation:point];
}

@end
