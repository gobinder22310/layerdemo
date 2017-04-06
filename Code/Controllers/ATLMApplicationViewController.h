//
//  ATLMApplicationViewController.h
//  Atlas Messenger
//
//  Created by Klemen Verdnik on 6/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMLayerController.h"

/**
 @abstract The `ATLMApplicationViewController` is responsible for taking care
   of the UI. It listens on the `ATLMLayerController` state changes and
   configures the UI accordingly. It also works with the `UIApplication` to
   setup remote notification registration and updating the icon badge counts.
 */
@interface ATLMApplicationViewController : UIViewController <ATLMLayerControllerDelegate>

/**
 @abstract Reference to the application controller view controller works with
   to present the appropriate UI and perform authentication when needed.
 */
@property (nonnull, nonatomic) ATLMLayerController *layerController;

@end
