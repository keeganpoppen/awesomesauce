//
//  SocialViewController.m
//  awesomesauce
//
//  Created by Ravi Parikh on 3/6/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "SocialViewController.h"


@implementation SocialViewController
@synthesize delegate;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)returnToMain:(id)sender {
	[delegate closeMe];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}


@end
