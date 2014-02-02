//
//  MainMenuScene.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/2/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MainMenuScene.h"
#import "PhysicsParameters.h"
#import "JPMButton.h"
#import "MyScene.h"

@implementation MainMenuScene
{
    // Locations
    CGPoint sceneFarLeftSide, sceneFarRightSide, sceneFarTopSide, sceneFarBottomSide;
    
    // Sizes
    CGFloat sceneWidth, sceneHeight, skyWidth, skyHeight;
    
    PhysicsParameters *physicsParameters;
}

- (void)defineUsefulConstants
{
    // Scene dimensions
    sceneWidth = self.scene.size.width;
    sceneHeight = self.scene.size.height;
    sceneFarLeftSide = CGPointMake(-sceneWidth/2, 0);
    sceneFarRightSide = CGPointMake(sceneWidth/2, 0);
    sceneFarTopSide = CGPointMake(0, sceneHeight/2);
    sceneFarBottomSide = CGPointMake(0, -sceneHeight/2);
}

# pragma mark - View life cycle

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        // Setup scene
        self.anchorPoint = CGPointMake(0.5, 0.5);
        [self defineUsefulConstants];
        
        // Add static images
        [self addImages];
        
        // Add physics bodies
        physicsParameters = [[PhysicsParameters alloc] init];
        self.physicsWorld.gravity = physicsParameters.gravity;
        [self addPhysicsBodies];
        
        // Add buttons
        [self addButtons];
        
    }
    return self;
}

- (void)update:(NSTimeInterval)currentTime
{
    SKSpriteNode *monkeySpriteNode = (SKSpriteNode *)[self childNodeWithName:@"monkey"];
    if (monkeySpriteNode.position.x < -100) {
        [monkeySpriteNode.physicsBody applyImpulse:CGVectorMake(6000, -800)];
    }
}

- (void)addImages
{
    // Add sky
    SKSpriteNode *skyBackgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"MainScreenSky"];
    skyBackgroundNode.position = CGPointMake(0, 0);
    skyBackgroundNode.zPosition = 0;
    [self addChild:skyBackgroundNode];
    
    // Add banana
    SKSpriteNode *bananaNode = [SKSpriteNode spriteNodeWithImageNamed:@"MainScreenBanana"];
    bananaNode.position = CGPointMake(200, 100);
    bananaNode.zPosition = 5;
    [self addChild:bananaNode];
}

- (void)addPhysicsBodies
{
    // Monkey
    SKSpriteNode *monkeySpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"MainScreenMonkey"];
    monkeySpriteNode.position = CGPointMake(-60, 10);
    monkeySpriteNode.zPosition = 104;
    monkeySpriteNode.name = @"monkey";
    [self addChild:monkeySpriteNode];
    
    // Monkey basic properties
    monkeySpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monkeySpriteNode.size];
    monkeySpriteNode.physicsBody.density = physicsParameters.monkeyDensity;
    monkeySpriteNode.physicsBody.restitution = physicsParameters.monkeyRestitution;
    monkeySpriteNode.physicsBody.linearDamping = physicsParameters.monkeyLinearDamping;
    monkeySpriteNode.physicsBody.angularDamping = physicsParameters.monkeyAngularDamping;
    monkeySpriteNode.physicsBody.velocity = CGVectorMake(300, 0);
    
    // Rope
    [self addRope];
}

- (void)addRope
{
    SKNode *fullRopeNode = [[SKNode alloc] init];
    fullRopeNode.name = @"rope";
    [self addChild:fullRopeNode];
    SKPhysicsBody *ropeSegment1PhysicsBody, *ropeSegment2PhysicsBody;
    for (int i = 0; i < 15; i = i + 2) {
        // Add first segment image
        SKSpriteNode *ropeSegment1 = [SKSpriteNode spriteNodeWithImageNamed:@"MainScreenRopeSegment"];
        ropeSegment1.position = CGPointMake(0, sceneFarTopSide.y - i * ropeSegment1.size.height * 0.9);
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
        SKSpriteNode *ropeSegment2 = [SKSpriteNode spriteNodeWithImageNamed:@"MainScreenRopeSegment"];
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
        
        // Add joints between segments
        SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:ropeSegment1.physicsBody bodyB:ropeSegment2.physicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y - ropeSegment1.size.height)];
        jointPin.upperAngleLimit = physicsParameters.ropeRotationLimit;
        jointPin.lowerAngleLimit = -physicsParameters.ropeRotationLimit;
        jointPin.shouldEnableLimits = YES;
        [self.physicsWorld addJoint:jointPin];
        
        // Join monkey to middle rope segment
        if (i == 10) {
            SKSpriteNode *monkeySpriteNode = (SKSpriteNode *)[self childNodeWithName:@"monkey"];
            SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:ropeSegment1PhysicsBody bodyB:monkeySpriteNode.physicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y - ropeSegment1.size.height)];
            jointPin.upperAngleLimit = 0;
            jointPin.lowerAngleLimit = 0;
            jointPin.shouldEnableLimits = YES;
            [self.physicsWorld addJoint:jointPin];
        }

    }

}

- (void)addButtons
{
    JPMButton *startButton = [[JPMButton alloc] initWithImageNamedNormal:@"StartGame" selected:@"StartGameClicked"];
    startButton.name = @"startButton";
    startButton.position = CGPointMake(0, sceneFarBottomSide.y + startButton.size.height);
    startButton.zPosition = 10;
    [startButton setTouchUpInsideTarget:self action:@selector(startGameAction)];
    [self addChild:startButton];
}

- (void)startGameAction
{
    SKTransition *reveal = [SKTransition doorwayWithDuration:1.6];
    MyScene *gameplayScene = [[MyScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:gameplayScene transition:reveal];
}

@end
