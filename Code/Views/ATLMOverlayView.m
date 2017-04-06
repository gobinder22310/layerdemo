//
//  LSOverlayView.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLMOverlayView.h"
#import <Atlas/Atlas.h> 
#import "ATLMConstants.h"

@interface ATLMOverlayView ()

@property (nonatomic) UILabel *instructionsLabel;
@property (nonatomic) UIImageView *logoImageView;

@end

@implementation ATLMOverlayView

CGFloat const ATLMQRScannerTopPadding = 100;
CGFloat const ATLMQRScannerSize = 240;
CGFloat const ATLMInstructionsLabelTopPadding = 32;
CGFloat const ATLMLogoImageViewTopPadding = 26;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupOverlayMaskWithFrame:frame];
        
        _instructionsLabel = [[UILabel alloc] init];
        _instructionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _instructionsLabel.numberOfLines = 3;
        _instructionsLabel.text = @"POINT THE DEVICE\n TOWARDS YOUR SCREEN\n AND SCAN THE CODE";
        _instructionsLabel.textAlignment = NSTextAlignmentCenter;
        _instructionsLabel.font = ATLMLightFont(24);
        _instructionsLabel.textColor = [UIColor whiteColor];
        [_instructionsLabel sizeToFit];
        [self addSubview:_instructionsLabel];
        
        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"layer-logo"]];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_logoImageView];
        
        [self configureLayoutConstraints];
    }
    return self;
}

- (void)setupOverlayMaskWithFrame:(CGRect)frame
{
    CGFloat size = 240;
    CGFloat originX = (frame.size.width / 2) - (size / 2);
    CGFloat originY = ATLMQRScannerTopPadding;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:0];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(originX, originY, size, size) cornerRadius:10];
    [path appendPath:cutoutPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.6;
    [self.layer addSublayer:fillLayer];
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.path =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(originX - 1, originY - 1, size + 2, size + 2) cornerRadius:10].CGPath;
    borderLayer.cornerRadius = 10;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
    borderLayer.lineDashPattern = @[@6, @6];
    [self.layer addSublayer:borderLayer];
}

- (void)configureLayoutConstraints
{
    // Instructions Label Constraints
    CGFloat top = ATLMQRScannerSize + ATLMQRScannerTopPadding + ATLMInstructionsLabelTopPadding;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_instructionsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:top]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_instructionsLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    // Logo Image View;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_instructionsLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ATLMLogoImageViewTopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}


@end
