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
            UIButton *resetMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            resetMonkeyButton.center = self.center;
            [resetMonkeyButton setFrame:frame];
            [resetMonkeyButton setImage:[UIImage imageNamed:@"SadMonkey"] forState:UIControlStateNormal];
            [resetMonkeyButton setImage:[UIImage imageNamed:@"MonkeyClicked"] forState:UIControlStateSelected];
            [resetMonkeyButton addTarget:self action:@selector(restartAction) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:resetMonkeyButton];
        } else if ([outcome isEqualToString:@"monkeyWon"]) {
            NSLog(@"Monkey Won!");
            // TODO: Implement this method
        } else if ([outcome isEqualToString:@"gameOver"]) {
            NSLog(@"Game over, sucak!");
            // TODO: Implement this method
        }

    }
    return self;
}

#pragma mark - User selection actions
- (void)restartAction
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