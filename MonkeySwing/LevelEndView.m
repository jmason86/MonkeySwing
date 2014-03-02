//
//  LevelEndView.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/18/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "LevelEndView.h"

@implementation LevelEndView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *resetMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resetMonkeyButton.center = self.center;
        [resetMonkeyButton setFrame:frame];
        [resetMonkeyButton setImage:[UIImage imageNamed:@"SadMonkey"] forState:UIControlStateNormal];
        [resetMonkeyButton setImage:[UIImage imageNamed:@"MonkeyClicked"] forState:UIControlStateSelected];
        [resetMonkeyButton addTarget:self action:@selector(restartAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resetMonkeyButton];
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