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
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *instPicker;
@property (nonatomic, retain) id <SynthViewProtocol, FlipViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;

@end

@protocol SynthViewProtocol
-(void) changeInstrument:(int)newInst;
@end
