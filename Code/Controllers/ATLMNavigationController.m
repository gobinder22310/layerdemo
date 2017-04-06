//
//  ATLMNavigationController.m
//  Atlas Messenger
//
//  Created by Ben Blakley on 1/14/15.
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

#import "ATLMNavigationController.h"

@interface ATLMNavigationController () <UINavigationControllerDelegate>

@property (nonatomic) NSMutableArray *animationCompletionHandlers;
@property (nonatomic, getter=isAnimating) BOOL animating;

@end

@implementation ATLMNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        _animationCompletionHandlers = [NSMutableArray new];
    }
    return self;
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (delegate != self) [NSException raise:NSInternalInconsistencyException format:@"LSNavigationController must act as its own delegate."];
    [super setDelegate:delegate];
}

- (void)notifyWhenCompletionEndsUsingBlock:(void (^)())handler
{
    if (!handler) return;

    if (!self.isAnimating) {
        handler();
        return;
    }

    [self.animationCompletionHandlers addObject:[handler copy]];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) return;
    self.animating = YES;

    [[self transitionCoordinator] animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (![context isCancelled]) return;
        self.animating = NO;
        [self notifyAnimationCompletionHandlers];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.animating = NO;
    [self notifyAnimationCompletionHandlers];
}

#pragma mark - Helpers

- (void)notifyAnimationCompletionHandlers
{
    while (!self.isAnimating && self.animationCompletionHandlers.count > 0) {
        void (^handler)() = self.animationCompletionHandlers.firstObject;
        [self.animationCompletionHandlers removeObjectAtIndex:0];
        handler();
    }
}

@end

@implementation UIViewController (ATLMNavigationController)

- (ATLMNavigationController *)ATLM_navigationController
{
    if (![self.navigationController isKindOfClass:[ATLMNavigationController class]]) return nil;

    return (ATLMNavigationController *)self.navigationController;
}

@end
