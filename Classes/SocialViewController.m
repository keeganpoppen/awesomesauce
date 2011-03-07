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

/*
 * handlers and junk from before
 */

/*
//TODO: THIS LOGIC IS IN TOTALLY THE WRONG PLACE
- (IBAction)shareTrack:(id)sender {
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	
	NSDictionary *composition = mh->encode();
	NSLog(@"sending track to server");
	[mh->serverDelegate sendCompositionToServer:composition withName:[trackName text]];
}

//TODO: THIS LOGIC IS IN TOTALLY THE WRONG PLACE
- (IBAction)loadTrack:(id)sender {
	int track_id = [[sharedTrackList objectAtIndex:[sharedTracks selectedRowInComponent:0]] intValue];
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	
	NSDictionary *toLoad = [mh->serverDelegate getCompositionFromServerWithID:track_id];
	NSLog(@"loading track from server");
	
	SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
	NSDictionary *composition = [[parser objectWithString:[toLoad objectForKey:@"data"] error:nil] retain];
	
	mh->decode(composition);
}

- (void)viewWillAppear:(BOOL)animated {
	sharedTracks.delegate = self;
	sharedTracks.dataSource = self;
	
	NSLog(@"gonna ask the server for the composition list!");
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	currentlySharedTracks = [[mh->serverDelegate getCompositionListFromServer] retain];
	
	NSLog(@"found the following: %@", [currentlySharedTracks description]);
	
	sharedTrackList = [[[NSMutableArray alloc] initWithCapacity:[currentlySharedTracks count]] retain];
	for (id key in currentlySharedTracks) {
		[sharedTrackList addObject:(NSString *)key];
	}
	
	[sharedTracks reloadAllComponents];
}
 */

/*
 * pickerview crap
 */

/*
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [sharedTrackList count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 50.;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return 385.;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [currentlySharedTracks objectForKey:[sharedTrackList objectAtIndex:row]];
}
*/

@end
