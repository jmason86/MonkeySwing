//
//  PhysicsParameters.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/24/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "PhysicsParameters.h"

@implementation PhysicsParameters

@synthesize gravity;
@synthesize ropeDensity, ropeRestitution, ropeLinearDamping, ropeAngularDamping, ropeRotationLimit;
@synthesize monkeyDensity, monkeyRestitution, monkeyLinearDamping, monkeyAngularDamping, monkeyInitialVelocity, monkeyJumpImpulse;
@synthesize leafMass, leafRestitution, leafLinearDamping, leafAngularDamping;
@synthesize fireRiseRate, fireNodeXSize, fireTimerRate;
@synthesize swipeToXVelocityConversion, swipeToYVelocityConversion;

- (id)init
{
    // World parameters
    gravity = CGVectorMake(0, -2.5); // SI, default = (0, -9.8), my default = (0, -3)
    
    // Rope parameters
    ropeDensity = 13.0;            // SI, default = 1.0
    ropeRestitution = 0.0;         // range = 0-1, default = 0.2
    ropeLinearDamping = 0.99;      // range = 0-1, default = 0.1
    ropeAngularDamping = 0.99;     // range = 0-1, default = 0.1
    ropeRotationLimit = M_PI/12;   // Rope allowed to swing +/- this value
    
    // Monkey parameters
    monkeyDensity = 1.0;          // SI, default = 1.0
    monkeyRestitution = 0.0;       // range = 0-1, default = 0.2
    monkeyLinearDamping = 0.1;     // range = 0-1, default = 0.1
    monkeyAngularDamping = 0.99;   // range = 0-1, default = 0.1
    monkeyInitialVelocity = CGVectorMake(300, 180); // default = (120, 0)
    monkeyJumpImpulse = CGVectorMake(20, 8);
    
    // Leaf parameters
    leafMass = 0.3;               // SI, default = 1.0
    leafRestitution = 0.8;        // range = 0-1, default = 0.2
    leafLinearDamping = 0.001;    // range = 0-1, default = 0.2
    leafAngularDamping = 0.01;    // range = 0-1, default = 0.2
    
    // Fire parameters
    fireRiseRate = 1.0;
    fireNodeXSize = 50.0;
    fireTimerRate = 0.75;
    
    // Touch parameters
    swipeToXVelocityConversion = 0.02;
    swipeToYVelocityConversion = 0.003;
    
    return self;
}

@end
