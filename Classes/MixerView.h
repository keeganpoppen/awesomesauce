//
//  MixerView.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/14/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixHandler.h"

@class awesomesauceViewController;

@interface MixerView : UIView {
	IBOutlet UILabel *trackName;
	IBOutlet UIButton *editButton;
	IBOutlet UISwitch *onSwitch;
	
	int trackNum;
	MatrixHandler *matrixHandler;
	awesomesauceViewController *parent;
}

- (void)setLabelText:(NSString *)labelText;
- (void)setTrackNum:(int)num;
- (void)setMatrixHandler:(MatrixHandler *)mh;
- (void)setParent:(awesomesauceViewController *)avc;
- (void)disableTrack;
- (void)enableTrack:(NSString *)labelText;
- (IBAction)editButtonPressed:(UIButton *)sender;
- (IBAction)onSwitchToggled;
- (int)getTrackNum;

@end
