//
//  SocialViewController.m
//  awesomesauce
//
//  Created by Ravi Parikh on 3/6/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "SocialViewController.h"
#import "GlobeViewController.h"
#import "CompositionsViewController.h"
#import "InstrumentsViewController.h"

@implementation SocialViewController
@synthesize delegate;
@synthesize tabBar;
@synthesize	globeTabBarItem;
@synthesize compositionsTabBarItem;
@synthesize instrumentsTabBarItem;
@synthesize selectedViewController;
@synthesize viewControllers;
@synthesize HUD;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	int index = 0;
	if (item == globeTabBarItem) {
		index = 0;
	}
	else if (item == compositionsTabBarItem) {
		index = 1;
	}
	else if (item == instrumentsTabBarItem) {
		index = 2;
	}
	UIViewController *vc = [viewControllers objectAtIndex:index];
	[self.selectedViewController.view removeFromSuperview];
	[self.view addSubview:vc.view];
	self.selectedViewController = vc;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
        // Custom initialization
		GlobeViewController *globeTabViewController = [[GlobeViewController alloc] initWithNibName:@"GlobeViewController" bundle:nil];
		CompositionsViewController *compsTabViewController = [[CompositionsViewController alloc] initWithNibName:@"CompositionsViewController" bundle:nil];
		InstrumentsViewController *instsTabViewController = [[InstrumentsViewController alloc] initWithNibName:@"InstrumentsViewController" bundle:nil];
		
		globeTabViewController.parent = self;
		compsTabViewController.parent = self;
		instsTabViewController.parent = self;
		
		NSArray *array = [[NSArray alloc] initWithObjects:globeTabViewController, compsTabViewController, instsTabViewController, nil];
		self.viewControllers = array;
		
		[self.view addSubview:compsTabViewController.view];
		self.selectedViewController = compsTabViewController;
		
		[array release];
		[globeTabViewController release];
		[compsTabViewController release];
		[instsTabViewController release];
		
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	HUD = [[HUDHandler alloc] init];
	//HUD.window = self.view.window;
	HUD.window = [[[UIApplication sharedApplication] delegate] window];
	[HUD registerListeners];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
	
	[HUD unregisterListeners];
}

- (IBAction)returnToMain:(id)sender {
	[delegate closeMe];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[tabBar release];
	[globeTabBarItem release];
	[compositionsTabBarItem release];
	[instrumentsTabBarItem release];
	[selectedViewController release];
	[viewControllers release];
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
