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
}

@property (nonatomic, retain) IBOutlet UISlider *bpmSlider;
@property (nonatomic, retain) IBOutlet UITableView *tracks;
@property (nonatomic, retain) id <ArrangeViewProtocol, FlipViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;
- (IBAction)bpmChanged:(UISlider *)sender;

@end

@protocol ArrangeViewProtocol
- (void) changeBpm:(float)newBpm;
- (int) getNumTracks;
- (void) closeAndSwitchTrack:(int)trackNum;
@end
