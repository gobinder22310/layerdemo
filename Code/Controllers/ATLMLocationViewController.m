//
//  ATLMLocationViewController.h
//  Atlas Messenger
//
//  Created by JP McGlone on 12/21/16.
//  Copyright (c) 2016 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMLocationViewController.h"
#import <MapKit/MapKit.h>
#import <Atlas/Atlas.h>

@interface ATLMLocationViewController ()

@property (nonatomic) LYRMessage *message;
@property (nonatomic) MKMapView *mapView;

@end

@implementation ATLMLocationViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call the designated initializer. Use initWithNibName:bundle:layerClient:" userInfo:nil];
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (instancetype)initWithMessage:(LYRMessage *)message
{
    // TODO: Consider making a LYRMessage category to more easily pull out
    // models from their MIME Types. Example: .location, .mp4, .gif, etc.
    LYRMessagePart *messagePart = message.parts.firstObject;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[ATLLocationLatitudeKey] doubleValue];
    double lon = [dictionary[ATLLocationLongitudeKey] doubleValue];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    
    self = [self initWithCoordinate:coordinate];
    if (self) {
        _message = message;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Map View
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mapView];
    
    [self setPinAtCoordinate:self.coordinate];
    [self zoomAtCoordinate:self.coordinate delta:0.005];
    
    // Navigation Items
    // Only show the done button if this viewController is the root
    // ViewController of its UINavigationController
    UIViewController *rootViewController = [[self.navigationController viewControllers] firstObject];
    if ([rootViewController isEqual:self]) {
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        self.navigationItem.leftBarButtonItem = doneButtonItem;
    }
    
    NSString *title = NSLocalizedString(@"Open in Maps", "'Maps': Proper noun, the Apple 'Maps' app");
    UIBarButtonItem *mapsButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(openMaps:)];
    self.navigationItem.rightBarButtonItem = mapsButtonItem;
}

- (void)setPinAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [self.mapView addAnnotation:annotation];
}

- (void)zoomAtCoordinate:(CLLocationCoordinate2D)coordinate delta:(CLLocationDegrees)delta
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = coordinate;
    mapRegion.span.latitudeDelta = delta;
    mapRegion.span.longitudeDelta = delta;
    
    [self.mapView setRegion:mapRegion animated: YES];
}

- (void)openMaps:(id)sender
{
    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)done:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
