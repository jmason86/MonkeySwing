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
        levelsButton.center = CGPointMake(0 + levelsButtonImage.size.width/2 + 5, self.view.bounds.size.width - levelsButtonImage.size.height/2 - 5); // Have to use self.view.bounds.size.width for the height here because iOS doesn't know that I'm in landscape for some reason
        [levelsButton setImage:levelsButtonImage forState:UIControlStateNormal];
        [levelsButton addTarget:self action:@selector(levelsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        levelsButton.opaque = YES;
        levelsButton.tag = 1;
        [self.view addSubview:levelsButton];
        
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
            continueButton.center = CGPointMake(self.view.bounds.size.height - continueButtonImage.size.width/2 - 5, self.view.bounds.size.width - continueButtonImage.size.height/2 - 5);
            [continueButton setImage:continueButtonImage forState:UIControlStateNormal];
            [continueButton addTarget:self action:@selector(continueButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            continueButton.opaque = YES;
            [self.view addSubview:continueButton];
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
        musicSwitch.center = CGPointMake(self.view.bounds.size.height - musicSwitch.bounds.size.width/2 - 10, 108);
        musicSwitch.on = YES;
        [musicSwitch addTarget:self action:@selector(musicSwitchToggled) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:musicSwitch];
        
        UISwitch *soundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        soundSwitch.center = CGPointMake(musicSwitch.center.x, musicSwitch.center.y + 65);
        soundSwitch.on = YES;
        [soundSwitch addTarget:self action:@selector(soundSwitchToggled) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:soundSwitch];
        
        UIImage *resetButtonImage = [UIImage imageNamed:@"ResetButton"];
        UIButton *resetButton= [UIButton buttonWithType:UIButtonTypeCustom];
        resetButton.frame = CGRectMake(0, 0, resetButtonImage.size.width, resetButtonImage.size.height);
        resetButton.center = CGPointMake(soundSwitch.center.x, soundSwitch.center.y + 65); // Have to use self.view.bounds.size.width for the height here because iOS doesn't know that I'm in landscape for some reason
        [resetButton setImage:resetButtonImage forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(resetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        resetButton.opaque = YES;
        [self.view addSubview:resetButton];
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