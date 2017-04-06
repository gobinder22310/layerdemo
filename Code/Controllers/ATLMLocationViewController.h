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

#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>

/**
 @abstract The `ATLMLocationViewController` displays a location on an Apple Map.
 */
@interface ATLMLocationViewController : UIViewController

/**
 @abstract The 'MKMapView' the 'ATLMLocationViewController' wraps.
 @discussion Note that the mapView is initialized with its parent's frame size, 
 and that 'ATLMLocationViewController' does not take ownership of its delegate.
 You can safely modify this mapView as you see fit.
 */
@property (nonatomic, readonly) MKMapView *mapView;

@property (readonly) CLLocationCoordinate2D coordinate;

/**
 @abstact Initializes the controller with a LYRMessage object.
 @discussion The message object should contain message parts with the MIMEType `ATLMIMETypeLocation`
 */
- (instancetype)initWithMessage:(LYRMessage *)message;

/**
 @abstact Initializes the controller with a CLLocationCoordinate2D.
 */
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
