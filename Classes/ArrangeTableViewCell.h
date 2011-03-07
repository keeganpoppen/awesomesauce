//
//  ArrangeTableViewCell.h
//  awesomesauce
//
//  Created by Ravi Parikh on 3/7/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixHandler.h"

@class ArrangeViewController;

@interface ArrangeTableViewCell : UITableViewCell {
	IBOutlet UILabel *trackName;
	IBOutlet UIButton *editButton;
	IBOutlet UISwitch *onSwitch;
	
	int trackNum;
	MatrixHandler *matrixHandler;
	ArrangeViewController *parent;
}

- (void)setLabelText:(NSString *)labelText;
- (void)setTrackNum:(int)num;
- (void)setMatrixHandler:(MatrixHandler *)mh;
- (void)disableTrack;
- (void)enableTrack:(NSString *)labelText;
- (void)setParent:(ArrangeViewController *)avc;
- (IBAction)editButtonPressed:(UIButton *)sender;
- (IBAction)onSwitchToggled;

@end
