//
//  LevelSelectionViewController.m
//  MonkeySwing
//
//  Created by James Paul Mason on 7/13/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "LevelSelectionContentViewController.h"

@interface LevelSelectionContentViewController ()

@end

@implementation LevelSelectionContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check for best time and high score
    if (!self.bestTimeString) {
        self.bestTimeString = @"--";
    }
    if (!self.highScoreString) {
        self.highScoreString = @"--";
    }
    
    // Load the background
    self.backgroundImageView.image = [UIImage imageNamed:self.backgroundImage];
    
    // Update the best time label with the proper font and value
    self.bestTimeLabel.text = [NSString stringWithFormat:@"%@%@", @"Best Time: ", self.bestTimeString];
    self.bestTimeLabel.font = [UIFont fontWithName:@"Flux Architect" size:16];
    self.bestTimeLabel.numberOfLines = 0; // Uses as many as needed
    self.bestTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.bestTimeLabel.textColor = [UIColor whiteColor];
    self.bestTimeLabel.shadowColor = [UIColor blackColor];
    self.bestTimeLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    
    // Update the high score label with the proper font and value
    self.highScoreLabel.text = [NSString stringWithFormat:@"%@%@", @"High Score: ", self.highScoreString];
    self.highScoreLabel.font = [UIFont fontWithName:@"Flux Architect" size:16];
    self.highScoreLabel.numberOfLines = 0; // Uses as many as needed
    self.highScoreLabel.textAlignment = NSTextAlignmentLeft;
    self.highScoreLabel.textColor = [UIColor whiteColor];
    self.highScoreLabel.shadowColor = [UIColor blackColor];
    self.highScoreLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButtonTapped:(UIButton *)sender
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"goToMainMenu" forKey:@"userSelection"];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelEndedUserSelection" object:self userInfo:userInfo];
}

- (IBAction)playButtonTapped:(UIButton *)sender {
}

@end