//
//  MyScene.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MyScene.h"
#import "JPMButton.h"

static const CGFloat k_swipeToXVelocityConversion = 0.8;
static const CGFloat k_swipeToYVelocityConversion = 0.4;
static const CGFloat k_fireRiseRate = 1;
static const uint32_t monkeyCategory =  0x1 << 0;
static const uint32_t ropeCategory =  0x1 << 1;
static const CGFloat ropeRotationLimit = M_PI/12;

@implementation MyScene
{
    CGPoint sceneFarLeftSide, sceneFarRightSide, sceneFarTopSide, sceneFarBottomSide, skyFarLeftSide, skyFarRightSide, skyFarTopSide, skyFarBottomSide;
    CGFloat sceneWidth, sceneHeight, skyWidth, skyHeight;
    NSTimeInterval touchBeganTime;
    CGPoint touchBeganPoint;
    int treeDensity; // [trees/screen]
    int bushDensity; // [bushes/screen]
    NSTimer *fireTimer;
    NSString *monkeyOnRopeWithName;
    SKNode *myWorld, *allFireNode;
}
@synthesize physicsParameters;

# pragma mark - View life cycle

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        // Initialize the physics parameters
        physicsParameters = [[PhysicsParameters alloc] init];
        
        // Create world
        [self createNewWorld];
        
        // Setup physicsWorld
        self.physicsWorld.gravity = CGVectorMake(0, -2);
        self.physicsWorld.contactDelegate = self;
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
    treeDensity = 20; // [trees/screen]
    bushDensity = 30; // [bushes/screen]
    [self addBackgroundToWorld];
    
    // Add fire
    [self addFireToWorld];
    
    // Add ropes
    [self addRopesToWorld];
    
    // Add monkey
    [self addMonkeyToWorld];
    
    // Add banana goal
    [self addBananaGoalToWorld];
}

- (void)update:(CFTimeInterval)currentTime
{
    
}

- (void)didSimulatePhysics
{
    [self centerOnNode:[self childNodeWithName:@"//monkey"]];
}

- (void)centerOnNode:(SKNode *)monkeyNode
{
    CGPoint monkeyPosition = monkeyNode.position;
    
    // Check if monkey died
    if (monkeyPosition.y < myWorld.frame.origin.y - sceneHeight/2) {
        [self monkeyDied:monkeyNode];
    }
    
    // Check if monkey won
    if (monkeyPosition.x > skyFarRightSide.x) {
        [self monkeyWon:monkeyNode];
    }
    
    // Move world
    if (monkeyPosition.y > 0 && monkeyPosition.x > 0 && monkeyPosition.x + sceneWidth < skyFarRightSide.x) {
        [myWorld setPosition:CGPointMake(-monkeyPosition.x, -monkeyPosition.y)]; // Scroll x and y
    } else if (monkeyPosition.y > 0 && monkeyPosition.x < 0) {
        [myWorld setPosition:CGPointMake(0, -monkeyPosition.y)]; // Scroll y only if monkey is too close to left edge
    } else if (monkeyPosition.y > 0 && monkeyPosition.x + sceneWidth > skyFarRightSide.x) {
        [myWorld setPosition:CGPointMake(-skyWidth + sceneWidth, -monkeyPosition.y)];
    }
}

- (void)monkeyDied:(SKNode *)monkeyNode
{
    // Get rid of the dead monkey sprite
    [monkeyNode removeFromParent];
    
    // Firey death scene
    //SKScene *deathScene = [SKScene sceneWithSize:CGSizeMake(self.size.width / 2, self.size.height/2)];
    
    // TODO: Replace this button with a whole new SKScene, but for now a button will suffice
    JPMButton *restartButton = [[JPMButton alloc] initWithImageNamedNormal:@"SadMonkey" selected:@"MonkeyClicked"];
    restartButton.name = @"SadMonkeyFace";
    restartButton.zPosition = 115;
    [restartButton setTouchUpInsideTarget:self action:@selector(restartAction)];
    [self addChild:restartButton];
    
    // Make a big fire behind the monkey!
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
    SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    fireEmitterNode.position = CGPointMake(0, sceneFarBottomSide.y);
    fireEmitterNode.zPosition = 114;
    fireEmitterNode.name = @"fireBehindMonkeyFace";
    [fireEmitterNode setParticleBirthRate:1600];
    [fireEmitterNode setParticleSpeed:250];
    [fireEmitterNode setParticlePositionRange:CGVectorMake(250, 0)];
    
    [self addChild:fireEmitterNode];
}

- (void)monkeyWon:(SKNode *)monkeyNode
{
    // Get rid of the happy monkey sprite
    [monkeyNode removeFromParent];
    
    // Celebration scene
    
    
    JPMButton *winButton = [[JPMButton alloc] initWithImageNamedNormal:@"WinScreen" selected:@"WinScreen"];
    winButton.name = @"HappyMonkeyFace";
    winButton.zPosition = 115;
    [winButton setTouchUpInsideTarget:self action:@selector(newLevelAction)];
    [self addChild:winButton];
}

#pragma mark - Initial setup of scene

- (void)addBackgroundToWorld
{
    // Add sky
    SKSpriteNode *skyBackground = [SKSpriteNode spriteNodeWithImageNamed:@"Sky"];
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
    
    // Add trees
    for (int i = 0; i < treeDensity; i++) {
        // Randomly select which tree image will be used
        int randomTreeIndex = (arc4random() % (5 - 1 + 1)) + 1;
        SKSpriteNode *treeNode = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%i", @"Tree", randomTreeIndex]];
        treeNode.anchorPoint = CGPointMake(0.5, 0);
        treeNode.position = CGPointMake(sceneFarLeftSide.x + i/(treeDensity - 1.0) * skyBackground.size.width, sceneFarBottomSide.y);
        treeNode.name = [NSString stringWithFormat:@"%@%i", @"tree", i];
        [myWorld addChild:treeNode];
        
        // Randomly decide if new tree will go in front of or behind last tree
        int randomIntegerBOOL = (arc4random() % (1 - 0 + 1));
        if (i > 0 && randomIntegerBOOL == 1) {
            treeNode.zPosition = 99;
        } else {
            treeNode.zPosition = 98;
        }
    }
    
    // Add bushes
    for (int i = 0; i < bushDensity; i++) {
        // Randomly select which bush image will be used
        int randomBushIndex = (arc4random() % (5 - 1 + 1)) + 1;
        SKSpriteNode *bushNode = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%i", @"Bush", randomBushIndex]];
        bushNode.position = CGPointMake(sceneFarLeftSide.x + i/(bushDensity - 1.0) * skyBackground.size.width, sceneFarBottomSide.y + bushNode.size.height * 0.4);
        [myWorld addChild:bushNode];
        
        // Randomly decide if new bush will go in front of or behind last bush
        int randomIntegerBOOL = (arc4random() % (1 - 0 + 1));
        if (i > 0 && randomIntegerBOOL == 1) {
            bushNode.zPosition = 101;
        } else {
            bushNode.zPosition = 100;
        }
    }
}

- (void)addFireToWorld
{
    allFireNode = [SKNode node];
    [myWorld addChild:allFireNode];
    fireTimer = [NSTimer scheduledTimerWithTimeInterval:physicsParameters.fireTimerRate target:self selector:@selector(fireUpdate:) userInfo:nil repeats:YES];
}

- (void)fireUpdate:(NSTimer *)timer
{
    // Obtain fire emitter node
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
    SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    [allFireNode addChild:fireEmitterNode];
    
    // Establish fire default parameters
    fireEmitterNode.zPosition = 105;
    [fireEmitterNode setParticlePositionRange:CGVectorMake(physicsParameters.fireNodeXSize, 0)];
    
    // Initially expand fire
    for (int i = 1; i <= [allFireNode.children count]; i++) {
        if (i < skyWidth / physicsParameters.fireNodeXSize) {
            fireEmitterNode.position = CGPointMake(sceneFarLeftSide.x + i * physicsParameters.fireNodeXSize / 2, sceneFarBottomSide.y);
            fireEmitterNode.name = [NSString stringWithFormat:@"%@%i", @"fire", i-1];
        }
    }
    
    // Make fire faster/higher
    for (SKEmitterNode *singleFireEmitterNode in allFireNode.children) {
        [singleFireEmitterNode setParticleSpeed:singleFireEmitterNode.particleSpeed + physicsParameters.fireRiseRate];
    }
}

// Every tree that is taller than he sceneHeight gets a rope
- (void)addRopesToWorld
{
    int ropeNumber = 0;
    for (SKNode *node in myWorld.children) {
        if ([node isKindOfClass:SKSpriteNode.class] && [node.name rangeOfString:@"tree"].location != NSNotFound) {
            SKSpriteNode *treeNode = (SKSpriteNode *)node;
            if (treeNode.size.height > sceneHeight) {
                
                // Make a full rope node to hold all the segments in a single object
                SKNode *fullRopeNode = [[SKNode alloc] init];
                fullRopeNode.name = [NSString stringWithFormat:@"%@%i", @"fullRope", ropeNumber];
                [myWorld addChild:fullRopeNode];
                
                // Make a bunch of rope segments
                SKPhysicsBody *ropeSegment1PhysicsBody, *ropeSegment2PhysicsBody;
                for (int i = 0; i < 15; i = i + 2) {
                    // Add first segment image
                    SKSpriteNode *ropeSegment1 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
                    ropeSegment1.position = CGPointMake(treeNode.position.x, sceneFarTopSide.y - i * ropeSegment1.size.height * 0.9);
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
                    if (i == 0) {
                        ropeSegment1.physicsBody.dynamic = NO;
                    }
                    ropeSegment1.physicsBody.categoryBitMask = ropeCategory;
                    ropeSegment1.physicsBody.contactTestBitMask = monkeyCategory;
                    
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
                    ropeSegment2.position = CGPointMake(ropeSegment1.position.x, sceneFarTopSide.y - (i + 1) * ropeSegment2.size.height * 0.9);
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
            }
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
    
    // Baisic properties
    monkeySpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monkeySpriteNode.size];
    monkeySpriteNode.physicsBody.mass = physicsParameters.monkeyMass;
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
    // Remove the sad monkey face
    SKNode *sadMonkeyFace = [self childNodeWithName:@"SadMonkeyFace"];
    [sadMonkeyFace removeFromParent];
    SKNode *fireBehindMonkeyFace = [self childNodeWithName:@"fireBehindMonkeyFace"];
    [fireBehindMonkeyFace removeFromParent];
    
    // Add a new monkey
    [self addMonkeyToWorld];
}

- (void)newLevelAction
{
    [self removeAllChildren];
    BOOL newLevel = [self initWithSize:CGSizeMake(self.size.width, self.size.height)];
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
                [ropeSegmentNode.physicsBody setContactTestBitMask:0];
                [ropeSegmentNode.physicsBody setCollisionBitMask:0];
            }
        }
    }
    SKPhysicsBody *monkeyPhysicsBody = [myWorld childNodeWithName:@"monkey"].physicsBody;
    monkeyPhysicsBody.collisionBitMask = 0;
    monkeyPhysicsBody.contactTestBitMask = 0;
    
    // Remove joint between monkey and rope
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

@end