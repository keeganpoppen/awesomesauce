//
//  CompositionsViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 3/7/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialViewController.h"

@interface CompositionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	id <FlipViewProtocol, SocialViewProtocol> delegate;
	SocialViewController *parent;
	
	NSMutableArray *compIds;
	NSMutableDictionary *compMap;
	NSInteger selectedComp;
	
	IBOutlet UITableView *downloads;
	
	IBOutlet UITextField *uploadName;
	IBOutlet UIButton *shareButton;

	IBOutlet UIActivityIndicatorView *loadingSpinner;
	IBOutlet UILabel *loadingText;
}

@property(nonatomic, retain) SocialViewController *parent;
@property(nonatomic, retain) NSMutableArray *compIds;
@property(nonatomic, retain) NSMutableDictionary *compMap;
@property(nonatomic, retain) IBOutlet UITableView *downloads;
@property(nonatomic, retain) IBOutlet UITextField *uploadName;
@property(nonatomic, retain) IBOutlet UIButton *shareButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property(nonatomic, retain) IBOutlet UILabel *loadingText;
@property(nonatomic, retain) id <FlipViewProtocol, SocialViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;
- (IBAction)shareTrack:(id)sender;
- (void)uploadDone;
- (void)compositionsLoaded:(NSNotification*)notification;
- (void)downloadedComposition:(NSNotification*)notification;

//UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
