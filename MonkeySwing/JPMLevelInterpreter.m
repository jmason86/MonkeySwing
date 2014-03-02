//
//  JPMLevelInterpreter.m
//  MonkeySwing
//
//  Created by James Paul Mason on 2/12/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "JPMLevelInterpreter.h"

@implementation JPMLevelInterpreter

+ (NSArray *)loadLevelFileNumber:(int)levelNumber
{
    // Allocate the output array
    NSMutableArray *levelData = [[NSMutableArray alloc] init];
    NSArray *cellDictionaryKeys = [NSArray arrayWithObjects:@"objectTypeID", @"objectNumber", @"xCenterPosition", @"yCenterPosition", @"property1", @"objectType", nil];
    
    // Load the file and separate the rows out
    NSString *filename = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%i", @"Level", levelNumber] ofType:@"csv"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filename usedEncoding:nil error:nil];
    NSArray *rows = [fileContents componentsSeparatedByString:@"\n"];
    
    // Loop through the rows to get the cells and create a dictionary to store the cells, add that dictionary to levelData
    for (int i = 0; i < rows.count; i++) {
        NSString *row = [rows objectAtIndex:i];
        NSArray *columns = [row componentsSeparatedByString:@","];
        
        // First row contains info on the bg, so just skip it and add data for the rest of the rows
        if ([columns count] > 5) {
            NSDictionary *cells = [NSDictionary dictionaryWithObjects:columns forKeys:cellDictionaryKeys];
            [levelData addObject:cells];
        }

    }
    return levelData;
}

@end