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
@synthesize envAttack;
@synthesize envRelease;
@synthesize osc1Picker;
@synthesize osc2Picker;
@synthesize osc3Picker;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)envLengthChanged:(UISlider *)sender {
	[delegate changeEnvLength:[sender value]];
}

- (IBAction)envAttackChanged:(UISlider *)sender {
	[delegate changeEnvAttack:[sender value]];
}

- (IBAction)envReleaseChanged:(UISlider *)sender {
	[delegate changeEnvRelease:[sender value]];
}

- (IBAction)returnToMain:(id)sender {
	[delegate closeMe];
}

- (IBAction)osc1PickerChanged:(UISegmentedControl *)sender {
	int newInst = [sender selectedSegmentIndex];
	[delegate changeInstrument:newInst withIndex:0];
}

- (IBAction)osc2PickerChanged:(UISegmentedControl *)sender {
	int newInst = [sender selectedSegmentIndex];
	[delegate changeInstrument:newInst withIndex:1];
}

- (IBAction)osc3PickerChanged:(UISegmentedControl *)sender {
	int newInst = [sender selectedSegmentIndex];
	[delegate changeInstrument:newInst withIndex:2];
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
