//
//  Library.m
//  Library
//
//  Created by Damien DeVille on 3/12/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "Library.h"

#import <UIKit/UIKit.h>

@implementation Library

- (void)sayHello
{
	UIAlertView *alertView = [[UIAlertView alloc] init];
	[alertView setTitle:@"Oh Hai"];
	[alertView setMessage:@"This message was shown from a dynamic library!"];
	[alertView addButtonWithTitle:@"OK"];
	[alertView show];
}

@end
