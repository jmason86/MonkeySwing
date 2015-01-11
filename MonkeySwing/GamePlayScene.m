//
//  MyScene.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "GamePlayScene.h"
#import "JPMButton.h"
#import "JPMLevelInterpreter.h"
#import "BonusPointsObject.h"
#import "LevelEndView.h"
#import "PlayerLevelRunData.h"
#import "JPMRope.h"

// Collision categories
static const uint32_t monkeyCategory = 0x1 << 0;
static const uint32_t ropeCategory = 0x1 << 1;
static const uint32_t bonusObjectCategory = 0x1 << 2; // << means bitshift. Each bit shift is a multiply by 2 (e.g., this line means 1 * 2 * 2)
static const uint32_t leafCategory = 0; // Means that these should not interact with anything

@interface GamePlayScene ()
    // Parallax background
    @property (nonatomic, strong) PBParallaxScrolling * parallaxBackground;
@end

@implementation GamePlayScene
{
    // Locations
    CGPoint sceneFarLeftSide, sceneFarRightSide, sceneFarTopSide, sceneFarBottomSide, skyFarLeftSide, skyFarRightSide, skyFarTopSide, skyFarBottomSide;
    
    // Sizes
    CGFloat sceneWidth, sceneHeight, skyWidth, skyHeight;
    CGFloat hudFireWidth, hudFireHeight;
    
    // Times
    NSTimeInterval touchBeganTime;
    NSTimer *fireTimer, *leafTimer, *upwardFireTimer;
    double timeOfRopeGrab;
    
    // Touches
    CGPoint touchBeganPoint;
    
    // Object identification
    SKSpriteNode *monkeySprite;
    NSArray *monkeyReachingFrames;
    NSArray *monkeySwingLeftFrames;
    NSArray *monkeySwingRightFrames;
    NSString *monkeyOnRopeWithName;
    SKNode *myWorld, *allFireNode;
    NSInteger numberOfBonusPointsObtained;
    NSInteger totalAvailableBonusPoints;
    NSInteger numberOfBonusObjectsAvailable;
    NSInteger numberOfBonusObjectsObtained;
    
    // HUD parameters
    SKCropNode *hudFireCropNode;
    int playerScore;
    
    // Player progress stats
    NSInteger storedHighScore;
    PlayerLevelRunData *playerLevelRunData;
    NSInteger numberOfRapidRopes;
}
@synthesize physicsParameters, levelNumber;

#pragma mark - View life cycle

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // TODO: Delete this - Set level number to 1 always for now. Should instead have levelNumber passed in.
        levelNumber = 1;
        
        // Get stored high score
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        storedHighScore = [standardDefaults integerForKey:[NSString stringWithFormat:@"%@%i", @"Level", levelNumber]];
        
        // Initialize the physics parameters
        physicsParameters = [[PhysicsParameters alloc] init];
        
        // Create world
        [self createNewWorld];
        
        // Listen to the LevelEndScene
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveLevelEndedUserSelection:)
                                                     name:@"levelEndedUserSelection"
                                                   object:nil];
    }
    return self;
}

- (void)createNewWorld
{
    // Prepare world
    myWorld = [SKNode node];
    myWorld.scene.anchorPoint = CGPointMake(0.5, 0.5);
    myWorld.name = @"myWorld";
    [self addChild:myWorld];
    
    // Define useful constants
    [self defineUsefulConstants];
    
    // Add background images (sky and forest) to myWorld
    [self addBackgroundToWorld];
    
    // Add parallax scrolling images
    if ([self childNodeWithName:@"monkey"].position.x > 0.0) { // TODO: Need to store previous position to determine direction of travel, and need to change this in the update method
        self.direction = kPBParallaxBackgroundDirectionRight;
    }
    NSArray *imageNames = @[@"LevelButton", @"MonkeyGearTail"];
    PBParallaxScrolling *parallax = [[PBParallaxScrolling alloc] initWithBackgrounds:imageNames size:self.view.bounds.size direction:_direction fastestSpeed:kPBParallaxBackgroundDefaultSpeed andSpeedDecrease:kPBParallaxBackgroundDefaultSpeedDifferential];
    self.parallaxBackground = parallax;
    [self insertChild:parallax atIndex:self.children.count];
    
    
    // Add fire
    [self addFireToWorld];
    
    // Add leaves
    [self addRandomLeaves];
    
    // Add random upward fire
    [self addRandomUpwardFire];
    
    // Add ropes
    NSArray *levelData = [JPMLevelInterpreter loadLevelFileNumber:levelNumber];
    [self addRopesAndBonusesToWorldWithLevelData:levelData];
    
    // Add monkey
    [self addMonkeyToWorld];
    
    // Add banana goal
    [self addBananaGoalToWorld];
    
    // Setup physicsWorld
    self.physicsWorld.gravity = physicsParameters.gravity;
    self.physicsWorld.contactDelegate = self;
    
    // Add HUD
    [self addHUD];
    numberOfBonusPointsObtained = 0;
    numberOfBonusObjectsObtained = 0;
    
    // Prepare to collect stats on the players progress
    playerLevelRunData = [[PlayerLevelRunData alloc] init];
}

- (void)addHUD
{
    // Add HUD banana
    SKSpriteNode *hudBanana = [SKSpriteNode spriteNodeWithImageNamed:@"HudBanana"];
    hudBanana.anchorPoint = CGPointMake(0, 1);
    hudBanana.position = CGPointMake(sceneFarLeftSide.x, sceneFarTopSide.y);
    hudBanana.zPosition = 120;
    [self addChild:hudBanana];
    
    // Add fire to banana
    SKSpriteNode *hudFire = [SKSpriteNode spriteNodeWithImageNamed:@"HudFire"];
    hudFire.anchorPoint = CGPointMake(0, 1);
    SKSpriteNode *hudFireMask = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(hudFire.size.width, hudFire.size.height)];
    hudFireCropNode = [SKCropNode node];
    [hudFireCropNode addChild:hudFire];
    [hudFireCropNode setMaskNode:hudFireMask];
    hudFireCropNode.position = CGPointMake(sceneFarLeftSide.x, sceneFarTopSide.y);
    hudFireCropNode.zPosition = 121;
    [self addChild:hudFireCropNode];
    
    // Add score
    playerScore = 0;
    SKLabelNode *scoreHudLabel = [SKLabelNode labelNodeWithFontNamed:@"Flux Architect"];
    scoreHudLabel.position = CGPointMake(sceneFarLeftSide.x + hudBanana.size.width + 20, sceneFarTopSide.y);
    scoreHudLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    scoreHudLabel.zPosition = 120;
    scoreHudLabel.fontColor = [SKColor whiteColor];
    scoreHudLabel.fontSize = 15;
    scoreHudLabel.text = @"0";
    scoreHudLabel.name = @"scoreHudLabel";
    [self addChild:scoreHudLabel];
}

- (void)updateHUD
{
    // Determine progress of fire
    CGFloat fractionFireProgress = physicsParameters.fireNodeXSize / skyWidth * [allFireNode.children count];
    
    // If fire got all the way, game over
    if (fractionFireProgress >= 1.0) {
        // Pause the game
        self.scene.view.paused = YES;
        
        // Configure PlayerLevelRunData
        playerLevelRunData.fireProgression = fractionFireProgress;
        
        // Show level end view
        CGPoint centerInView = [self convertPointToView:CGPointMake(sceneFarLeftSide.x + sceneWidth/2, 0)];
        LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height) forOutcome:@"gameOver" withRunData:playerLevelRunData];
        levelEndView.center = centerInView;
        levelEndView.tag = 1;
        [self.view addSubview:levelEndView];
    }
    
    // Update fire in HUD
    SKSpriteNode *hudFireMask = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(hudFireWidth * fractionFireProgress, hudFireHeight)];
    [hudFireCropNode setMaskNode:hudFireMask];
    
    // Update score
    SKLabelNode *scoreHudLabel = (SKLabelNode *)[self childNodeWithName:@"scoreHudLabel"];
    CGFloat monkeyFractionalPosition = (sceneWidth/2 + [self childNodeWithName:@"//monkey"].position.x) / skyWidth;
    if (round(monkeyFractionalPosition * 1000) > [scoreHudLabel.text integerValue] - numberOfBonusPointsObtained) {
        playerScore = playerScore + round(monkeyFractionalPosition * 1000);
    }
    scoreHudLabel.text = [NSString stringWithFormat:@"%i", playerScore];
}

- (void)update:(CFTimeInterval)currentTime
{
    [self updateHUD];
    [self.parallaxBackground update:currentTime];
    
}

- (void)didSimulatePhysics
{
    [self centerOnNode:[self childNodeWithName:@"//monkey"]];
    [self resetRopeCategoryMasksForAllRopes:NO];
    
    // Run monkey reaching animation if appropriate
    if (monkeyOnRopeWithName) { // TODO: 2014/11/9 This suddenly became a necessary if statement after I changed the xPosition and yPosition for ropes. Make sure it's getting assigned when appropriate
        if ([self childNodeWithName:@"//monkey"].position.x > [self childNodeWithName:monkeyOnRopeWithName].position.x) {
            [self animateMonkeyReaching];
        }
    }
}

- (void)centerOnNode:(SKNode *)monkeyNode
{
    CGPoint monkeyPosition = monkeyNode.position;
    
    // Check if monkey died
    if (monkeyPosition.y < myWorld.frame.origin.y - sceneHeight/2) {
        [self monkeyDied];
    }
    
    // Check if monkey won
    if (monkeyPosition.x > skyFarRightSide.x) {
        [self monkeyWon:monkeyNode];
    }
    
    // Define limits
    CGFloat scrollTopLimit = skyFarTopSide.y - sceneHeight/2;
    CGFloat scrollBottomLimit = 0;
    CGFloat scrollLeftLimit = 0;
    CGFloat scrollRightLimit = skyFarRightSide.x - sceneWidth/2;
    
    // Normal (no limits hit) scrolling
    if (monkeyPosition.x > scrollLeftLimit && monkeyPosition.x < scrollRightLimit && monkeyPosition.y > scrollBottomLimit && monkeyPosition.y < scrollTopLimit) {
        [myWorld setPosition:CGPointMake(-monkeyPosition.x, -monkeyPosition.y)];
    }
    
    // At far left scrolling
    if (monkeyPosition.x < scrollLeftLimit) {
        // No y limits hit
        if (monkeyPosition.y > scrollBottomLimit && monkeyPosition.y < scrollTopLimit) {
            [myWorld setPosition:CGPointMake(0, -monkeyPosition.y)];
        }
        
        // Bottom limit hit
        if (monkeyPosition.y < scrollBottomLimit) {
            [myWorld setPosition:CGPointMake(0, 0)];
        }
        
        // Top limit hit
        if (monkeyPosition.y > scrollTopLimit) {
            [myWorld setPosition:CGPointMake(0, -scrollTopLimit)];
        }
    }
    
    // At far right scrolling
    if (monkeyPosition.x > scrollRightLimit) {
        // No y limits hit
        if (monkeyPosition.y > scrollBottomLimit && monkeyPosition.y < scrollTopLimit) {
            [myWorld setPosition:CGPointMake(-scrollRightLimit, -monkeyPosition.y)];
        }
        
        // Bottom limit hit
        if (monkeyPosition.y < scrollBottomLimit) {
            [myWorld setPosition:CGPointMake(-scrollRightLimit, 0)];
        }
        
        // Top limit hit
        if (monkeyPosition.y > scrollTopLimit) {
            [myWorld setPosition:CGPointMake(-scrollRightLimit, -scrollTopLimit)];
        }
    }
    
    // At far bottom scrolling
    if (monkeyPosition.y < scrollBottomLimit) {
        // No x limits hit
        if (monkeyPosition.x > scrollLeftLimit && monkeyPosition.x < scrollRightLimit) {
            [myWorld setPosition:CGPointMake(-monkeyPosition.x, 0)];
        }
        
        // Left limit hit
        if (monkeyPosition.x < scrollLeftLimit) {
            [myWorld setPosition:CGPointMake(0, 0)];
        }
        
        // Right limit hit
        if (monkeyPosition.x > scrollRightLimit) {
            [myWorld setPosition:CGPointMake(-scrollRightLimit, 0)];
        }
    }
    
    // At far top scrolling
    if (monkeyPosition.y > scrollTopLimit) {
        // No x limits hit
        if (monkeyPosition.x > scrollLeftLimit && monkeyPosition.x < scrollRightLimit) {
            [myWorld setPosition:CGPointMake(-monkeyPosition.x, -scrollTopLimit)];
        }
        
        // Left limit hit
        if (monkeyPosition.x < scrollLeftLimit) {
            [myWorld setPosition:CGPointMake(0, -scrollTopLimit)];
        }
        
        // Right limit hit
        if (monkeyPosition.x > scrollRightLimit) {
            [myWorld setPosition:CGPointMake(-scrollRightLimit, -scrollTopLimit)];
        }
    }
}

- (void)monkeyDied
{
    // Grab monkey node
    SKNode *monkeyNode = [self childNodeWithName:@"//monkey"];
    
    // Pause the progression of fire
    [fireTimer invalidate];
    
    // Reset rapid ropes count
    numberOfRapidRopes = 0;
    
    // Get rid of the dead monkey sprite
    [monkeyNode removeFromParent];
    
    // Increment number of times died and fire progression
    playerLevelRunData.numberOfTimesDied++;
    playerLevelRunData.fireProgression = physicsParameters.fireNodeXSize / skyWidth * [allFireNode.children count];
    
    // Show level end view
    CGPoint centerInView = [self convertPointToView:CGPointMake(sceneFarLeftSide.x + sceneWidth/2, 0)];
    LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height) forOutcome:@"monkeyFell" withRunData:playerLevelRunData];
    //LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height) forOutcome:@"monkeyWon" withRunData:playerLevelRunData]; // Just for debugging purposes
    levelEndView.center = centerInView;
    levelEndView.tag = 1;
    [self.view addSubview:levelEndView];
    
    // Reset all the ropes so that they can be grabbed again
    [self resetRopeCategoryMasksForAllRopes:YES];
}

- (void)monkeyWon:(SKNode *)monkeyNode
{
    // Get rid of the happy monkey sprite
    [monkeyNode removeFromParent];
    
    // Update playerLevelRunData
    playerLevelRunData.levelNumber = levelNumber;
    playerLevelRunData.totalPoints = playerScore;
    playerLevelRunData.numberOfBonusPointsObtained = numberOfBonusPointsObtained;
    playerLevelRunData.totalAvailableBonusPoints = totalAvailableBonusPoints;
    playerLevelRunData.numberOfBonusObjectsObtained = numberOfBonusObjectsObtained;
    playerLevelRunData.numberOfBonusObjectsAvailable = numberOfBonusObjectsAvailable;
    playerLevelRunData.numberOfRapidRopes = numberOfRapidRopes;
    playerLevelRunData.storedHighScore = storedHighScore;
    
    // Show level end view
    CGPoint centerInView = [self convertPointToView:CGPointMake(sceneFarLeftSide.x + sceneWidth/2, 0)];
    LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height) forOutcome:@"monkeyWon" withRunData:playerLevelRunData];
    levelEndView.center = centerInView;
    levelEndView.tag = 1;
    [self.view addSubview:levelEndView];
}

- (void)resetRopeCategoryMasksForAllRopes:(BOOL)resetAllRopes
{
    for (SKNode *node in [myWorld children]) {
        // Grab rope nodes
        if (monkeyOnRopeWithName && [node.name isEqualToString:monkeyOnRopeWithName]) {
            
            // Either reset all ropes (monkey died)
            if (resetAllRopes == YES) {
                for (SKNode *ropeSegmentNode in node.children) {
                    ropeSegmentNode.physicsBody.categoryBitMask = ropeCategory;
                }
            } else {
                
                // Or reset a single rope that the monkey just released once the monkey is past it
                SKSpriteNode *monkey = (SKSpriteNode *)[myWorld childNodeWithName:@"monkey"];
                CGFloat largestRopeXPosition = skyFarLeftSide.x;
                for (SKNode *ropeSegmentNode in node.children) {
                    if (ropeSegmentNode.position.x > largestRopeXPosition) {
                        largestRopeXPosition = ropeSegmentNode.position.x;
                    }
                }
                if (monkey.position.x > largestRopeXPosition) {
                    for (SKNode *ropeSegmentNode in node.children) {
                        ropeSegmentNode.physicsBody.categoryBitMask = ropeCategory;
                    }
                }
            }
        }
    }
}

#pragma mark - Initial setup of scene

- (void)addBackgroundToWorld
{
    // Add sky
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"FullLevel1"];
    background.anchorPoint = CGPointMake(0, 0);
    background.position = CGPointMake(background.frame.origin.x - sceneWidth/2, background.frame.origin.y - sceneHeight/2);
    background.name = @"skyBackground";
    [myWorld addChild:background];
    
    // Add parallax
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-1000);
    horizontalMotionEffect.maximumRelativeValue = @(1000);
    [background.scene.view addMotionEffect:horizontalMotionEffect];
    
    // Update global parameters with sky values
    skyWidth = background.size.width;
    skyHeight = background.size.height;
    skyFarLeftSide = CGPointMake(sceneFarLeftSide.x, 0);
    skyFarRightSide = CGPointMake(sceneFarLeftSide.x + skyWidth, 0);
    skyFarTopSide = CGPointMake(0, sceneFarBottomSide.y + skyHeight);
    skyFarBottomSide = CGPointMake(0, sceneFarBottomSide.y);
}

- (void)addFireToWorld
{
    // Add first flame
    allFireNode = [SKNode node];
    
    // Obtain fire emitter node
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
    SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    // Establish fire default parameters
    fireEmitterNode.zPosition = 105;
    [fireEmitterNode setParticlePositionRange:CGVectorMake(physicsParameters.fireNodeXSize, 0)];
    fireEmitterNode.position = CGPointMake(sceneFarLeftSide.x, sceneFarBottomSide.y);
    fireEmitterNode.name = @"fire0";
    [allFireNode addChild:fireEmitterNode];

    [myWorld addChild:allFireNode];
    
    // Update fire periodically
    fireTimer = 0; // Destroy timer if just came from a level restart or different level
    fireTimer = [NSTimer scheduledTimerWithTimeInterval:physicsParameters.fireTimerRate target:self selector:@selector(fireUpdate:) userInfo:nil repeats:YES];
}

- (void)fireUpdate:(NSTimer *)timer
{
    // Create fire emitter node
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
    SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    // Expand fire
    BOOL willAddNewFlame = NO;
    NSUInteger numberOfFires = [allFireNode.children count];
    if (numberOfFires < skyWidth / physicsParameters.fireNodeXSize) {
        // Establish fire default parameters
        fireEmitterNode.zPosition = 105;
        [fireEmitterNode setParticlePositionRange:CGVectorMake(physicsParameters.fireNodeXSize, 0)];
        
        fireEmitterNode.position = CGPointMake(sceneFarLeftSide.x + numberOfFires * physicsParameters.fireNodeXSize, sceneFarBottomSide.y);
        fireEmitterNode.name = [NSString stringWithFormat:@"%@%lu", @"fire", (unsigned long)numberOfFires];
        
        willAddNewFlame = YES;
    }
    if (willAddNewFlame) {
        [allFireNode addChild:fireEmitterNode];
    }
    
    // Make all of the existent fire faster/higher
    for (SKEmitterNode *singleFireEmitterNode in allFireNode.children) {
        [singleFireEmitterNode setParticleSpeed:singleFireEmitterNode.particleSpeed + physicsParameters.fireRiseRate];
    }
}

- (void)addRandomUpwardFire
{
    upwardFireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(upwardFireTimer) userInfo:nil repeats:YES];
}

- (void)upwardFireTimer
{
    // Randomly decide whether to do an upward fire node
    float randomFireNumber = arc4random() % 10;
    if (randomFireNumber > 1) {
        // Determine a random position offset
        float randomPositionOffset = arc4random() % 150;
        float randomFireNodeChoice = arc4random() % 10;
        if (randomFireNodeChoice > 5) {
            randomPositionOffset = -randomPositionOffset;
        }
        // Create fire emitter node
        NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
        SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
        fireEmitterNode.zPosition = 112;
        [fireEmitterNode setParticlePositionRange:CGVectorMake(10, 10)];
        [fireEmitterNode setParticleSize:CGSizeMake(35, 35)];
        [fireEmitterNode setParticleSpeedRange:50];
        fireEmitterNode.position = CGPointMake([self childNodeWithName:@"monkey"].position.x + randomPositionOffset, sceneFarBottomSide.y);
        
        // Add physics parameters to fire node
        fireEmitterNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(50, 50)];
        fireEmitterNode.physicsBody.mass = 0;
        fireEmitterNode.physicsBody.restitution = physicsParameters.leafRestitution;
        fireEmitterNode.physicsBody.linearDamping = physicsParameters.leafLinearDamping;
        fireEmitterNode.physicsBody.angularDamping = physicsParameters.leafAngularDamping;
        fireEmitterNode.physicsBody.categoryBitMask = leafCategory;
        fireEmitterNode.physicsBody.contactTestBitMask = leafCategory;
        fireEmitterNode.physicsBody.collisionBitMask = leafCategory;
        [fireEmitterNode.physicsBody applyImpulse:CGVectorMake(0, 10000)]; // TODO: Figure out why these bits of fire aren't moving up.
        fireEmitterNode.physicsBody.affectedByGravity = NO;
        
        
        [myWorld addChild:fireEmitterNode];
    }
}

- (void)addRandomLeaves
{
    // Setup a timer to add leaves
    leafTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(leafTimer) userInfo:nil repeats:YES];
}

- (void)leafTimer
{
    // Randomly pick which kind of leaf
    float randomLeafNumber = arc4random() % 10;
    NSString *leafNumber = [[NSString alloc] init];
    if (randomLeafNumber > 5) {
        leafNumber = @"1";
    } else {
        leafNumber = @"2";
    }
    
    // Create and add leaf
    SKSpriteNode *leafNode = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%@", @"Leaf", leafNumber]];
    leafNode.position = CGPointMake([self childNodeWithName:@"//monkey"].position.x + randomLeafNumber * 3, sceneFarTopSide.y);
    leafNode.name = @"Leaf";
    leafNode.zPosition = 111;
    [myWorld addChild:leafNode];
    
    // Decide if the leaf will have a fire node attached
    float randomFireNodeChoice = arc4random() % 10;
    if (randomFireNodeChoice > 7) {
        // Create fire emitter node
        NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
        SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
        fireEmitterNode.zPosition = 112;
        [fireEmitterNode setParticlePositionRange:CGVectorMake(10, 10)];
        [fireEmitterNode setParticleSize:CGSizeMake(35, 35)];
        [fireEmitterNode setParticleSpeedRange:50];
        fireEmitterNode.position = CGPointMake(0, 0);
        [leafNode addChild:fireEmitterNode];
    }
    
    // Create random wind vector
    float randomWindX = arc4random() % 10;
    float randomWindXDirection = arc4random() % 10;
    if (randomWindXDirection > 5) {
        randomWindX = -randomWindX;
    }
    float randomLeafFallImpulse = (arc4random() % 10) + 15;
    
    // Create random wind angular impulse
    float randomWindAngular = arc4random() % 4;
    float randomWindTorqueDirection = arc4random() % 10;
    if (randomWindTorqueDirection > 5) {
        randomWindAngular = -randomWindAngular;
    }
    
    // Give physics properties to leaf
    leafNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leafNode.size];
    leafNode.physicsBody.mass = physicsParameters.leafMass;
    leafNode.physicsBody.restitution = physicsParameters.leafRestitution;
    leafNode.physicsBody.linearDamping = physicsParameters.leafLinearDamping;
    leafNode.physicsBody.angularDamping = physicsParameters.leafAngularDamping;
    leafNode.physicsBody.categoryBitMask = leafCategory;
    leafNode.physicsBody.contactTestBitMask = leafCategory;
    leafNode.physicsBody.collisionBitMask = leafCategory;
    [leafNode.physicsBody applyImpulse:CGVectorMake(randomWindX, -randomLeafFallImpulse)];
    [leafNode.physicsBody applyAngularImpulse:randomWindAngular];
    leafNode.physicsBody.affectedByGravity = NO;
}

- (void)addRopesAndBonusesToWorldWithLevelData:(NSArray *)levelData
{
    // Initialize parameters
    int ropeNumber = 0;
    numberOfBonusObjectsAvailable = 0;
    totalAvailableBonusPoints = 0;
    numberOfRapidRopes = 0;
    
    for (NSDictionary *objectProperties in levelData) {
        // Handle ropes
        if ([[objectProperties objectForKey:@"objectType"] isEqualToString:@"rope.png"]) {
            // Cast object properties
            CGFloat yPosition = skyFarTopSide.y - [[objectProperties objectForKey:@"yCenterPosition"] floatValue];
            CGFloat xPosition = [[objectProperties objectForKey:@"xCenterPosition"] floatValue];
            CGPoint ropeAttachPosition = CGPointMake(xPosition, yPosition);
            NSInteger numberOfSegments = [[objectProperties objectForKey:@"property1"] integerValue];
            
            // Make a hidden anchor
            SKSpriteNode *anchor = [SKSpriteNode spriteNodeWithImageNamed:@"dummypixel_transparent.png"];
            anchor.position = ropeAttachPosition;
            anchor.size = CGSizeMake(1, 1);
            anchor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:anchor.size];
            anchor.physicsBody.affectedByGravity = false;
            anchor.physicsBody.mass = 99999999999;
            anchor.name = [NSString stringWithFormat:@"%@%i", @"ropeAnchor", ropeNumber];
            [myWorld addChild:anchor];
            
            // Make a full rope node to hold all the segments in a single object
            NSString *fullRopeName = [NSString stringWithFormat:@"%@%i", @"fullRope", ropeNumber];
            
            JPMRope *rope = [JPMRope new];
            [myWorld addChild:rope];
            
            // Attach rope to anchor
            [rope setAttachmentPoint:ropeAttachPosition toNode:anchor];
            
            // Set length of rope
            rope.ropeLength = (int)numberOfSegments;
            
            // Set name of rope
            rope.name = fullRopeName;
            
            // Update rope number for names
            ropeNumber++;

        } else if ([[objectProperties objectForKey:@"objectType"] isEqualToString:@"apple.png"]) { // Handle bonus point objects
            // Cast object properties
            CGFloat xPosition =  skyFarLeftSide.x + [[objectProperties objectForKey:@"xCenterPosition"] floatValue];
            CGFloat yPosition = skyFarTopSide.y - [[objectProperties objectForKey:@"yCenterPosition"] floatValue];
            NSInteger numberOfPoints = [[objectProperties objectForKey:@"property1"] integerValue];
            
            // Create and place the apple
            BonusPointsObject *bonusPointSpriteNode = [BonusPointsObject spriteNodeWithImageNamed:@"Apple"];
            bonusPointSpriteNode.position = CGPointMake(xPosition, yPosition);
            bonusPointSpriteNode.zPosition = 103;
            bonusPointSpriteNode.numberOfPoints = (int) numberOfPoints;
            bonusPointSpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bonusPointSpriteNode.size];
            [bonusPointSpriteNode.physicsBody setAffectedByGravity:NO];
            bonusPointSpriteNode.physicsBody.categoryBitMask = bonusObjectCategory;
            bonusPointSpriteNode.physicsBody.contactTestBitMask = monkeyCategory;
            [myWorld addChild:bonusPointSpriteNode];
            
            // Update bonus point instance variables
            numberOfBonusObjectsAvailable++;
            totalAvailableBonusPoints += numberOfPoints;
        }
    }
}

- (void)addMonkeyToWorld
{
    SKSpriteNode *monkeySpriteNode; // = [SKSpriteNode spriteNodeWithImageNamed:@"Monkey"];
    
    // Prep for an animated monkey - reaching
    NSMutableArray *monkeyReachingFramesTemp = [NSMutableArray array];
    SKTextureAtlas *monkeyReachingTextureAtlas = [SKTextureAtlas atlasNamed:@"MonkeyReaching"];
    NSUInteger numberOfMonkeyReachingImages = monkeyReachingTextureAtlas.textureNames.count;
    for (int i = 1; i <= numberOfMonkeyReachingImages/2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"MonkeyReaching%d", i];
        SKTexture *temp = [monkeyReachingTextureAtlas textureNamed:textureName];
        [monkeyReachingFramesTemp addObject:temp];
    }
    monkeyReachingFrames = monkeyReachingFramesTemp;
    SKTexture *temp = monkeyReachingFrames[0];
    monkeySpriteNode = [SKSpriteNode spriteNodeWithTexture:temp];
    monkeySpriteNode.position = CGPointMake(sceneFarLeftSide.x + 30, sceneFarTopSide.y - 50);
    monkeySpriteNode.zPosition = 104;
    monkeySpriteNode.name = @"monkey";
    [myWorld addChild:monkeySpriteNode];
    
    // Prep for an animated monkey - swing right
    NSMutableArray *monkeySwingRightFramesTemp = [NSMutableArray array];
    SKTextureAtlas *monkeySwingRightTextureAtlas = [SKTextureAtlas atlasNamed:@"MonkeySwingForward"];
    NSUInteger numberOfMonkeySwingRightImages = monkeySwingRightTextureAtlas.textureNames.count;
    for (int i = 1; i < numberOfMonkeySwingRightImages/2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"MonkeySwingForward%d", i];
        SKTexture *temp = [monkeySwingRightTextureAtlas textureNamed:textureName];
        [monkeySwingRightFramesTemp addObject:temp];
    }
    monkeySwingRightFrames = monkeySwingRightFramesTemp;
    
    // Basic properties
    monkeySpriteNode.anchorPoint = CGPointMake(0.5, 0.5);
    monkeySpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monkeySpriteNode.size center:CGPointMake(0, 0)];
    monkeySpriteNode.physicsBody.density = physicsParameters.monkeyDensity;
    monkeySpriteNode.physicsBody.restitution = physicsParameters.monkeyRestitution;
    monkeySpriteNode.physicsBody.linearDamping = physicsParameters.monkeyLinearDamping;
    monkeySpriteNode.physicsBody.angularDamping = physicsParameters.monkeyAngularDamping;
    monkeySpriteNode.physicsBody.velocity = physicsParameters.monkeyInitialVelocity;
    
    // Collision properties
    monkeySpriteNode.physicsBody.categoryBitMask = monkeyCategory;
    monkeySpriteNode.physicsBody.contactTestBitMask = ropeCategory;
    monkeySpriteNode.physicsBody.collisionBitMask = 0x0;
    monkeySpriteNode.physicsBody.usesPreciseCollisionDetection = YES;
}

- (void)addBananaGoalToWorld
{
    SKSpriteNode *bananaGoalSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"Banana"];
    bananaGoalSpriteNode.position = CGPointMake(skyFarRightSide.x, 0);
    bananaGoalSpriteNode.zPosition = 113;
    bananaGoalSpriteNode.name = @"banana";
    [myWorld addChild:bananaGoalSpriteNode];
}

- (void)respawnAction
{
    // Remove the level end view
    for (UIView *subview in self.view.subviews) {
        if (subview.tag == 1) {
            [subview removeFromSuperview];
        }
    }
    
    // Unpause the game
    self.scene.view.paused = NO;
    
    // Add a new monkey
    [self addMonkeyToWorld];
    
    // Start the fire progression again
    fireTimer = [NSTimer scheduledTimerWithTimeInterval:physicsParameters.fireTimerRate target:self selector:@selector(fireUpdate:) userInfo:nil repeats:YES];
}

- (void)newLevelAction
{
    [self removeAllChildren];
    BOOL newLevel = (BOOL) [self initWithSize:CGSizeMake(self.size.width, self.size.height)]; // TODO: Casting to BOOL can't be the best practice, what is?
    if (newLevel) {
        // Unpause the game
        self.scene.view.paused = NO;
    }
}

#pragma mark - Convenience methods

- (void)defineUsefulConstants
{
    // Scene dimensions
    sceneWidth = self.scene.frame.size.width;
    sceneHeight = self.scene.frame.size.height;
    sceneFarLeftSide = CGPointMake(-sceneWidth/2, 0);
    sceneFarRightSide = CGPointMake(sceneWidth/2, 0);
    sceneFarTopSide = CGPointMake(0, sceneHeight/2);
    sceneFarBottomSide = CGPointMake(0, -sceneHeight/2);
    
    // HUD fire width
    SKSpriteNode *hudFireSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"HudFire"];
    hudFireWidth = 2 * hudFireSpriteNode.size.width;
    hudFireHeight = 2 * hudFireSpriteNode.size.height;
}

-(CGPoint)convertSceneToFrameCoordinates:(CGPoint)scenePoint
{
    return CGPointMake(scenePoint.x + self.frame.size.width/2, scenePoint.y + self.frame.size.height/2);
}


#pragma mark - Touch response methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        touchBeganTime = touch.timestamp;
        touchBeganPoint = [touch locationInNode:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchEndPoint = [touch locationInNode:self];
        
        if (fabsf(touchEndPoint.x - touchBeganPoint.x) < 100 && fabsf(touchEndPoint.y - touchBeganPoint.y) < 100) {
            [self monkeyReleaseRope];
        } else {
            NSTimeInterval touchEndTime = touch.timestamp;
            CGFloat xVelocity = physicsParameters.swipeToXVelocityConversion * (touchEndPoint.x - touchBeganPoint.x) / (touchEndTime - touchBeganTime);
            CGFloat yVelocity = physicsParameters.swipeToYVelocityConversion * (touchEndPoint.y - touchBeganPoint.y) / (touchEndTime - touchBeganTime);
            CGVector swipeVelocity = CGVectorMake(xVelocity, yVelocity);
            [self monkeySwingWithSwipeVelocity:swipeVelocity];
        }
    }
}

- (void)monkeySwingWithSwipeVelocity:(CGVector)swipeVelocity
{
    SKPhysicsBody *monkeyPhysicsBody = [myWorld childNodeWithName:@"monkey"].physicsBody;
    if (monkeyPhysicsBody.joints.count != 0) {
        [monkeyPhysicsBody applyImpulse:swipeVelocity];
    }
    
    // Animate the monkey
    if (swipeVelocity.dx < 0) {
        [self animateMonkeySwingLeft];
    } else if (swipeVelocity.dx > 0) {
        [self animateMonkeySwingRight];
    }
}

- (void)monkeyReleaseRope
{
    // Check if this was a rapid rope
    double currentTime = CACurrentMediaTime(); // [seconds]
    if (currentTime - timeOfRopeGrab < 2.0) {
        numberOfRapidRopes++;
    }
    
    // Make the rope and monkey contactless to allow monkey to move through
    for (SKNode *node in myWorld.children) {
        if ([node.name isEqualToString:monkeyOnRopeWithName]) {
            for (SKNode *ropeSegmentNode in node.children) {
                [ropeSegmentNode.physicsBody setCategoryBitMask:monkeyCategory];
            }
        }
    }
    
    // Remove joint between monkey and rope
    SKPhysicsBody *monkeyPhysicsBody = [myWorld childNodeWithName:@"monkey"].physicsBody;
    for (SKPhysicsJoint *joint in monkeyPhysicsBody.joints) {
        [self.physicsWorld removeJoint:joint];
    }
    
    // Add a jumping impulse to the monkey
    [monkeyPhysicsBody applyImpulse:physicsParameters.monkeyJumpImpulse];
}

- (void)animateMonkeyReaching
{
    [[self childNodeWithName:@"//monkey"] runAction:[SKAction animateWithTextures:monkeyReachingFrames timePerFrame:0.1f resize:NO restore:YES] withKey:@"monkeyReaching"];
    return;
}

- (void)animateMonkeySwingLeft
{
    [[self childNodeWithName:@"//monkey"] runAction:[SKAction animateWithTextures:monkeySwingLeftFrames timePerFrame:0.1f resize:NO restore:YES] withKey:@"monkeySwingLeft"];
    return;
}

- (void)animateMonkeySwingRight
{
    // DEBUG: Loop monkey swinging infinitely
    SKSpriteNode *monkey = [self childNodeWithName:@"//monkey"];
    [[self childNodeWithName:@"//monkey"] runAction:[SKAction repeatActionForever:
                                                     [SKAction animateWithTextures:monkeySwingRightFrames
                                                                      timePerFrame:0.1f
                                                                            resize:NO
                                                                           restore:YES]]
                                            withKey:@"monkeySwingRight"];
    //[[self childNodeWithName:@"//monkey"] runAction:[SKAction animateWithTextures:monkeySwingRightFrames timePerFrame:0.1f resize:NO restore:YES] withKey:@"monkeySwingRight"];
    return;
}

#pragma mark - Collision response methods

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // Sort which bodies are which
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // Verify that the two bodies were the monkey and rope, then handle collision
    if ((firstBody.categoryBitMask & ropeCategory) != 0 && (secondBody.categoryBitMask & monkeyCategory) != 0)
    {
        [self monkey:secondBody didCollideWithRope:firstBody atPoint:contact.contactPoint];
    }
    
    if (contact.bodyA.categoryBitMask == bonusObjectCategory || contact.bodyB.categoryBitMask == bonusObjectCategory) {
        if ([contact.bodyA.node.name isEqualToString:@"monkey"]) {
            [self bonusObjectWasCollected:contact.bodyB.node];
        } else if ([contact.bodyB.node.name isEqualToString:@"monkey"]) {
            [self bonusObjectWasCollected:contact.bodyA.node];
        }
    }
}

- (void)monkey:(SKPhysicsBody *)monkeyPhysicsBody didCollideWithRope:(SKPhysicsBody *)ropePhysicsBody atPoint:(CGPoint)contactPoint
{
    if (monkeyPhysicsBody.joints.count == 0) {
        // Create a new joint between the monkey and the rope segment
        CGPoint convertedRopePosition = [self convertSceneToFrameCoordinates:ropePhysicsBody.node.position];
        SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:monkeyPhysicsBody bodyB:ropePhysicsBody anchor:convertedRopePosition]; // FIXME: Monkey-rope joint going to weird position
        jointPin.upperAngleLimit = M_PI/4;
        jointPin.shouldEnableLimits = YES;
        [self.scene.physicsWorld addJoint:jointPin];
        
        /*
        // DEBUG: Draw a rectangle in a coordinate system
        SKSpriteNode *bla = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(100, 100)];
        [self.scene addChild:bla]; // If I use bla.scene, it doesn't work. self, self.scene, myworld all do work though.
        bla.position = convertedRopePosition;
        bla.zPosition = 999;
        */
        
        // Flag the name of the fullRope that the monkey is currently on
        monkeyOnRopeWithName = ropePhysicsBody.node.parent.name;
        
        // Start timer for determination of rapid ropes
        timeOfRopeGrab = CACurrentMediaTime(); // [seconds]
    }
}

- (void)bonusObjectWasCollected:(SKNode *)bonusObject
{
    // Cast to BonusPointsObject and add points to score
    BonusPointsObject *bonusPointsObject = (BonusPointsObject *)bonusObject;
    playerScore = playerScore + bonusPointsObject.numberOfPoints;
    
    numberOfBonusPointsObtained = numberOfBonusPointsObtained + bonusPointsObject.numberOfPoints;
    numberOfBonusObjectsObtained++;
    [self updateHUD];
    
    // TODO: Create animation for apple disappear
    [bonusPointsObject removeFromParent];
    
    // Show bonus value
    SKNode *scoreHudLabel = [self childNodeWithName:@"scoreHudLabel"];
    SKLabelNode *bonusPointsLabel = [SKLabelNode labelNodeWithFontNamed:@"Flux Architect"];
    bonusPointsLabel.text = [NSString stringWithFormat:@"%@%i", @"+", bonusPointsObject.numberOfPoints];
    bonusPointsLabel.position = CGPointMake(scoreHudLabel.position.x + scoreHudLabel.frame.size.width + 10.0, scoreHudLabel.position.y);
    bonusPointsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    bonusPointsLabel.zPosition = 120;
    bonusPointsLabel.fontColor = [SKColor whiteColor];
    bonusPointsLabel.fontSize = 15;
    bonusPointsLabel.xScale = 0.5;
    [self addChild:bonusPointsLabel];
    
    // Create animation for adding bonus score
    SKAction *enlargeAction = [SKAction scaleXTo:1.4 y:1.0 duration:0.3];
    SKAction *backToNormalScale = [SKAction scaleXTo:1.0 y:1.0 duration:0.3];
    SKAction *reduceAction = [SKAction scaleXTo:1.0 y:0.1 duration:0.3];
    SKAction *moveToFullScore = [SKAction moveTo:CGPointMake(scoreHudLabel.position.x, scoreHudLabel.position.y - scoreHudLabel.frame.size.height/2) duration:0.3];
    moveToFullScore.timingMode = SKActionTimingEaseInEaseOut;
    SKAction *movingGroup = [SKAction group:[NSArray arrayWithObjects:reduceAction, moveToFullScore, nil]];
    SKAction *removeFromParent = [SKAction removeFromParent];
    [bonusPointsLabel runAction:[SKAction sequence:[NSArray arrayWithObjects:enlargeAction, backToNormalScale, movingGroup, removeFromParent, nil]]];
}

#pragma mark - Notification center response methods

- (void)receiveLevelEndedUserSelection:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"levelEndedUserSelection"]) {
        NSString *userSelection = [notification.userInfo objectForKey:@"userSelection"];
        
        if ([userSelection isEqualToString:@"respawn"]) {
            [self respawnAction];
        }
        if ([userSelection isEqualToString:@"restartLevel"]) {
            // Unpause
            self.scene.view.paused = NO;
            // Remove the level end view
            for (UIView *subview in self.view.subviews) {
                if (subview.tag == 1) {
                    [subview removeFromSuperview];
                }
            }
            
            // Remake the level
            [self removeAllChildren];
            [self createNewWorld];
        }
    }
}

@end