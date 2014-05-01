//
//  LevelEndView.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/18/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "LevelEndView.h"
#import "GameKitHelper.h"

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
    // Respawn button
    UIImage *respawnImage = [UIImage imageNamed:@"RespawnButton"];
    UIButton *respawnMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    respawnMonkeyButton.frame = CGRectMake(0, 0, respawnImage.size.width, respawnImage.size.height);
    respawnMonkeyButton.center = self.center;
    [respawnMonkeyButton setImage:respawnImage forState:UIControlStateNormal];
    [respawnMonkeyButton setImage:[UIImage imageNamed:@"RespawnButtonClicked"] forState:UIControlStateSelected];
    [respawnMonkeyButton addTarget:self action:@selector(respawnAction) forControlEvents:UIControlEventTouchUpInside];
    respawnMonkeyButton.opaque = YES;
    [self addSubview:respawnMonkeyButton];
    
    // Menu button
    UIImage *menuImage = [UIImage imageNamed:@"MenuButton"];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    menuButton.center = CGPointMake(self.bounds.size.width - menuImage.size.width/2 - 10, self.bounds.size.height - menuImage.size.height/2 - 10);
    [menuButton setImage:menuImage forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"MenuButtonClicked"] forState:UIControlStateSelected];
    [menuButton addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
    menuButton.opaque = YES;
    [self addSubview:menuButton];
    
    // Label showing how many monkeys you've killed
    UILabel *numberOfDeadMonkeysLabel = [[UILabel alloc] initWithFrame:CGRectMake(respawnMonkeyButton.center.x - 200, respawnMonkeyButton.center.y - respawnImage.size.height/2.0 - 40, 400, 40)];
    if (playerLevelRunData.numberOfTimesDied == 1) {
        numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You've killed ", (long)playerLevelRunData.numberOfTimesDied, @" monkey"];
    } else {
        numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You've killed ", (long)playerLevelRunData.numberOfTimesDied, @" monkeys"];
    }
    numberOfDeadMonkeysLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:26];
    numberOfDeadMonkeysLabel.textAlignment = NSTextAlignmentCenter;
    numberOfDeadMonkeysLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberOfDeadMonkeysLabel];
    
    // Label pointing out how much the fire has progressed
    UILabel *fireProgressionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 200)];
    int fireProgression = roundf(playerLevelRunData.fireProgression * 100.);
    fireProgressionLabel.text = [NSString stringWithFormat:@"%@%i%@", @"Fire is ", fireProgression, @"% of the way to your banana!"];
    fireProgressionLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:16];
    fireProgressionLabel.numberOfLines = 0; // Uses as many as needed
    fireProgressionLabel.textAlignment = NSTextAlignmentLeft;
    fireProgressionLabel.textColor = [UIColor whiteColor];
    [self addSubview:fireProgressionLabel];
    
    // Add arrow between HUD and fire progression label
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    UIImage *hudFire = [UIImage imageNamed:@"HudFire"];
    arrowView.center = CGPointMake(hudFire.size.width * playerLevelRunData.fireProgression, hudFire.size.height * 2);
    [self addSubview:arrowView];
}

- (void)setupGameOver
{
    // Prepare the correct image for the restart button
    UIImage *gameOverImage;
    UILabel *gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x, self.center.y, 400, 40)];
    if (playerLevelRunData.fireProgression >= 1) {
        gameOverImage = [UIImage imageNamed:@"GameOverByFireButton"];
        gameOverLabel.text = @"The fire consumed your bananna!";
    } else {
        gameOverImage = [UIImage imageNamed:@"DeadMonkeysButton"];
        gameOverLabel.text = @"You killed all the monkeys!";
    }
    
    // Game over button
    UIButton *gameOverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gameOverButton.frame = CGRectMake(0, 0, gameOverImage.size.width, gameOverImage.size.height);
    gameOverButton.center = self.center;
    [gameOverButton setImage:gameOverImage forState:UIControlStateNormal];
    [gameOverButton setImage:[UIImage imageNamed:@"GameOverByFireButtonClicked"] forState:UIControlStateSelected];
    [gameOverButton addTarget:self action:@selector(playAgainAction) forControlEvents:UIControlEventTouchUpInside];
    gameOverButton.opaque = YES;
    [self addSubview:gameOverButton];
    
    // Game over label
    gameOverLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:26];
    gameOverLabel.textAlignment = NSTextAlignmentCenter;
    gameOverLabel.center = CGPointMake(self.center.x, 26);
    gameOverLabel.textColor = [UIColor whiteColor];
    [self addSubview:gameOverLabel];
    
    // Menu button
    UIImage *menuImage = [UIImage imageNamed:@"MenuButton"];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    menuButton.center = CGPointMake(self.bounds.size.width - menuImage.size.width/2 - 10, self.bounds.size.height - menuImage.size.height/2 - 10);
    [menuButton setImage:menuImage forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"MenuButtonClicked"] forState:UIControlStateSelected];
    [menuButton addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
    menuButton.opaque = YES;
    [self addSubview:menuButton];
}

- (void)setupMonkeyWon
{
    // Button for playing the level again
    UIImage *playAgainImage = [UIImage imageNamed:@"PlayAgainButton"];
    UIButton *playAgainMonkeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playAgainMonkeyButton.frame = CGRectMake(0, 0, playAgainImage.size.width, playAgainImage.size.height);
    playAgainMonkeyButton.center = self.center;
    [playAgainMonkeyButton setImage:playAgainImage forState:UIControlStateNormal];
    [playAgainMonkeyButton setImage:[UIImage imageNamed:@"PlayAgainButtonClicked"] forState:UIControlStateSelected];
    [playAgainMonkeyButton addTarget:self action:@selector(playAgainAction) forControlEvents:UIControlEventTouchUpInside];
    playAgainMonkeyButton.opaque = YES;
    [self addSubview:playAgainMonkeyButton];
    
    // Button to go to the next level
    UIImage *nextLevelImage = [UIImage imageNamed:@"NextLevelButton"];
    UIButton *nextLevelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextLevelButton.frame = CGRectMake(0, 0, nextLevelImage.size.width, nextLevelImage.size.height);
    nextLevelButton.center = CGPointMake(self.bounds.size.width - nextLevelImage.size.width/2, self.center.y);
    [nextLevelButton setImage:nextLevelImage forState:UIControlStateNormal];
    [nextLevelButton setImage:[UIImage imageNamed:@"PlayAgainClicked"] forState:UIControlStateSelected];
    [nextLevelButton addTarget:self action:@selector(nextLevelAction) forControlEvents:UIControlEventTouchUpInside];
    nextLevelButton.opaque = YES;
    [self addSubview:nextLevelButton];
    
    // Menu button
    UIImage *menuImage = [UIImage imageNamed:@"MenuButton"];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    menuButton.center = CGPointMake(self.bounds.size.width - menuImage.size.width/2 - 10, self.bounds.size.height - menuImage.size.height/2 - 10);
    [menuButton setImage:menuImage forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"MenuButtonClicked"] forState:UIControlStateSelected];
    [menuButton addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
    menuButton.opaque = YES;
    [self addSubview:menuButton];
    
    // Label showing final score
    UILabel *playerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    playerScoreLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You got ", (long)playerLevelRunData.totalPoints, @" points!"];
    playerScoreLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:36];
    playerScoreLabel.textAlignment = NSTextAlignmentCenter;
    playerScoreLabel.textColor = [UIColor whiteColor];
    [self addSubview:playerScoreLabel];
    
    // Label showing number of apples
    UILabel *numberOfApplesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, playerScoreLabel.center.y + 10, self.bounds.size.width, 40)];
    numberOfApplesLabel.text = [NSString stringWithFormat:@"%@%li%@%li", @"Apples: ", (long)playerLevelRunData.numberOfBonusObjectsObtained, @"/", (long)playerLevelRunData.numberOfBonusObjectsAvailable];
    numberOfApplesLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:30];
    numberOfApplesLabel.textAlignment = NSTextAlignmentCenter;
    numberOfApplesLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberOfApplesLabel];
    
    // Label showing number of dead monkeys
    UILabel *numberOfDeadMonkeysLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, numberOfApplesLabel.center.y + 5, self.bounds.size.width, 40)];
    numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li", @"Dead monkeys: ", (long)playerLevelRunData.numberOfTimesDied];
    numberOfDeadMonkeysLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:30];
    numberOfDeadMonkeysLabel.textAlignment = NSTextAlignmentCenter;
    numberOfDeadMonkeysLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberOfDeadMonkeysLabel];
    
    // Label showing number of rapid ropes
    UILabel *numberOfRapidRopesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, numberOfDeadMonkeysLabel.center.y + 5, self.bounds.size.width, 40)];
    numberOfRapidRopesLabel.text = [NSString stringWithFormat:@"%@%li", @"Rapid Ropes: ", (long)playerLevelRunData.numberOfRapidRopes];
    numberOfRapidRopesLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:30];
    numberOfRapidRopesLabel.textAlignment = NSTextAlignmentCenter;
    numberOfRapidRopesLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberOfRapidRopesLabel];
    
    // TOOD: Label comparing score to Game Center friends (just top friend? just nearest more points friend?)
    NSInteger competitorScore = [self getCompetitorScore];
    if (competitorScore != 0) {
        UILabel *competitorScoreLabel = [[UILabel alloc] init];
        competitorScoreLabel.text = [NSString stringWithFormat:@"%li", (long)competitorScore];
        competitorScoreLabel.center = CGPointMake(playerScoreLabel.center.x + playerScoreLabel.bounds.size.width + 10, playerScoreLabel.center.y);
        competitorScoreLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:14];
        competitorScoreLabel.textColor = [UIColor orangeColor];
        [self addSubview:competitorScoreLabel];
    }
    
    // Label indicating new high score
    if (playerLevelRunData.totalPoints > 0) {//playerLevelRunData.storedHighScore) {
        UILabel *newHighScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 120, 0, 180, 40)];
        newHighScoreLabel.text = @"New high score!";
        newHighScoreLabel.font = [UIFont fontWithName:@"Englebert-Regular" size:16];
        newHighScoreLabel.textAlignment = NSTextAlignmentLeft;
        newHighScoreLabel.textColor = [UIColor orangeColor];
        [self addSubview:newHighScoreLabel];
        
        // Save new high score to disk
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setObject:[NSNumber numberWithInteger:playerLevelRunData.totalPoints] forKey:[NSString stringWithFormat:@"%@%i", @"Level", playerLevelRunData.levelNumber]];
        [standardDefaults synchronize];
        
        // Push new high score to Game Center
        NSInteger score = playerLevelRunData.totalPoints;
        [GameKitHelper reportScore:score forIdentifier:[NSString stringWithFormat:@"%@%i", @"Level", playerLevelRunData.levelNumber]];
    }
}

#pragma mark - User selection actions

- (void)respawnAction
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:@"respawn" forKey:@"userSelection"];
    
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

- (void)menuAction
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