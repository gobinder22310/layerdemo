//
//  LYRUIMessagePart.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessagePart.h"

@implementation LYRUIMessagePart

static NSString *const LYRUIMIMETypeTextPlain = @"text/plain";
static NSString *const LYRUIMIMETypeImagePNG = @"image/png";
static NSString *const LYRUIMIMETypeImageJPEG = @"image/jpeg";
static NSString *const LYRUIMIMETypeLocationCoodrinate = @"loaction/coordinate";

+ (instancetype)messagePartWithText:(NSString *)text
{
    LYRUIMessagePart *messagePart = [super init];
    messagePart.data = [text dataUsingEncoding:NSUTF8StringEncoding];
    messagePart.MIMEType = LYRUIMIMETypeTextPlain;
    return messagePart;
}

+ (instancetype)messagePartWithImage:(UIImage *)image
{
    LYRUIMessagePart *messagePart = [super init];
    messagePart.data =  UIImageJPEGRepresentation(image, 1.0);
    messagePart.MIMEType = LYRUIMIMETypeImageJPEG;
    return messagePart;
}

//+ (instancetype)messagePartWithLocation:(CLLocationCoordinate2D)location
//{
//    
//}

@end
