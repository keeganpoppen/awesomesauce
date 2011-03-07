//
//  SynthViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SynthViewProtocol;
@protocol FlipViewProtocol;


@interface SynthViewController : UIViewController {
	id <FlipViewProtocol, SynthViewProtocol> delegate;
	IBOutlet UILabel *titleLabel;
	IBOutlet UISegmentedControl *instPicker;
	
	//envelope controls
	IBOutlet UISlider *envLength;
	IBOutlet UISlider *envAttack;
	IBOutlet UISlider *envRelease;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *instPicker;
@property (nonatomic, retain) IBOutlet UISlider *envLength;
@property (nonatomic, retain) IBOutlet UISlider *envAttack;
@property (nonatomic, retain) IBOutlet UISlider *envRelease;
@property (nonatomic, retain) id <SynthViewProtocol, FlipViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;
- (IBAction)envLengthChanged:(UISlider *)sender;
- (IBAction)envAttackChanged:(UISlider *)sender;
- (IBAction)envReleaseChanged:(UISlider *)sender;

@end

@protocol SynthViewProtocol
-(void) changeInstrument:(int)newInst;
-(void) changeEnvLength:(float)newVal;
-(void) changeEnvAttack:(float)newVal;
-(void) changeEnvRelease:(float)newVal;
@end
