    //
//  CompositionsViewController.m
//  awesomesauce
//
//  Created by Ravi Parikh on 3/7/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "CompositionsViewController.h"
#import "MatrixHandler.h"
#import "awesomesauceAppDelegate.h"


@implementation CompositionsViewController

@synthesize parent;
@synthesize compIds;
@synthesize compMap;
@synthesize downloads;
@synthesize uploadName;
@synthesize shareButton;
@synthesize loadingSpinner;
@synthesize loadingText;


- (IBAction)returnToMain:(id)sender {
	[parent returnToMain:sender];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


-(void)viewDidLoad {
	[super viewDidLoad];
	
	downloads.dataSource = self;
	downloads.delegate = self;
	
	selectedComp = -1;
	
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];

	//this is going to respond with a notification "composition_list_loaded," so register for it
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compositionsLoaded:) name:@"composition_list_loaded" object:nil];
	[mh->serverDelegate requestCompositionListFromServer];
}


//comes in as { id: name, ... }
-(void)compositionsLoaded:(NSNotification*)notification {
	if(compIds != nil) [compIds release];
	if(compMap != nil) [compMap release];
	
	compIds = [[NSMutableArray alloc] initWithArray:[[notification userInfo] allKeys]];
	compMap = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
	
	//reload the tableview
	[downloads reloadData];

	//TODO: NOTE: hopefully dupes don't break!
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_list_loaded" object:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	//TODO: NOTE: IS THIS GOING TO BREAK SOMETHING?????
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_uploaded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_list_loaded" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_loaded" object:nil];
}


- (void)dealloc {
    [super dealloc];
	
	//TODO: right?
	[compIds release];
	[compMap release];
}

-(void)uploadDone {
	[loadingText setText:@"done!"];
	[loadingSpinner stopAnimating];
	[loadingSpinner setHidden:YES];
	
	//hide the text in 5 seconds
	[self performSelectorInBackground:@selector(killDoneAfterTimeout:) withObject:[NSNumber numberWithInt:3]];
	
	//TODO: hopefully calling this multiple times doesn't break anything...
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_uploaded" object:nil];
	
	//refresh the datas (TODO:COPIED) -- refresh the list
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compositionsLoaded:) name:@"composition_list_loaded" object:nil];
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	[mh->serverDelegate requestCompositionListFromServer];
}

-(void)killDoneAfterTimeout:(NSNumber*)time {
	usleep([time integerValue] * 1000000);
	[loadingText setHidden:YES];
	[loadingText setText:@"uploading..."];
}

- (IBAction)shareTrack:(id)sender {
	NSString *name = [uploadName text];
	
	if (name != nil) {
		MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
		[loadingText setHidden:NO];
		[loadingSpinner setHidden:NO];
		[loadingSpinner startAnimating];
		
		//this is going to respond with a notification "composition_uploaded," so register for it
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDone) name:@"composition_uploaded" object:nil];
		mh->saveCurrentComposition(name);
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedComp = indexPath.row;
	[downloads reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	
	//this is going to respond with a notification "composition_loaded," so register for it
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadedComposition:) name:@"composition_loaded" object:nil];
	[mh->serverDelegate requestCompositionFromServerWithID:[[compIds objectAtIndex:indexPath.row] integerValue]];
}


-(void)downloadedComposition:(NSNotification*)notification {
	NSDictionary *new_mh = [[notification userInfo] retain];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_loaded" object:nil];
	
	MatrixHandler *mh = [(awesomesauceAppDelegate*)[[UIApplication sharedApplication] delegate] getMatrixHandler];

	NSLog(@"decoding... %@", new_mh);
	mh->decode([new_mh objectForKey:@"data"]);
	
	selectedComp = -1;
	[downloads reloadData];
	
	[new_mh release];
}


//UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *newCell = [[UITableViewCell alloc] init];
	UILabel *newCellLabel = [newCell textLabel];
	
	if (compIds == nil || indexPath.row == selectedComp) {
		[newCellLabel setText:@"loading..."];	
	}else {
		[newCellLabel setText:[compMap objectForKey:[compIds objectAtIndex:indexPath.row]]];
	}

	return newCell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (compIds == nil)? 1 : (NSInteger)[compIds count];
}


@end
