//
//  ATLLogoView.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLLogoView.h"
#import <Atlas/Atlas.h> 
#import "ATLMConstants.h"

@interface ATLLogoView ()

@property (nonatomic) UILabel *atlasLabel;
@property (nonatomic) UILabel *poweredByLabel;
@property (nonatomic) UIImageView *logoImageView;

@end

@implementation ATLLogoView

CGFloat const ATLMLogoSize = 18;
CGFloat const ATLMLogoLeftPadding = 4;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSMutableAttributedString *atlasString = [[NSMutableAttributedString alloc] initWithString:@"ATLAS MESSENGER"];
        [atlasString addAttribute:NSFontAttributeName value:ATLMUltraLightFont(26) range:NSMakeRange(0, atlasString.length)];
        [atlasString addAttribute:NSForegroundColorAttributeName value:ATLBlueColor() range:NSMakeRange(0, atlasString.length)];
        [atlasString addAttribute:NSKernAttributeName value:@(12.0) range:NSMakeRange(0, atlasString.length)];
        
        _atlasLabel = [[UILabel alloc] init];
        _atlasLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _atlasLabel.attributedText = atlasString;
        [_atlasLabel sizeToFit];
        [self addSubview:_atlasLabel];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Powered By "];
        [attributedString addAttribute:NSForegroundColorAttributeName value:ATLGrayColor() range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSFontAttributeName value:ATLLightFont(9) range:NSMakeRange(0, attributedString.length)];
        
        _poweredByLabel = [[UILabel alloc] init];
        _poweredByLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _poweredByLabel.attributedText = attributedString;
        [_poweredByLabel sizeToFit];
        [self addSubview:_poweredByLabel];
        
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _logoImageView.image = [UIImage imageNamed:@"layer-logo-gray"];
        [self addSubview:_logoImageView];
        
        [self configureLayoutConstraints];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(320, 80);
}

- (void)configureLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_atlasLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_atlasLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    CGFloat poweredByLabelOffset = (ATLMLogoSize + ATLMLogoLeftPadding) / ATLMLogoLeftPadding;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_poweredByLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-poweredByLabelOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_poweredByLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_atlasLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_poweredByLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:ATLMLogoLeftPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_logoImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_poweredByLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

@end
