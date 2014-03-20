//
//  LevelEndView.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/18/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "LevelEndView.h"

@implementation LevelEndView

#pragma mark - Initialization methods

- (id)initWithFrame:(CGRect)frame forOutcome:(NSString *)outcome
{
    self = [super initWithFrame:frame];
    if (self) {
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
    UIButton *resetMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetMonkeyButton.center = self.center;
    [resetMonkeyButton setImage:[UIImage imageNamed:@"Respawn"] forState:UIControlStateNormal];
    [resetMonkeyButton setImage:[UIImage imageNamed:@"RespawnClicked"] forState:UIControlStateSelected];
    [resetMonkeyButton addTarget:self action:@selector(respawnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resetMonkeyButton];
}

- (void)setupGameOver
{
    // TODO: Implement method
    
}

- (void)setupMonkeyWon
{
    // TODO: Label showing final score
    
    
    // TOOD: Label comparing score to Game Center friends (just top friend? just nearest more points friend?)
    
    // Button for playing the level again
    UIButton *playAgainMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playAgainMonkeyButton.center = self.center;
    [playAgainMonkeyButton setImage:[UIImage imageNamed:@"PlayAgain"] forState:UIControlStateNormal];
    [playAgainMonkeyButton setImage:[UIImage imageNamed:@"PlayAgainClicked"] forState:UIControlStateSelected];
    [playAgainMonkeyButton addTarget:self action:@selector(playAgainAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playAgainMonkeyButton];
    
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

@end