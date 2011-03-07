//
//  ArrangeViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrangeTableViewCell.h"

@protocol ArrangeViewProtocol;
@protocol FlipViewProtocol;


@interface ArrangeViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource> {
	id <FlipViewProtocol, ArrangeViewProtocol> delegate;
	IBOutlet UISlider *bpmSlider;
	IBOutlet UITableView *tracks;
	IBOutlet ArrangeTableViewCell *tblCell;
	
	IBOutlet UIPickerView *sharedTracks;
	IBOutlet UITextField *trackName;
	NSDictionary *currentlySharedTracks;
	NSMutableArray *sharedTrackList;
}

@property (nonatomic, retain) NSDictionary *currentlySharedTracks;
@property (nonatomic, retain) NSMutableArray *sharedTrackList;
@property (nonatomic, retain) IBOutlet UISlider *bpmSlider;
@property (nonatomic, retain) IBOutlet UITableView *tracks;
@property (nonatomic, retain) IBOutlet UIPickerView *sharedTracks;
@property (nonatomic, retain) IBOutlet UITextField *trackName;

@property (nonatomic, retain) id <ArrangeViewProtocol, FlipViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;
- (IBAction)bpmChanged:(UISlider *)sender;
- (IBAction)shareTrack:(id)sender;
- (IBAction)loadTrack:(id)sender;

//pickerview junk
	//data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
	//delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;


@end

@protocol ArrangeViewProtocol
- (void) changeBpm:(float)newBpm;
- (int) getNumTracks;
- (void) closeAndSwitchTrack:(int)trackNum;
@end
