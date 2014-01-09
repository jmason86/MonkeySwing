//
//  MyScene.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "MyScene.h"

static const CGFloat k_swipeToXVelocityConversion = 0.02;
static const CGFloat k_swipeToYVelocityConversion = 0.01;

@implementation MyScene
{
    CGPoint farLeftSide, farRightSide, farTopSide, farBottomSide;
    CGFloat sceneWidth, sceneHeight;
    NSTimeInterval touchBeganTime;
    CGPoint touchBeganPoint;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        // Define useful constants
        [self defineUsefulConstants];
        
        // Add background images (sky and forest)
        [self addBackground];
        
        // Add fire
        [self addFire];
        
        // Add ropes
        [self addRopes];
        
        // Add monkey
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        //[self ropeSwing];
        touchBeganTime = touch.timestamp;
        touchBeganPoint = [touch locationInNode:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        NSTimeInterval touchEndTime = touch.timestamp;
        CGPoint touchEndPoint = [touch locationInNode:self];
        CGFloat xVelocity = k_swipeToXVelocityConversion * (touchEndPoint.x - touchBeganPoint.x) / (touchEndTime - touchBeganTime);
        CGFloat yVelocity = k_swipeToYVelocityConversion * (touchEndPoint.y - touchBeganPoint.y) / (touchEndTime - touchBeganTime);
        CGVector swipeVelocity = CGVectorMake(xVelocity, yVelocity);
        [self ropeSwingWithSwipeVelocity:swipeVelocity];
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
    
    // Add a few trees
    SKSpriteNode *tree1 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeStandard"];
    tree1.position = CGPointMake(farLeftSide.x + sceneWidth/11, 0);
    [self addChild:tree1];
    
    SKSpriteNode *tree2 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeStandard"];
    tree2.position = CGPointMake(farLeftSide.x + sceneWidth/5, 0);
    [self addChild:tree2];

    SKSpriteNode *tree3 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeMedium3"];
    tree3.position = CGPointMake(farLeftSide.x + sceneWidth/3, 20);
    [self addChild:tree3];
    
    SKSpriteNode *tree4 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeSmall"];
    tree4.position = CGPointMake(farLeftSide.x + sceneWidth/2, -15);
    [self addChild:tree4];
    
    SKSpriteNode *tree5 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeMedium2"];
    tree5.position = CGPointMake(farRightSide.x - sceneWidth/3, 0);
    [self addChild:tree5];

    SKSpriteNode *tree6 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeMedium1"];
    tree6.position = CGPointMake(farRightSide.x - sceneWidth/3.5, 30);
    [self addChild:tree6];
    
    SKSpriteNode *tree7 = [SKSpriteNode spriteNodeWithImageNamed:@"TreeBig"];
    tree7.position = CGPointMake(farRightSide.x - 5, 50);
    [self addChild:tree7];
}

- (void)addFire
{
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"ParticleFire" ofType:@"sks"];
    SKEmitterNode *fireNode = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    fireNode.position = CGPointMake(farLeftSide.x, farBottomSide.y);
    [self addChild:fireNode];
}

- (void)addRopes
{
    SKPhysicsBody *ropeSegment1PhysicsBody, *ropeSegment2PhysicsBody;
    for (int i = 0; i < 15; i = i + 2) {
        // Add first segment image
        SKSpriteNode *ropeSegment1 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
        ropeSegment1.position = CGPointMake(farLeftSide.x + sceneWidth/2, farTopSide.y - i * ropeSegment1.size.height * 0.9);
        ropeSegment1.name = [NSString stringWithFormat:@"%@%i", @"rope", i];
        [self addChild:ropeSegment1];
        
        // Add first segment physics
        ropeSegment1PhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeSegment1.size];
        ropeSegment1.physicsBody = ropeSegment1PhysicsBody;
        ropeSegment1.physicsBody.density = 3;
        ropeSegment1.physicsBody.linearDamping = 0.8;
        if (i == 0) {
            ropeSegment1.physicsBody.dynamic = NO;
        }
        
        // Add joint between new ropeSegment1 and previous ropeSegment2
        if (i > 0) {
            SKPhysicsBody *previousBottomRopeSegmentPhysicsBody = ropeSegment2PhysicsBody;
            SKPhysicsJointSliding *jointPin = [SKPhysicsJointSliding jointWithBodyA:ropeSegment1PhysicsBody bodyB:previousBottomRopeSegmentPhysicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y + ropeSegment1.size.height) axis:CGVectorMake(1, 0)];
            jointPin.shouldEnableLimits = YES;
            [self.physicsWorld addJoint:jointPin];
        }
        
        // Add new ropeSegment
        SKSpriteNode *ropeSegment2 = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
        ropeSegment2.position = CGPointMake(farLeftSide.x + sceneWidth/2, farTopSide.y - (i + 1) * ropeSegment2.size.height * 0.9);
        ropeSegment2.name = [NSString stringWithFormat:@"%@%i", @"rope", i + 1];
        [self addChild:ropeSegment2];
        
        // Add physics to segments
        ropeSegment2PhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ropeSegment2.size];
        ropeSegment2.physicsBody = ropeSegment2PhysicsBody;
        ropeSegment2.physicsBody.density = 3;
        ropeSegment2.physicsBody.linearDamping = 0.8;
        
        // Add joints between segments
        SKPhysicsJointPin *jointPin = [SKPhysicsJointPin jointWithBodyA:ropeSegment1PhysicsBody bodyB:ropeSegment2PhysicsBody anchor:CGPointMake(ropeSegment1.position.x, ropeSegment1.position.y - ropeSegment1.size.height)];
        jointPin.upperAngleLimit = M_PI/4;
        jointPin.lowerAngleLimit = -M_PI/4;
        jointPin.shouldEnableLimits = YES;
        [self.physicsWorld addJoint:jointPin];
    }
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
    SKNode *ropeSegment = [self childNodeWithName:@"rope9"];
    [ropeSegment.physicsBody applyImpulse:swipeVelocity];
}

@end