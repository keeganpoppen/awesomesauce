    //
//  ArrangeViewController.m
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "ArrangeViewController.h"
#import "awesomesauceAppDelegate.h"
#import "JSON.h"

#define CUR_IP @"192.168.190.160"

@implementation ArrangeViewController
@synthesize delegate;
@synthesize bpmSlider;
@synthesize tracks;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)returnToMain:(id)sender {
	[delegate closeMe];
}

- (IBAction)bpmChanged:(UISlider *)sender {
	[delegate changeBpm:[sender value]];
}

- (IBAction)playButtonPressed {
	if([[playButton titleLabel] text] == @"Play") {
		[delegate startPlayback];
		[playButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
	else {
		[delegate pausePlayback];
		[playButton setTitle:@"Play" forState:UIControlStateNormal];
	}
}

- (IBAction)stopButtonPressed {
	[delegate stopPlayback];
	[playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
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

//table view stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [delegate getNumTracks];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"arrViewCell";
	
	ArrangeTableViewCell *cell = (ArrangeTableViewCell *)[tracks dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"ArrangeTableViewCell" owner:self options:nil];
		cell = tblCell;
	}
	NSString *trackTitle = [NSString stringWithFormat:@"Track %d", indexPath.row+1];
	[cell setLabelText:trackTitle];
	[cell setTrackNum:indexPath.row];
	[cell setMatrixHandler:[delegate getMatrixHandler]];
	[cell setParent:self];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//TODO
}


@end
