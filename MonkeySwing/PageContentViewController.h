//
//  PageContentViewController.h
//  MonkeySwing
//
//  Created by James Paul Mason on 7/15/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
