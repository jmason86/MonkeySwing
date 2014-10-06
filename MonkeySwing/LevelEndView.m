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
{
    UIVisualEffectView *blurEffectView;
    UIVisualEffectView *vibrancyEffectView;
}

@synthesize playerLevelRunData;

#pragma mark - Initialization methods

- (id)initWithFrame:(CGRect)frame forOutcome:(NSString *)outcome withRunData:(PlayerLevelRunData *)playerLevelRunDataInput
{
    self = [super initWithFrame:frame];
    if (self) {
        playerLevelRunData = playerLevelRunDataInput; // Only have to do this because need to use initWithFrame so can't call a normall setter method first
        
        // Blur background
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        [self addSubview:blurEffectView];
        
        // Text vibrancy effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [vibrancyEffectView setFrame:self.bounds];

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
    [self insertSubview:menuButton aboveSubview:respawnMonkeyButton];
    
    // Label showing how many monkeys you've killed
    UILabel *numberOfDeadMonkeysLabel = [[UILabel alloc] initWithFrame:CGRectMake(respawnMonkeyButton.center.x - 200, respawnMonkeyButton.center.y - respawnImage.size.height/2.0 - 40, 400, 40)];
    if (playerLevelRunData.numberOfTimesDied == 1) {
        numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You've killed ", (long)playerLevelRunData.numberOfTimesDied, @" monkey"];
    } else {
        numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You've killed ", (long)playerLevelRunData.numberOfTimesDied, @" monkeys"];
    }
    numberOfDeadMonkeysLabel.font = [UIFont fontWithName:@"Flux Architect" size:26];
    numberOfDeadMonkeysLabel.textAlignment = NSTextAlignmentCenter;
    //numberOfDeadMonkeysLabel.textColor = [UIColor whiteColor];
    //numberOfDeadMonkeysLabel.shadowColor = [UIColor blackColor];
    //numberOfDeadMonkeysLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:numberOfDeadMonkeysLabel];
    
    
    // Label pointing out how much the fire has progressed
    UILabel *fireProgressionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 200)];
    int fireProgression = roundf(playerLevelRunData.fireProgression * 100.);
    fireProgressionLabel.text = [NSString stringWithFormat:@"%@%i%@", @"Fire is ", fireProgression, @"% of the way to your banana!"];
    fireProgressionLabel.font = [UIFont fontWithName:@"Flux Architect" size:16];
    fireProgressionLabel.numberOfLines = 0; // Uses as many as needed
    fireProgressionLabel.textAlignment = NSTextAlignmentLeft;
    //fireProgressionLabel.textColor = [UIColor whiteColor];
    //fireProgressionLabel.shadowColor = [UIColor blackColor];
    //fireProgressionLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:fireProgressionLabel];
    
    // Add arrow between HUD and fire progression label
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    UIImage *hudFire = [UIImage imageNamed:@"HudFire"];
    arrowView.center = CGPointMake(hudFire.size.width * playerLevelRunData.fireProgression, hudFire.size.height * 2);
    [self insertSubview:arrowView aboveSubview:respawnMonkeyButton];
    
    // Add the vibrant text to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

- (void)setupGameOver
{
    // Prepare the correct image for the restart button
    UIImage *gameOverImage;
    UILabel *gameOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x, self.center.y, self.frame.size.width, 40)];
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
    [self insertSubview:gameOverButton atIndex:0];
    
    // Game over label
    gameOverLabel.font = [UIFont fontWithName:@"Flux Architect" size:23];
    gameOverLabel.textAlignment = NSTextAlignmentCenter;
    gameOverLabel.center = CGPointMake(self.center.x, 26);
    //gameOverLabel.textColor = [UIColor whiteColor];
    //gameOverLabel.shadowColor = [UIColor blackColor];
    gameOverLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:gameOverLabel];
    
    // Menu button
    UIImage *menuImage = [UIImage imageNamed:@"MenuButton"];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    menuButton.center = CGPointMake(self.bounds.size.width - menuImage.size.width/2 - 10, self.bounds.size.height - menuImage.size.height/2 - 10);
    [menuButton setImage:menuImage forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"MenuButtonClicked"] forState:UIControlStateSelected];
    [menuButton addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
    menuButton.opaque = YES;
    [self insertSubview:menuButton aboveSubview:gameOverButton];
    
    // Add the vibrant text to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

- (void)setupMonkeyWon
{
    // Level name
    NSString *levelName = [NSString stringWithFormat:@"%@%i", @"Level", playerLevelRunData.levelNumber];
    
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
    [self insertSubview:nextLevelButton aboveSubview:playAgainMonkeyButton];
    
    // Menu button
    UIImage *menuImage = [UIImage imageNamed:@"MenuButton"];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    menuButton.center = CGPointMake(self.bounds.size.width - menuImage.size.width/2 - 10, self.bounds.size.height - menuImage.size.height/2 - 10);
    [menuButton setImage:menuImage forState:UIControlStateNormal];
    [menuButton setImage:[UIImage imageNamed:@"MenuButtonClicked"] forState:UIControlStateSelected];
    [menuButton addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
    menuButton.opaque = YES;
    [self insertSubview:menuButton aboveSubview:playAgainMonkeyButton];
    
    // Label showing final score
    UILabel *playerScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    playerScoreLabel.text = [NSString stringWithFormat:@"%@%li%@", @"You got ", (long)playerLevelRunData.totalPoints, @" points!"];
    playerScoreLabel.font = [UIFont fontWithName:@"Flux Architect" size:36];
    playerScoreLabel.textAlignment = NSTextAlignmentCenter;
    //playerScoreLabel.textColor = [UIColor whiteColor];
    //playerScoreLabel.shadowColor = [UIColor blackColor];
    playerScoreLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:playerScoreLabel];
    
    // Label showing number of apples
    UILabel *numberOfApplesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, playerScoreLabel.center.y + 10, self.bounds.size.width, 40)];
    numberOfApplesLabel.text = [NSString stringWithFormat:@"%@%li%@%li", @"Apples: ", (long)playerLevelRunData.numberOfBonusObjectsObtained, @"/", (long)playerLevelRunData.numberOfBonusObjectsAvailable];
    numberOfApplesLabel.font = [UIFont fontWithName:@"Flux Architect" size:30];
    numberOfApplesLabel.textAlignment = NSTextAlignmentCenter;
    //numberOfApplesLabel.textColor = [UIColor whiteColor];
    //numberOfApplesLabel.shadowColor = [UIColor blackColor];
    numberOfApplesLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:numberOfApplesLabel];
    
    // Label showing number of dead monkeys
    UILabel *numberOfDeadMonkeysLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, numberOfApplesLabel.center.y + 5, self.bounds.size.width, 40)];
    numberOfDeadMonkeysLabel.text = [NSString stringWithFormat:@"%@%li", @"Dead monkeys: ", (long)playerLevelRunData.numberOfTimesDied];
    numberOfDeadMonkeysLabel.font = [UIFont fontWithName:@"Flux Architect" size:30];
    numberOfDeadMonkeysLabel.textAlignment = NSTextAlignmentCenter;
    //numberOfDeadMonkeysLabel.textColor = [UIColor whiteColor];
    //numberOfDeadMonkeysLabel.shadowColor = [UIColor blackColor];
    numberOfDeadMonkeysLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:numberOfDeadMonkeysLabel];
    
    // Label showing number of rapid ropes
    UILabel *numberOfRapidRopesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, numberOfDeadMonkeysLabel.center.y + 5, self.bounds.size.width, 40)];
    numberOfRapidRopesLabel.text = [NSString stringWithFormat:@"%@%li", @"Rapid Ropes: ", (long)playerLevelRunData.numberOfRapidRopes];
    numberOfRapidRopesLabel.font = [UIFont fontWithName:@"Flux Architect" size:30];
    numberOfRapidRopesLabel.textAlignment = NSTextAlignmentCenter;
    //numberOfRapidRopesLabel.textColor = [UIColor whiteColor];
    //numberOfRapidRopesLabel.shadowColor = [UIColor blackColor];
    numberOfRapidRopesLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
    [[vibrancyEffectView contentView] addSubview:numberOfRapidRopesLabel];
    
    // Label and image comparing score to Game Center friend
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(competitorDisplayNameAndScoreReceived) name:@"competitor_display_name_saved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(competitorPhotoReceived) name:@"competitor_photo_received" object:nil];
    
    [[GameKitHelper sharedGameKitHelper] getFriendsNextHigherScore:playerLevelRunData.totalPoints forLeaderboardIdentifier:levelName];
    
    // Label indicating new high score
    if (playerLevelRunData.totalPoints > 0) {//playerLevelRunData.storedHighScore) {
        UILabel *newHighScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 120, 0, 180, 40)];
        newHighScoreLabel.text = @"New high score!";
        newHighScoreLabel.font = [UIFont fontWithName:@"Flux Architect" size:16];
        newHighScoreLabel.textAlignment = NSTextAlignmentLeft;
        //newHighScoreLabel.textColor = [UIColor orangeColor];
        //newHighScoreLabel.shadowColor = [UIColor blackColor];
        newHighScoreLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
        [[vibrancyEffectView contentView] addSubview:newHighScoreLabel];
        
        // Save new high score to disk
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setObject:[NSNumber numberWithInteger:playerLevelRunData.totalPoints] forKey:levelName];
        [standardDefaults synchronize];
        
        // Push new high score to Game Center
        NSInteger score = playerLevelRunData.totalPoints;
        [GameKitHelper reportScore:score forIdentifier:levelName];
    }
    
    // Add the vibrant text to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

- (void)competitorDisplayNameAndScoreReceived
{
    // Pull the data from the player into this class
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    GameCenterFriendData *competitorScoreInfo = gameKitHelper.gameCenterFriendData;
    
    // Parse the data
    NSString *playerName = competitorScoreInfo.playerName;
    NSString *competitorScore = competitorScoreInfo.score.formattedValue;
    
    // Create labels and images with player data
    if (competitorScore != nil) {
        UILabel *competitorScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, self.frame.size.width, self.frame.size.height)];
        competitorScoreLabel.text = [NSString stringWithFormat:@"%@ beat you with %@!", playerName, competitorScore];
        competitorScoreLabel.font = [UIFont fontWithName:@"Flux Architect" size:14];
        //competitorScoreLabel.textColor = [UIColor orangeColor];
        //competitorScoreLabel.shadowColor = [UIColor blackColor];
        competitorScoreLabel.shadowOffset = CGSizeMake(-1.0, 0.0);
        [[vibrancyEffectView contentView] addSubview:competitorScoreLabel];
    }
    
    // Add the vibrant tetx to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

- (void)competitorPhotoReceived
{
    // Pull the data from the player into this class
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    GameCenterFriendData *competitorScoreInfo = gameKitHelper.gameCenterFriendData;

    UIImage *competitorPhotoImage = competitorScoreInfo.playerPhoto;
    [competitorPhotoImage drawInRect:CGRectMake(50, 50, 50, 50)];
    UIImageView *competitorPhotoImageView = [[UIImageView alloc] initWithImage:competitorPhotoImage];
    competitorPhotoImageView.center = CGPointMake(50, 50);
    [self addSubview:competitorPhotoImageView];
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

@end