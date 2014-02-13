//
//  JPMLevelInterpreter.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/12/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "JPMLevelInterpreter.h"

@implementation JPMLevelInterpreter

- (NSArray *)loadLevelFileNumber:(NSInteger)levelNumber
{
    // Allocate the output array
    NSMutableArray *levelData = [[NSMutableArray alloc] init];
    NSArray *cellDictionaryKeys = [NSArray arrayWithObjects:@"imageName", @"xCenterPosition", @"yCenterPosition", @"property1", nil];
    
    // Load the file and separate the rows out
    NSString *filename = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%i", @"Level", (int)levelNumber] ofType:@"csv"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filename usedEncoding:nil error:nil];
    NSArray *rows = [fileContents componentsSeparatedByString:@"\r"];
    
    // Loop through the rows to get the cells and create a dictionary to store the cells, add that dictionary to levelData
    for (int i = 0; i < rows.count; i++) {
        NSString *row = [rows objectAtIndex:i];
        NSArray *columns = [row componentsSeparatedByString:@","];
        
        NSDictionary *cells = [NSDictionary dictionaryWithObjects:columns forKeys:cellDictionaryKeys];
        [levelData addObject:cells];
    }

    return levelData;
}

@end
