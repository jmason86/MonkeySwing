//
//  JPMRope.h
//  MonkeySwing
//
//  Created by James Paul Mason on 11/20/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface JPMRope : SKNode

@property int ropeLength;

-(void) setAttachmentPoint:(CGPoint)point toNode:(SKNode*)body;

@end