//
//  ATLMMediaViewController.h
//  Atlas Messenger
//
//  Created by Ben Blakley on 1/16/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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
 @abstract The `ATLMImageViewController` downloads and displays a high quality version of an image.
 */
@interface ATLMMediaViewController : UIViewController

/** 
 @abstact Initializes the controller with a message object. 
 @discussion The message object should contain message parts with MIMETypes of `ATLMIMETypeImageJPEG`, `ATLMIMETypeImageJPEGPreview`, `ATLMIMETypeImageSize`.
 */
- (instancetype)initWithMessage:(LYRMessage *)message;

@end
