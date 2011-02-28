//
//  SynthViewController.m
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "SynthViewController.h"


@implementation SynthViewController
@synthesize delegate;
@synthesize titleLabel;
@synthesize instPicker;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)returnToMain:(id)sender {
	[delegate closeMe];
}

- (IBAction)instPickerChanged:(UISegmentedControl *)sender {
	int newInst = [sender selectedSegmentIndex];
	[delegate changeInstrument:newInst];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
