//
//  LYRUIMessagePart.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LYRUIMessagePart : NSObject

@property (nonatomic, strong) NSString *MIMEType;

@property (nonatomic, strong) NSData *data;

+ (instancetype)messagePartWithText:(NSString *)text;

+ (instancetype)messagePartWithImage:(UIImage *)image;

+ (instancetype)messagePartWithLocation:(CLLocationCoordinate2D)location;

@end
