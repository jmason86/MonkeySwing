//
//  MyScene.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MyScene.h"
#import "JPMButton.h"
#import "JPMLevelInterpreter.h"
#import "BonusPointsObject.h"
#import "LevelEndView.h"
#import "PlayerLevelRunData.h"

// Collision categories
static const uint32_t monkeyCategory = 0x1 << 0;
static const uint32_t ropeCategory = 0x1 << 1;
static const uint32_t bonusObjectCategory = 0x1 << 2;

@implementation MyScene
{
    // Locations
    CGPoint sceneFarLeftSide, sceneFarRightSide, sceneFarTopSide, sceneFarBottomSide, skyFarLeftSide, skyFarRightSide, skyFarTopSide, skyFarBottomSide;
    
    // Sizes
    CGFloat sceneWidth, sceneHeight, skyWidth, skyHeight;
    CGFloat hudFireWidth, hudFireHeight;
    
    // Times
    NSTimeInterval touchBeganTime;
    NSTimer *fireTimer;
    
    // Touches
    CGPoint touchBeganPoint;
    
    // Object identification
    NSString *monkeyOnRopeWithName;
    SKNode *myWorld, *allFireNode;
    NSInteger numberOfBonusPointsObtained;
    
    // HUD parameters
    SKCropNode *hudFireCropNode;
    int playerScore;
    
    // Player progress stats
    PlayerLevelRunData *playerLevelRunData;
}
@synthesize physicsParameters, levelNumber;

#pragma mark - View life cycle

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // DELETE: Set level number to 1 always for now
        levelNumber = 1;
        
        // Initialize the physics parameters
        physicsParameters = [[PhysicsParameters alloc] init];
        
        // Create world
        [self createNewWorld];
        
        // Setup physicsWorld
        self.physicsWorld.gravity = physicsParameters.gravity;
        self.physicsWorld.contactDelegate = self;
        
        // Add HUD
        [self addHUD];
        numberOfBonusPointsObtained = 0;
        
        // Prepare to collect stats on the players progress
        playerLevelRunData = [[PlayerLevelRunData alloc] init];
        
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
    self.anchorPoint = CGPointMake(0.5, 0.5);
    myWorld = [SKNode node];
    myWorld.scene.anchorPoint = CGPointMake(0.5, 0.5);
    myWorld.name = @"myWorld";
    [self addChild:myWorld];
    
    // Define useful constants
    [self defineUsefulConstants];
    
    // Add background images (sky and forest) to myWorld
    [self addBackgroundToWorld];
    
    // Add fire
    [self addFireToWorld];
    
    // Add ropes
    NSArray *levelData = [JPMLevelInterpreter loadLevelFileNumber:levelNumber];
    [self addRopesAndBonusesToWorldWithLevelData:levelData];
    
    // Add monkey
    [self addMonkeyToWorld];
    
    // Add banana goal
    [self addBananaGoalToWorld];
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
    SKLabelNode *scoreHudLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkboard SE"];
    scoreHudLabel.position = CGPointMake(sceneFarLeftSide.x + hudBanana.size.width + 10, sceneFarTopSide.y);
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
        // Show level end view
        CGPoint centerInView = [self convertPointToView:CGPointMake(sceneFarLeftSide.x + sceneWidth/2, 0)];
        LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) forOutcome:@"gameOver"];
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
}

- (void)didSimulatePhysics
{
    [self centerOnNode:[self childNodeWithName:@"//monkey"]];
    [self resetRopeCategoryMasksForAllRopes:NO];
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
    
    // Get rid of the dead monkey sprite
    [monkeyNode removeFromParent];
    
    // Increment number of times died
    playerLevelRunData.numberOfTimesDied++;
    
    // Show level end view
    CGPoint centerInView = [self convertPointToView:CGPointMake(sceneFarLeftSide.x + sceneWidth/2, 0)];
    LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) forOutcome:@"monkeyFell"];
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
    playerLevelRunData.numberOfApples = numberOfBonusPointsObtained;
    // TODO: Determine how many apples there are total
    // TODO: Create method for determining number of "rapid ropes"
    
    // Show level end view
    CGPoint centerInView = [self convertPointToView:CGPointMake(sceneFarLeftSide.x + sceneWidth/2, 0)];
    LevelEndView *levelEndView = [[LevelEndView alloc] initWithFrame:CGRectMake(0, 0, 300, 300) forOutcome:@"monkeyWon"]; // TODO: Modify this method to include a "withRunData:playerLevelRunData"
    levelEndView.center = centerInView;
    levelEndView.tag = 1;
    [self.view addSubview:levelEndView];
}

- (void)resetRopeCategoryMasksForAllRopes:(BOOL)resetAllRopes
{
    for (SKNode *node in [myWorld children]) {
        // Grab rope nodes
        if ([node.name rangeOfString:@"fullRope"].location != NSNotFound) {
            // Either reset all ropes (monkey died)
            if (resetAllRopes == YES) {
                for (SKNode *ropeSegmentNode in node.children) {
                    ropeSegmentNode.physicsBody.categoryBitMask = ropeCategory;
                }
            } else {
                // Or reset a single rope that the monkey just released once the monkey is past it
                // TODO: This isn't working very well, fix it
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
    SKSpriteNode *skyBackground = [SKSpriteNode spriteNodeWithImageNamed:@"FullLevel1"];
    skyBackground.anchorPoint = CGPointMake(0, 0);
    skyBackground.position = CGPointMake(skyBackground.frame.origin.x - sceneWidth/2, skyBackground.frame.origin.y - sceneHeight/2);
    skyBackground.name = @"skyBackground";
    [myWorld addChild:skyBackground];
    
    // Update global parameters with sky values
    skyWidth = skyBackground.size.width;
    skyHeight = skyBackground.size.height;
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

// Every tree that is taller than the sceneHeight gets a rope
- (void)addRopesAndBonusesToWorldWithLevelData:(NSArray *)levelData
{
    int ropeNumber = 0;
    for (NSDictionary *objectProperties in levelData) {
        // Handle ropes
        if ([[objectProperties objectForKey:@"objectType"] isEqualToString:@"rope.png"]) {
            // Cast object properties
            CGFloat xPosition =  skyFarLeftSide.x + [[objectProperties objectForKey:@"xCenterPosition"] floatValue];
            CGFloat yPosition =  skyFarTopSide.y - [[objectProperties objectForKey:@"yCenterPosition"] floatValue];
            NSInteger numberOfSegments = [[objectProperties objectForKey:@"property1"] integerValue];
            
            // Make a full rope node to hold all the segments in a single object
            SKNode *fullRopeNode = [[SKNode alloc] init];
            fullRopeNode.name = [NSString stringWithFormat:@"%@%i", @"fullRope", ropeNumber];
            [myWorld addChild:fullRopeNode];
            
            // Make a bunch of rope segments
            SKPhysicsBody *ropeSegment1PhysicsBody, *ropeSegment2PhysicsBody;
            for (int i = 0; i < numberOfSegments; i = i + 2) {
                // Add first segment image
                SKSpriteNode *ropeSegment1 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
                ropeSegment1.position = CGPointMake(xPosition, yPosition - i * ropeSegment1.size.height * 0.9);
                ropeSegment1.name = [NSString stringWithFormat:@"%@%i", @"rope", i];
                [fullRopeNode addChild:ropeSegment1];
                ropeSegment1.zPosition = 110;
                
                // Add first segment physics
                ropeSegment1PhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeSegment1.size];
                ropeSegment1.physicsBody = ropeSegment1PhysicsBody;
                ropeSegment1.physicsBody.density = physicsParameters.ropeDensity;
                ropeSegment1.physicsBody.linearDamping = physicsParameters.ropeLinearDamping;
                ropeSegment1.physicsBody.angularDamping = physicsParameters.ropeAngularDamping;
                ropeSegment1.physicsBody.restitution = physicsParameters.ropeRestitution;
                ropeSegment1.physicsBody.usesPreciseCollisionDetection = YES;
                ropeSegment1.physicsBody.categoryBitMask = ropeCategory;
                ropeSegment1.physicsBody.contactTestBitMask = monkeyCategory;
                if (i == 0) {
                    ropeSegment1.physicsBody.dynamic = NO;
                }
                
                // Add joint between new ropeSegment1 and previous ropeSegment2
                if (i > 0) {
                    SKPhysicsBody *previousBottomRopeSegmentPhysicsBody = ropeSegment2PhysicsBody;
                    SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:ropeSegment1.physicsBody bodyB:previousBottomRopeSegmentPhysicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y + ropeSegment1.size.height)];
                    jointPin.upperAngleLimit = physicsParameters.ropeRotationLimit;
                    jointPin.lowerAngleLimit = -physicsParameters.ropeRotationLimit;
                    jointPin.shouldEnableLimits = YES;
                    [self.physicsWorld addJoint:jointPin];
                }
                
                // Add new ropeSegment
                SKSpriteNode *ropeSegment2 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
                ropeSegment2.position = CGPointMake(ropeSegment1.position.x, yPosition - (i + 1) * ropeSegment2.size.height * 0.9);
                ropeSegment2.name = [NSString stringWithFormat:@"%@%i", @"rope", i + 1];
                [fullRopeNode addChild:ropeSegment2];
                ropeSegment2.zPosition = 110;
                
                // Add physics to segments
                ropeSegment2PhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeSegment2.size];
                ropeSegment2.physicsBody = ropeSegment2PhysicsBody;
                ropeSegment2.physicsBody.density = physicsParameters.ropeDensity;
                ropeSegment2.physicsBody.linearDamping = physicsParameters.ropeLinearDamping;
                ropeSegment2.physicsBody.angularDamping = physicsParameters.ropeAngularDamping;
                ropeSegment2.physicsBody.restitution = physicsParameters.ropeRestitution;
                ropeSegment2.physicsBody.usesPreciseCollisionDetection = YES;
                ropeSegment2.physicsBody.categoryBitMask = ropeCategory;
                ropeSegment2.physicsBody.contactTestBitMask = monkeyCategory;
                
                // Add joints between segments
                SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:ropeSegment1.physicsBody bodyB:ropeSegment2.physicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y - ropeSegment1.size.height)];
                jointPin.upperAngleLimit = physicsParameters.ropeRotationLimit;
                jointPin.lowerAngleLimit = -physicsParameters.ropeRotationLimit;
                jointPin.shouldEnableLimits = YES;
                [self.physicsWorld addJoint:jointPin];
            }
            ropeNumber++;

        } else if ([[objectProperties objectForKey:@"objectType"] isEqualToString:@"apple.png"]) { // Handle bonus point objects
            // Cast object properties
            CGFloat xPosition =  skyFarLeftSide.x + [[objectProperties objectForKey:@"xCenterPosition"] floatValue];
            CGFloat yPosition = skyFarTopSide.y - [[objectProperties objectForKey:@"yCenterPosition"] floatValue];
            NSInteger numberOfPoints = [[objectProperties objectForKey:@"property1"] integerValue];
            
            BonusPointsObject *bonusPointSpriteNode = [BonusPointsObject spriteNodeWithImageNamed:@"Apple"];
            bonusPointSpriteNode.position = CGPointMake(xPosition, yPosition);
            bonusPointSpriteNode.zPosition = 103;
            bonusPointSpriteNode.numberOfPoints = (int) numberOfPoints;
            bonusPointSpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bonusPointSpriteNode.size];
            [bonusPointSpriteNode.physicsBody setAffectedByGravity:NO];
            bonusPointSpriteNode.physicsBody.categoryBitMask = bonusObjectCategory;
            bonusPointSpriteNode.physicsBody.contactTestBitMask = monkeyCategory;
            [myWorld addChild:bonusPointSpriteNode];
        }
    }
}

- (void)addMonkeyToWorld
{
    SKSpriteNode *monkeySpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"Monkey"];
    monkeySpriteNode.position = CGPointMake(sceneFarLeftSide.x + 30, sceneFarTopSide.y - 50);
    monkeySpriteNode.zPosition = 104;
    monkeySpriteNode.name = @"monkey";
    [myWorld addChild:monkeySpriteNode];
    
    // Basic properties
    monkeySpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monkeySpriteNode.size];
    monkeySpriteNode.physicsBody.density = physicsParameters.monkeyDensity;
    monkeySpriteNode.physicsBody.restitution = physicsParameters.monkeyRestitution;
    monkeySpriteNode.physicsBody.linearDamping = physicsParameters.monkeyLinearDamping;
    monkeySpriteNode.physicsBody.angularDamping = physicsParameters.monkeyAngularDamping;
    monkeySpriteNode.physicsBody.velocity = physicsParameters.monkeyInitialVelocity;
    
    // Collision properties
    monkeySpriteNode.physicsBody.categoryBitMask = monkeyCategory;
    monkeySpriteNode.physicsBody.contactTestBitMask = ropeCategory;
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

- (void)restartAction
{
    // Remove the level end view
    for (UIView *subview in self.view.subviews) {
        if (subview.tag == 1) {
            [subview removeFromSuperview];
        }
    }
    
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
}

- (void)monkeyReleaseRope
{
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
            [self bonusObjectwasCollected:contact.bodyB.node];
        } else if ([contact.bodyB.node.name isEqualToString:@"monkey"]) {
            [self bonusObjectwasCollected:contact.bodyA.node];
        }
    }
}

- (void)monkey:(SKPhysicsBody *)monkeyPhysicsBody didCollideWithRope:(SKPhysicsBody *)ropePhysicsBody atPoint:(CGPoint)contactPoint
{
    if (monkeyPhysicsBody.joints.count == 0) {
        // Create a new joint between the monkey and the rope segment
        SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:monkeyPhysicsBody bodyB:ropePhysicsBody anchor:contactPoint];
        jointPin.upperAngleLimit = M_PI/4;
        jointPin.shouldEnableLimits = YES;
        [self.physicsWorld addJoint:jointPin];
        
        // Flag the name of the fullRope that the monkey is currently on
        monkeyOnRopeWithName = ropePhysicsBody.node.parent.name;
    }
}

- (void)bonusObjectwasCollected:(SKNode *)bonusObject
{
    // Cast to BonusPointsObject and add points to score
    BonusPointsObject *bonusPointsObject = (BonusPointsObject *)bonusObject;
    playerScore = playerScore + bonusPointsObject.numberOfPoints;
    
    numberOfBonusPointsObtained = numberOfBonusPointsObtained + bonusPointsObject.numberOfPoints;
    [self updateHUD];
    
    // TODO: Create animation for apple disappear
    [bonusPointsObject removeFromParent];
    
    // Show bonus value
    SKNode *scoreHudLabel = [self childNodeWithName:@"scoreHudLabel"];
    SKLabelNode *bonusPointsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkboard SE"];
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
        [self restartAction];
    }
}

@end