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


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	//TODO: NOTE: IS THIS GOING TO BREAK SOMETHING?????
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_uploaded" object:nil];
}


- (void)dealloc {
    [super dealloc];
}

-(void)uploadDone {
	[loadingText setHidden:YES];
	[loadingSpinner stopAnimating];
	[loadingSpinner setHidden:YES];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"composition_uploaded" object:nil];
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


@end
