//
//  LSRegistrationViewController.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLMRegistrationViewController.h"
#import "ATLLogoView.h"
#import <Atlas/Atlas.h>
#import "ATLMConstants.h"
#import "ATLMUtilities.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLMConstants.h"
#import "ATLMErrors.h"
#import "ATLMUserCredentials.h"

@interface ATLMRegistrationViewController () <UITextFieldDelegate>

@property (nonatomic) ATLLogoView *logoView;
@property (nonatomic) UITextField *emailTextField;
@property (nonatomic) UITextField *passwordTextField;
@property (nonatomic) NSLayoutConstraint *emailTextFieldBottomConstraint;
@property (nonatomic) NSLayoutConstraint *passwordTextFieldBottomConstraint;

@end

@implementation ATLMRegistrationViewController

CGFloat const ATLMLogoViewBCenterYOffset = 184;
CGFloat const ATLMEmailTextFieldWidthRatio = 0.8;
CGFloat const ATLMEmailTextFieldHeight = 52;
CGFloat const ATLMEmailTextFieldBottomPadding = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoView = [[ATLLogoView alloc] init];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoView];
    
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.emailTextField.delegate = self;
    self.emailTextField.placeholder = @"Email Address";
    self.emailTextField.textAlignment = NSTextAlignmentCenter;
    self.emailTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.emailTextField.layer.borderWidth = 0.5;
    self.emailTextField.layer.cornerRadius = 2;
    self.emailTextField.font = [UIFont systemFontOfSize:22];
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.emailTextField ];
    
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordTextField.delegate = self;
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.textAlignment = NSTextAlignmentCenter;
    self.passwordTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.passwordTextField.layer.borderWidth = 0.5;
    self.passwordTextField.layer.cornerRadius = 2;
    self.passwordTextField.font = [UIFont systemFontOfSize:22];
    self.passwordTextField.returnKeyType = UIReturnKeyGo;
    self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordTextField.secureTextEntry = YES;
    [self.view addSubview:self.passwordTextField ];
    
    [self configureLayoutConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.passwordTextFieldBottomConstraint.constant = -rect.size.height - ATLMEmailTextFieldBottomPadding;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        NSString *email = self.emailTextField.text;
        NSString *password = self.passwordTextField.text;
        [self registerAndAuthenticateUserWithEmail:email password:password];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (void)registerAndAuthenticateUserWithEmail:(NSString *)email password:(NSString *)password
{
    [self.view endEditing:YES];

    // Gather and send the credentials to the delegate.
    ATLMUserCredentials *credentials = [[ATLMUserCredentials alloc] initWithEmail:email password:password];
    if ([self.delegate respondsToSelector:@selector(registrationViewController:didSubmitCredentials:)]) {
        [self.delegate registrationViewController:self didSubmitCredentials:credentials];
    }
}

- (void)configureLayoutConstraints
{
    // Logo View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-ATLMLogoViewBCenterYOffset]];
    
    // Registration View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:ATLMEmailTextFieldWidthRatio constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMEmailTextFieldHeight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.emailTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeTop multiplier:1.0 constant:-ATLMEmailTextFieldBottomPadding]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:ATLMEmailTextFieldWidthRatio constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMEmailTextFieldHeight]];
    self.passwordTextFieldBottomConstraint = [NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLMEmailTextFieldBottomPadding];
    [self.view addConstraint:self.passwordTextFieldBottomConstraint];
}

@end
