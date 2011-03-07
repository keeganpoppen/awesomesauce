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
@synthesize envLength;
@synthesize instPicker;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)envLengthChanged:(UISlider *)sender {
	[delegate changeEnvLength:[sender value]];
}

- (IBAction)returnToMain:(id)sender {
	[delegate closeMe];
}

- (IBAction)instPickerChanged:(UISegmentedControl *)sender {
	int newInst = [sender selectedSegmentIndex];
	[delegate changeInstrument:newInst];
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
