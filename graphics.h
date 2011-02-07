//
//  graphics.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

class TouchMatrix;

class TouchMatrixDisplay {
	
public:
	TouchMatrixDisplay(TouchMatrix *parentMatrix);
	
	void display();
	
	TouchMatrix *parent;
};

void audioInit();

/*
 @interface graphics : NSObject {
 
 }
 
 @end
 */