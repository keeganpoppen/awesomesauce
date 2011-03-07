//
//  graphics.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class TouchMatrix;

bool graphicsInit();
void displayMatrix(TouchMatrix *matrix);
void setMainScreen(bool newVal);