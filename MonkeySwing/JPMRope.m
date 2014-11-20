//
//  JPMRope.m
//  MonkeySwing
//
//  Created by James Paul Mason on 11/20/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "JPMRope.h"
#import "PhysicsParameters.h"

static const uint32_t ropeCategory = 0x1 << 1;

@implementation JPMRope
{
    NSMutableArray *_ropeParts;
    SKNode *_startNode;
    CGPoint _positionOnStartNode;
    PhysicsParameters *physicsParameters;
}

-(void) setAttachmentPoint:(CGPoint)point toNode:(SKNode *)node
{
    _positionOnStartNode = point;
    _startNode = node;
}


-(void) setRopeLength:(int)ropeLength
{
    if (_ropeParts) {
        [_ropeParts removeAllObjects];
        _ropeParts = nil;
    }
    
    _ropeParts = [NSMutableArray arrayWithCapacity:ropeLength];
    
    SKSpriteNode *firstPart = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
    firstPart.position = _positionOnStartNode;
    firstPart.zPosition = 110;
    firstPart.name = @"RopeSegment0";
    firstPart.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:firstPart.size.height];
    firstPart.physicsBody.allowsRotation = YES;
    
    [_ropeParts addObject:firstPart];
    [[self.scene childNodeWithName:@"myWorld"] addChild:firstPart];
    
    for (int i = 1; i < ropeLength; i++) {
        SKSpriteNode *ropePart = [SKSpriteNode spriteNodeWithImageNamed:@"Rope Segment"];
        ropePart.position = CGPointMake(firstPart.position.x, firstPart.position.y - (i * ropePart.size.height));
        ropePart.zPosition = 110;
        ropePart.name = [NSString stringWithFormat:@"%@%i", @"RopeSegment", i];
        ropePart.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ropePart.size.height];
        ropePart.physicsBody.allowsRotation = YES;
        
        [[self.scene childNodeWithName:@"myWorld"] addChild:ropePart];
        [_ropeParts addObject:ropePart];
    }
    
    [self ropePhysics];
}

-(int) ropeLength
{
    return (int)_ropeParts.count;
}

-(void) ropePhysics
{
    // Attach first node to start
    SKNode *nodeA = _startNode;
    SKSpriteNode *nodeB = [_ropeParts objectAtIndex:0];
    SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody
                                                           bodyB:nodeB.physicsBody
                                                          anchor:_positionOnStartNode];
    [self.scene.physicsWorld addJoint:joint];
    
    // Then add rest of the joints and physics parameters
    for (int i=1; i<_ropeParts.count; i++) {
        SKSpriteNode *nodeA = [_ropeParts objectAtIndex:i-1];
        SKSpriteNode *nodeB = [_ropeParts objectAtIndex:i];
        SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:nodeA.physicsBody
                                                               bodyB:nodeB.physicsBody
                                                              anchor:CGPointMake(CGRectGetMidX(nodeA.frame),
                                                                                 CGRectGetMinY(nodeA.frame))];
        [self.scene.physicsWorld addJoint:joint];
        
        //nodeB.physicsBody.density = physicsParameters.ropeDensity;
        nodeB.physicsBody.linearDamping = physicsParameters.ropeLinearDamping;
        nodeB.physicsBody.angularDamping = physicsParameters.ropeAngularDamping;
        nodeB.physicsBody.affectedByGravity = YES;
        /*nodeB.physicsBody.restitution = physicsParameters.ropeRestitution;
        nodeB.physicsBody.usesPreciseCollisionDetection = YES;
        nodeB.physicsBody.categoryBitMask = ropeCategory;
        nodeB.physicsBody.contactTestBitMask = ropeCategory;
        nodeB.physicsBody.collisionBitMask = 0x0;
         */
    }
}

@end