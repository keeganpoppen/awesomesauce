//
//  SocialViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 3/6/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialViewProtocol;
@protocol FlipViewProtocol;

@interface SocialViewController : UIViewController /*<UIPickerViewDelegate, UIPickerViewDataSource>*/ {
	id <FlipViewProtocol, SocialViewProtocol> delegate;

	/*
	IBOutlet UIPickerView *sharedTracks;
	IBOutlet UITextField *trackName;
	NSDictionary *currentlySharedTracks;
	NSMutableArray *sharedTrackList;
	 */
}
/*
@property (nonatomic, retain) NSDictionary *currentlySharedTracks;
@property (nonatomic, retain) NSMutableArray *sharedTrackList;
@property (nonatomic, retain) IBOutlet UIPickerView *sharedTracks;
@property (nonatomic, retain) IBOutlet UITextField *trackName;
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
*/

@property (nonatomic, retain) id <FlipViewProtocol, SocialViewProtocol> delegate;

- (IBAction)returnToMain:(id)sender;

@end

@protocol SocialViewProtocol
@end
