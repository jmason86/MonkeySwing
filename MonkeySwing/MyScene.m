//
//  MyScene.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MyScene.h"

static const CGFloat k_swipeToXVelocityConversion = 0.4;
static const CGFloat k_swipeToYVelocityConversion = 0.2;
static const uint32_t monkeyCategory =  0x1 << 0;
static const uint32_t ropeCategory =  0x1 << 1;

@implementation MyScene
{
    CGPoint farLeftSide, farRightSide, farTopSide, farBottomSide;
    CGFloat sceneWidth, sceneHeight;
    NSTimeInterval touchBeganTime;
    CGPoint touchBeganPoint;
    int treeDensity; // [trees/screen]
    int bushDensity; // [bushes/screen]
    NSTimer *fireTimer;
    NSString *monkeyOnRopeWithName;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        // Define useful constants
        [self defineUsefulConstants];
        
        // Add background images (sky and forest)
        treeDensity = 7; // [trees/screen]
        bushDensity = 15; // [bushes/screen]
        [self addBackground];
        
        // Add fire
        [self addFire];
        
        // Add ropes
        [self addRopes];
        
        // Add monkey
        [self addMonkey];
        
        // Setup physicsWorld
        self.physicsWorld.gravity = CGVectorMake(0, -1);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

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
            CGFloat xVelocity = k_swipeToXVelocityConversion * (touchEndPoint.x - touchBeganPoint.x) / (touchEndTime - touchBeganTime);
            CGFloat yVelocity = k_swipeToYVelocityConversion * (touchEndPoint.y - touchBeganPoint.y) / (touchEndTime - touchBeganTime);
            CGVector swipeVelocity = CGVectorMake(xVelocity, yVelocity);
            [self monkeySwingWithSwipeVelocity:swipeVelocity];
        }

    }
}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark - Initial setup of scene

- (void)addBackground
{
    // Add sky
    SKSpriteNode *skyBackground = [SKSpriteNode spriteNodeWithImageNamed:@"Sky"];
    skyBackground.name = @"skyBackground";
    [self addChild:skyBackground];
    
    // Add trees
    for (int i = 0; i < treeDensity; i++) {
        // Randomly select which tree image will be used
        int randomTreeIndex = (arc4random() % (5 - 1 + 1)) + 1;
        SKSpriteNode *treeNode = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"%@%i", @"Tree", randomTreeIndex]];
        treeNode.anchorPoint = CGPointMake(0.5, 0);
        treeNode.position = CGPointMake(farLeftSide.x + i/(treeDensity - 1.0) * sceneWidth, farBottomSide.y);
        treeNode.name = [NSString stringWithFormat:@"%@%i", @"tree", i];
        [self addChild:treeNode];
        
        // Randomly decide if new bush will go in front of or behind last tree
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
        bushNode.position = CGPointMake(farLeftSide.x + i/(bushDensity - 1.0) * sceneWidth, farBottomSide.y + bushNode.size.height * 0.4);
        [self addChild:bushNode];
        
        // Randomly decide if new bush will go in front of or behind last bush
        int randomIntegerBOOL = (arc4random() % (1 - 0 + 1));
        if (i > 0 && randomIntegerBOOL == 1) {
            bushNode.zPosition = 101;
        } else {
            bushNode.zPosition = 100;
        }
    }
}

- (void)addFire
{
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
    SKEmitterNode *fireEmitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    fireEmitterNode.position = CGPointMake(farLeftSide.x, farBottomSide.y);
    [self addChild:fireEmitterNode];
    fireEmitterNode.zPosition = 105;
    fireEmitterNode.position = CGPointMake(farLeftSide.x + sceneWidth/2, farBottomSide.y);
    fireEmitterNode.particlePositionRange = CGVectorMake(0, 0);
    fireTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fireUpdate:) userInfo:fireEmitterNode repeats:YES];
}

- (void)fireUpdate:(NSTimer *)timer
{
    SKEmitterNode *fireEmitterNode = [timer userInfo];
    
    // Initially expand fire from middle outward
    if (fireEmitterNode.particlePositionRange.dx < sceneWidth) {
        fireEmitterNode.particlePositionRange = CGVectorMake(fireEmitterNode.particlePositionRange.dx + 100 , 2);
        fireEmitterNode.particleBirthRate = fireEmitterNode.particleBirthRate + 80; // Hold the intensity roughly constant during expansion
    }
    
    // Make fire faster and higher
    [fireEmitterNode setParticleSpeed:fireEmitterNode.speed + 1];
    [fireEmitterNode setParticleLifetime:fireEmitterNode.particleLifetime + 1];
    if (fireEmitterNode.particleBirthRate < 3000) {
        fireEmitterNode.particleBirthRate = fireEmitterNode.particleBirthRate + 5;
    }
}

// Every tree that is taller than he sceneHeight gets a rope
- (void)addRopes
{
    int ropeNumber = 0;
    for (SKNode *node in self.children) {
        if ([node isKindOfClass:SKSpriteNode.class] && [node.name rangeOfString:@"tree"].location != NSNotFound) {
            SKSpriteNode *treeNode = (SKSpriteNode *)node;
            if (treeNode.size.height > sceneHeight) {
                
                // Make a full rope node to hold all the segments in a single object
                SKNode *fullRopeNode = [[SKNode alloc] init];
                fullRopeNode.name = [NSString stringWithFormat:@"%@%i", @"fullRope", ropeNumber];
                [self addChild:fullRopeNode];
                
                // Make a bunch of rope segments
                SKPhysicsBody *ropeSegment1PhysicsBody, *ropeSegment2PhysicsBody;
                for (int i = 0; i < 15; i = i + 2) {
                    // Add first segment image
                    SKSpriteNode *ropeSegment1 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
                    ropeSegment1.position = CGPointMake(treeNode.position.x, farTopSide.y - i * ropeSegment1.size.height * 0.9);
                    ropeSegment1.name = [NSString stringWithFormat:@"%@%i", @"rope", i];
                    [fullRopeNode addChild:ropeSegment1];
                    ropeSegment1.zPosition = 110;
                    
                    // Add first segment physics
                    ropeSegment1PhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeSegment1.size];
                    ropeSegment1.physicsBody = ropeSegment1PhysicsBody;
                    ropeSegment1.physicsBody.density = 3;
                    ropeSegment1.physicsBody.linearDamping = 0.8;
                    if (i == 0) {
                        ropeSegment1.physicsBody.dynamic = NO;
                    }
                    ropeSegment1.physicsBody.categoryBitMask = ropeCategory;
                    ropeSegment1.physicsBody.contactTestBitMask = monkeyCategory;
                    
                    // Add joint between new ropeSegment1 and previous ropeSegment2
                    if (i > 0) {
                        SKPhysicsBody *previousBottomRopeSegmentPhysicsBody = ropeSegment2PhysicsBody;
                        SKPhysicsJointSliding *jointPin = [SKPhysicsJointSliding jointWithBodyA:ropeSegment1.physicsBody bodyB:previousBottomRopeSegmentPhysicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y + ropeSegment1.size.height) axis:CGVectorMake(1, 0)];
                        jointPin.shouldEnableLimits = YES;
                        [self.physicsWorld addJoint:jointPin];
                    }
                    
                    // Add new ropeSegment
                    SKSpriteNode *ropeSegment2 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
                    ropeSegment2.position = CGPointMake(ropeSegment1.position.x, farTopSide.y - (i + 1) * ropeSegment2.size.height * 0.9);
                    ropeSegment2.name = [NSString stringWithFormat:@"%@%i", @"rope", i + 1];
                    [fullRopeNode addChild:ropeSegment2];
                    ropeSegment2.zPosition = 110;
                    
                    // Add physics to segments
                    ropeSegment2PhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeSegment2.size];
                    ropeSegment2.physicsBody = ropeSegment2PhysicsBody;
                    ropeSegment2.physicsBody.density = 3;
                    ropeSegment2.physicsBody.linearDamping = 0.8;
                    ropeSegment2.physicsBody.categoryBitMask = ropeCategory;
                    ropeSegment2.physicsBody.contactTestBitMask = monkeyCategory;
                    
                    // Add joints between segments
                    SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:ropeSegment1.physicsBody bodyB:ropeSegment2.physicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y - ropeSegment1.size.height)];
                    jointPin.upperAngleLimit = M_PI/4;
                    jointPin.lowerAngleLimit = -M_PI/4;
                    jointPin.shouldEnableLimits = YES;
                    [self.physicsWorld addJoint:jointPin];
                }
                ropeNumber++;
            }
        }
    }
}

- (void)addMonkey
{
    SKSpriteNode *monkeySpriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"Monkey"];
    monkeySpriteNode.position = CGPointMake(farLeftSide.x + 30, farTopSide.y - 50);
    monkeySpriteNode.zPosition = 104;
    monkeySpriteNode.name = @"monkey";
    [self addChild:monkeySpriteNode];
    
    // Baisic properties
    monkeySpriteNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monkeySpriteNode.size];
    monkeySpriteNode.physicsBody.mass = 10;
    monkeySpriteNode.physicsBody.velocity = CGVectorMake(100, 0);
    
    // Collision properties
    monkeySpriteNode.physicsBody.categoryBitMask = monkeyCategory;
    monkeySpriteNode.physicsBody.contactTestBitMask = ropeCategory;
    monkeySpriteNode.physicsBody.usesPreciseCollisionDetection = YES;
}

#pragma mark - Convenience methods

- (void)defineUsefulConstants
{
    farLeftSide = CGPointMake(-self.frame.size.width/2, 0);
    farRightSide = CGPointMake(self.frame.size.width/2, 0);
    farTopSide = CGPointMake(0, self.frame.size.height/2);
    farBottomSide = CGPointMake(0, -self.frame.size.height/2);
    sceneWidth = self.scene.frame.size.width;
    sceneHeight = self.scene.frame.size.height;
}

#pragma mark - Touch response methods

- (void)ropeSwingWithSwipeVelocity:(CGVector)swipeVelocity
{
    // Determine which rope segment to apply impulse to
    CGPoint rayStart = touchBeganPoint;
    CGPoint rayEnd = CGPointMake(farRightSide.x, touchBeganPoint.y);
    
    SKPhysicsBody *bodyAlongRay = [self.physicsWorld bodyAlongRayStart:rayStart end:rayEnd];
    if (bodyAlongRay && [bodyAlongRay.node.name rangeOfString:@"rope"].location != NSNotFound) {
        [bodyAlongRay applyImpulse:swipeVelocity];
    }
}

- (void)monkeySwingWithSwipeVelocity:(CGVector)swipeVelocity
{
    SKPhysicsBody *monkeyPhysicsBody = [self childNodeWithName:@"monkey"].physicsBody;
    if (monkeyPhysicsBody.joints.count != 0) {
        [monkeyPhysicsBody applyImpulse:swipeVelocity];
    }
}

- (void)monkeyReleaseRope
{
    // Make the rope and monkey contactless to allow monkey to move through
    for (SKNode *node in self.children) {
        if ([node.name isEqualToString:monkeyOnRopeWithName]) {
            for (SKNode *ropeSegmentNode in node.children) {
                [ropeSegmentNode.physicsBody setContactTestBitMask:0];
                [ropeSegmentNode.physicsBody setCollisionBitMask:0];
            }
        }
    }
    SKPhysicsBody *monkeyPhysicsBody = [self childNodeWithName:@"monkey"].physicsBody;
    monkeyPhysicsBody.collisionBitMask = 0;
    monkeyPhysicsBody.contactTestBitMask = 0;
    
    // Remove joint between monkey and rope
    for (SKPhysicsJoint *joint in monkeyPhysicsBody.joints) {
        [self.physicsWorld removeJoint:joint];
    }
    
    // Add a jumping impulse to the monkey
    [monkeyPhysicsBody applyImpulse:CGVectorMake(1000, 500)];
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
        [self monkey:secondBody didCollideWithRope:firstBody];
    }
}

- (void)monkey:(SKPhysicsBody *)monkeyPhysicsBody didCollideWithRope:(SKPhysicsBody *)ropePhysicsBody
{
    if (monkeyPhysicsBody.joints.count == 0) {
        // Create a new joint between the monkey and the rope segment
        SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:monkeyPhysicsBody bodyB:ropePhysicsBody anchor:ropePhysicsBody.node.position];
        jointPin.upperAngleLimit = M_PI/4;
        jointPin.shouldEnableLimits = YES;
        [self.physicsWorld addJoint:jointPin];
        
        // Flag the name of the fullRope that the monkey is currently on
        monkeyOnRopeWithName = ropePhysicsBody.node.parent.name;
    }

}

@end