//
//  LevelEndView.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/18/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "LevelEndView.h"

@implementation LevelEndView

@synthesize playerLevelRunData;

#pragma mark - Initialization methods

- (id)initWithFrame:(CGRect)frame forOutcome:(NSString *)outcome withRunData:(PlayerLevelRunData *)playerLevelRunDataInput
{
    self = [super initWithFrame:frame];
    if (self) {
        playerLevelRunData = playerLevelRunDataInput; // Only have to do this because need to use initWithFrame so can't call a normall setter method first
        
        // Send to relevant method for outcome
        if ([outcome isEqualToString:@"monkeyFell"]) {
            [self setupMonkeyFell];
        } else if ([outcome isEqualToString:@"gameOver"]) {
            [self setupGameOver];
        } else if ([outcome isEqualToString:@"monkeyWon"]) {
            [self setupMonkeyWon];
        }
    }
    return self;
}

- (void)setupMonkeyFell
{
    // Button to respawn
    UIImage *respawnImage = [UIImage imageNamed:@"Respawn"];
    UIButton *respawnMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    respawnMonkeyButton.frame = CGRectMake(0, 0, respawnImage.size.width, respawnImage.size.height);
    respawnMonkeyButton.center = self.center;
    [respawnMonkeyButton setImage:respawnImage forState:UIControlStateNormal];
    [respawnMonkeyButton setImage:[UIImage imageNamed:@"RespawnClicked"] forState:UIControlStateSelected];
    [respawnMonkeyButton addTarget:self action:@selector(respawnAction) forControlEvents:UIControlEventTouchUpInside];
    respawnMonkeyButton.opaque = YES;
    [self addSubview:respawnMonkeyButton];
    
    // Label showing how many monkeys you've killed
    UILabel *numberOfDeadMonkeysLabel = [[UILabel alloc] initWithFrame:CGRectMake(respawnMonkeyButton.center.x - 200, respawnMonkeyButton.center.y - respawnImage.size.height/2.0 - 40, 400, 40)];
    if (playerLevelRunData.numberOfTimesDied == 1) {
        numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You've killed ", playerLevelRunData.numberOfTimesDied, @" monkey"];
    } else {
        numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You've killed ", playerLevelRunData.numberOfTimesDied, @" monkeys"];
    }
    numberOfDeadMonkeysLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:26];
    numberOfDeadMonkeysLabel.textAlignment = NSTextAlignmentCenter;
    numberOfDeadMonkeysLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberOfDeadMonkeysLabel];
}

- (void)setupGameOver
{
    // TODO: Implement method
    
}

- (void)setupMonkeyWon
{
    // Button for playing the level again
    UIImage *playAgainImage = [UIImage imageNamed:@"PlayAgain"];
    UIButton *playAgainMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playAgainMonkeyButton.frame = CGRectMake(0, 0, playAgainImage.size.width, playAgainImage.size.height);
    playAgainMonkeyButton.center = self.center;
    [playAgainMonkeyButton setImage:playAgainImage forState:UIControlStateNormal];
    [playAgainMonkeyButton setImage:[UIImage imageNamed:@"PlayAgainClicked"] forState:UIControlStateSelected];
    [playAgainMonkeyButton addTarget:self action:@selector(playAgainAction) forControlEvents:UIControlEventTouchUpInside];
    playAgainMonkeyButton.opaque = YES;
    [self addSubview:playAgainMonkeyButton];
    
    // Label showing final score
    UILabel *playerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(playAgainMonkeyButton.center.x, playAgainMonkeyButton.center.y - playAgainImage.size.height/2.0 - 40, 120, 40)];
    playerScoreLabel.text = [NSString stringWithFormat:@"%li", (long)playerLevelRunData.totalPoints];
    playerScoreLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:36];
    playerScoreLabel.textColor = [UIColor whiteColor];
    [self addSubview:playerScoreLabel];
    
    // TOOD: Label comparing score to Game Center friends (just top friend? just nearest more points friend?)
    NSInteger competitorScore = [self getCompetitorScore];
    if (competitorScore != 0) {
        UILabel *competitorScoreLabel = [[UILabel alloc] init];
        competitorScoreLabel.text = [NSString stringWithFormat:@"%li", (long)competitorScore];
        competitorScoreLabel.center = CGPointMake(playerScoreLabel.center.x + playerScoreLabel.bounds.size.width + 10, playerScoreLabel.center.y);
        competitorScoreLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:14];
        competitorScoreLabel.textColor = [UIColor orangeColor];
        [self addSubview:competitorScoreLabel];
    }
    
    // TODO: Button for returning to main screen
    
    
    // TODO: Button for going to next level
    
    
}

#pragma mark - User selection actions

- (void)respawnAction
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"restartLevel" forKey:@"userSelection"];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelEndedUserSelection" object:self userInfo:userInfo];
}

- (void)playAgainAction
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"restartLevel" forKey:@"userSelection"];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelEndedUserSelection" object:self userInfo:userInfo];
}

- (void)nextLevelAction
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"goToNextLevel" forKey:@"userSelection"];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelEndedUserSelection" object:self userInfo:userInfo];
}

- (void)mainMenuAction
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"goToMainMenu" forKey:@"userSelection"];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"levelEndedUserSelection" object:self userInfo:userInfo];
}

#pragma mark - Game Center methods

- (NSInteger)getCompetitorScore
{
    return 0;
}

@end