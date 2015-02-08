//
//  PageContentViewController.m
//  MonkeySwing
//
//  Created by James Paul Mason on 7/15/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MainMenuContentViewController.h"

@interface MainMenuContentViewController ()

@end

@implementation MainMenuContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [UIImage imageNamed:self.backgroundImage];
    
    // If on the main page, add the levels button, continue button (if applicable), monkey, and rope
    if (self.pageIndex == 0) {
        UIImage *levelsButtonImage = [UIImage imageNamed:@"LevelButton"];
        UIButton *levelsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        levelsButton.frame = CGRectMake(0, 0, levelsButtonImage.size.width, levelsButtonImage.size.height);
        [levelsButton setImage:levelsButtonImage forState:UIControlStateNormal];
        [levelsButton addTarget:self action:@selector(levelsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        levelsButton.opaque = YES;
        levelsButton.tag = 1;
        levelsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:levelsButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:levelsButton attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0 constant:-16]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:levelsButton attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0 constant:16]];
        
        
        UIImageView *monkeyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MonkeyAngry"]];
        monkeyImageView.center = CGPointMake(-25, 50);
        monkeyImageView.tag = 1;
        
        UIImageView *ropeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rope"]];
        ropeImageView.center = CGPointMake(self.view.center.y + monkeyImageView.image.size.width/2 - 30, -40);
        ropeImageView.tag = 1;
        [self.view addSubview:ropeImageView];
        [ropeImageView addSubview:monkeyImageView]; // TODO: Just added this to ropeimageview instead of self.view. Need to change the center point of the monkey. Then can animate just one layer.
        
        // Animate monkey swinging on rope
        monkeyImageView.layer.anchorPoint = CGPointMake(0,0);
        ropeImageView.layer.anchorPoint = CGPointMake(0, 0);
        CABasicAnimation* swingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [swingAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        [swingAnimation setFromValue:[NSNumber numberWithFloat:M_PI/3]];
        [swingAnimation setDuration:2];
        [swingAnimation setRepeatCount:HUGE_VALF];
        [swingAnimation setAutoreverses:YES];
        [swingAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [monkeyImageView.layer addAnimation:swingAnimation forKey:@"SwingingRotation"];
        [ropeImageView.layer addAnimation:swingAnimation forKey:@"SwingRotation"];
        
        self.isContinueButtonAvailable = YES; // TODO: This boolean should be triggered appropriately
        if (self.isContinueButtonAvailable == YES) {
            UIImage *continueButtonImage = [UIImage imageNamed:@"ContinueButton"];
            UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
            continueButton.frame = CGRectMake(0, 0, continueButtonImage.size.width, continueButtonImage.size.height);
            [continueButton setImage:continueButtonImage forState:UIControlStateNormal];
            [continueButton addTarget:self action:@selector(continueButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            continueButton.opaque = YES;
            [self.view addSubview:continueButton];
            continueButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:continueButton attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.backgroundImageView attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:-16]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:continueButton attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0 constant:-16]];
            // DEBUG: Figure out autolayout for iPad mini and iPhone 5s
            /*NSLog(@"%@", [continueButton constraintsAffectingLayoutForAxis:1]);
            NSLog(@"%@", [continueButton constraintsAffectingLayoutForAxis:0]);
            */
            for (UIView *aView in [self.view subviews]) {
                if ([aView hasAmbiguousLayout]) {
                    NSLog(@"View Frame %@", NSStringFromCGRect(aView.frame));
                    NSLog(@"%@", [aView class]);
                    NSLog(@"%@", [aView constraintsAffectingLayoutForAxis:1]);
                    NSLog(@"%@", [aView constraintsAffectingLayoutForAxis:0]);
                    
                    [aView exerciseAmbiguityInLayout];
                }
            }
            
        }
    }
    
    // If on settings page, add the monkey gear, music switch, sound switch, and reset button
    if (self.pageIndex == 1) {
        UIImageView *monkeyGearImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MonkeyGearTail"]];
        monkeyGearImageView.center = CGPointMake(80, -40);// + monkeyGearImageView.image.size.height/2);
        [self.view addSubview:monkeyGearImageView];
        
        // Animate monkey gear
        monkeyGearImageView.layer.anchorPoint = CGPointMake(0,0);
        CABasicAnimation* swingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [swingAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        [swingAnimation setFromValue:[NSNumber numberWithFloat:M_PI/3]];
        [swingAnimation setDuration:2];
        [swingAnimation setRepeatCount:HUGE_VALF];
        [swingAnimation setAutoreverses:YES];
        [swingAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [monkeyGearImageView.layer addAnimation:swingAnimation forKey:@"SwingingRotation"];
        
        UISwitch *musicSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; // This frame gets overridden anyway
        musicSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        musicSwitch.on = YES;
        [musicSwitch addTarget:self action:@selector(musicSwitchToggled) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:musicSwitch];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:musicSwitch attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.backgroundImageView attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0 constant:-16]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:musicSwitch attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.backgroundImageView attribute:NSLayoutAttributeTop
                                                             multiplier:1.0 constant:95]];
        
        
        UISwitch *soundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        soundSwitch.translatesAutoresizingMaskIntoConstraints = NO;
        soundSwitch.on = YES;
        [soundSwitch addTarget:self action:@selector(soundSwitchToggled) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:soundSwitch];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:soundSwitch attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:musicSwitch attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:soundSwitch attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:musicSwitch attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0 constant:30]];
        
        UIImage *resetButtonImage = [UIImage imageNamed:@"ResetButton"];
        UIButton *resetButton= [UIButton buttonWithType:UIButtonTypeCustom];
        resetButton.frame = CGRectMake(0, 0, resetButtonImage.size.width, resetButtonImage.size.height);
        resetButton.translatesAutoresizingMaskIntoConstraints = NO;
        [resetButton setImage:resetButtonImage forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(resetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        resetButton.opaque = YES;
        [self.view addSubview:resetButton];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:resetButton attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:soundSwitch attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:resetButton attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:soundSwitch attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0 constant:30]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)levelsButtonTapped
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelsButtonTapped" object:self userInfo:nil];
}

- (void)continueButtonTapped
{
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"continueButtonTapped" object:self userInfo:nil];
}

- (void)musicSwitchToggled
{
    
}

- (void)soundSwitchToggled
{
    
}

- (void)resetButtonTapped
{
    
}

@end