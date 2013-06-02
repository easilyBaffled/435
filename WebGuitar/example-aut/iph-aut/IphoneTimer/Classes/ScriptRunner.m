//
//  ScriptRunner.m
//  SelfTesting
//
//  Created by Matt Gallagher on 9/10/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#ifdef SCRIPT_DRIVEN_TEST_MODE_ENABLED

#import "ScriptRunner.h"
#import "UIView+FullDescription.h"
#import "XPathQuery.h"
#import "TouchSynthesis.h"
#import <stdio.h>
#import <stdlib.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSObject.h>

@interface Coordinates : NSObject {
	int x;
	int y;
}

- (Coordinates*)initWithX:(int)x andY:(int)y;
- (int) x;
- (int) y;

@end

@implementation Coordinates

- (Coordinates*)initWithX:(int)xIn andY:(int)yIn {
    if (self = [super init]) {
		x	= xIn;
		y	= yIn;
    }
    return self;
}

- (int) x {
	return x;
}

- (int) y {
	return y;
}

- (void)dealloc {
    [super dealloc];
}

@end

const float SCRIPT_RUNNER_INTER_COMMAND_DELAY = .5;

@implementation ScriptRunner

@synthesize delegate;
@synthesize callback;
@synthesize errorCallback;

//
// init
//
// Init method for the object.
// 
- (id)init
{
	self = [super init];
	if (self != nil)
	{
		imgNum = 0;
		numWindows = 1;
		buttonsTo = [[NSArray arrayWithObjects: [[Coordinates alloc] initWithX:104 andY:309], nil] retain];
		buttonsFrom = [[NSArray arrayWithObjects: [[Coordinates alloc] initWithX:104 andY:262], nil] retain];
		
		// Connect to java server.		
		NSString *urlStr = @"http://localhost:8081/";
		if (![urlStr isEqualToString:@""]) {
			NSURL *website = [NSURL URLWithString:urlStr];
			if (!website) {
				NSLog(@"%@ is not a valid URL");
				return;
			}
			
			CFReadStreamRef readStream;
			CFWriteStreamRef writeStream;
			CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[website host], 8081, &readStream, &writeStream);
			
			inputStream_ = (NSInputStream *)readStream;
			outputStream_ = (NSOutputStream *)writeStream;
			
			[inputStream_ setDelegate:self];
			//[outputStream_ setDelegate:self];
			
			[inputStream_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			//[outputStream_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			
			[inputStream_ open];
			[outputStream_ open];
		}
		
		guitarCommands = [[NSMutableArray alloc] init];
		[self retain];;
		keep_running = YES;
		no_SDK = NO;
		
		[self performSelector:@selector(runCommand) withObject:nil afterDelay:1.0];
	}
	return self;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[buttonsTo release];
	[buttonsFrom release];
	[guitarCommands dealloc];
	[super dealloc];
}

- (void)sendText:(NSString *)message {
    NSString * stringToSend = [NSString stringWithFormat:@"%@\n", message];
	NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
	if (outputStream_) {
		int remainingToWrite = [dataToSend length];
		void * marker = (void *)[dataToSend bytes];
		while (0 < remainingToWrite) {
			int actuallyWritten = 0;
			actuallyWritten = [outputStream_ write:marker maxLength:remainingToWrite];
			remainingToWrite -= actuallyWritten;
			marker += actuallyWritten;
		}
		NSLog(@"Done sending message.");
	}
}

- (void)takeScreenshot {
//	SwitchAppDelegate *del = [UIApplication sharedApplication].delegate;
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	UIViewController *controller = window.rootViewController;
	UIGraphicsBeginImageContext(controller.view.bounds.size);
	[controller.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
	NSData* imageData = UIImageJPEGRepresentation (viewImage, 1.0);
	imgNum++;
	[imageData writeToFile:[NSString stringWithFormat:@"Demo/screenshots/img%03d.jpg", imgNum] atomically:NO];
}

- (void)writeToTextFile:(NSString *)str {
	
	//get the documents directory:
	/*
	NSArray *paths = NSSearchPathForDirectoriesInDomains	
	(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	*/
	//make a file name to write the data to using the documents directory:

	NSString *fileName = [NSString stringWithFormat:@"Demo/screenshots/efg%03d.txt", imgNum];
	
	[str writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (BOOL)touchWindow:(NSString *)class x:(NSNumber *)x y:(NSNumber *)y {						
	// Find the desire subview.
	UIView* viewToTouch = [[[UIApplication sharedApplication] keyWindow]
						   findViewWithClass:class andX:x andY:y];
	
	if (viewToTouch) {
		NSLog(@"Found a good view to touch!");								
		[self performTouchInView:viewToTouch];
		return TRUE;
	} else {
		NSLog(@"Found no good view to touch :(");
		return FALSE;
	}
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    NSInputStream * istream;
	 NSLog(@"Handle event.");
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable:;
			istream = (NSInputStream *)aStream;
            NSLog(@"Received stream");
			
            uint8_t buffer[2048];
            int actuallyRead = [inputStream_ read:buffer maxLength:2048];
            if (actuallyRead > 0) {
				NSString *output = [[NSString alloc] initWithBytes:buffer length:actuallyRead encoding:NSASCIIStringEncoding];
				if (nil != output)
				{
					NSLog(@"%@", output);
					
					if ([output isEqualToString:@"invoke main method"]) {
						// We aren't in the SDK at this point.
						no_SDK = YES;
						
						NSLog(@"In main method call.");
						[self sendText:@"Hello"];
						NSLog(@"Finishing main method call.");
					}
					else if ([output isEqualToString:@"get num windows"]) {
						NSLog(@"Sent num windows.");
						[self sendText:[NSString stringWithFormat:@"%d", numWindows]];
					} 
					else if ([output isEqualToString:@"get root window list"]) {
						NSString* keyWindowDescription = [[[UIApplication sharedApplication] keyWindow] fullDescription];
						NSLog(@"%@", keyWindowDescription);
						[self sendText:keyWindowDescription];
						NSLog(@"finished sending root window.");
						[self takeScreenshot];
					}
					else if ([output isEqualToString:@"get new window"]) {
						for ( int i = 0; i < [buttonsTo count]; i++ ) {
							Coordinates *to = [buttonsTo objectAtIndex:i];
							Coordinates *from = [buttonsFrom objectAtIndex:i];
							
							[self touchWindow:@"UIRoundedRectButton" x: [NSNumber numberWithInt:to.x] y:[NSNumber numberWithInt:to.y] ];
							NSLog( @"going to new view, touching button at x: %d, y: %d.", to.x, to.y );
							
							NSString* keyWindowDescription = [[[UIApplication sharedApplication] keyWindow] fullDescription];
							
							NSLog(@"%@", keyWindowDescription);
							[self sendText:keyWindowDescription];
							[self takeScreenshot];

							[self touchWindow:@"UIRoundedRectButton" x:[NSNumber numberWithInt:from.x] y:[NSNumber numberWithInt:from.y]];
							NSLog( @"returning from new view, touching button at x: %d, y: %d.", from.x, from.y );
							NSLog( @"finished sending new window." );
						}
					}
					else if ([output hasPrefix:@"INVOKE"]) {
						// [self sendText:@"Received INVOKE request!"];
						NSArray *chunks = [output componentsSeparatedByString: @" "];
						
						// Handle command (just TOUCH for the time being).
						if ([[chunks objectAtIndex:1] isEqualToString:@"TOUCH"]) {
							NSLog(@"Received TOUCH request.");

							NSString* class = [chunks objectAtIndex:2];
							NSNumber *x = [NSNumber numberWithInt:[[chunks objectAtIndex:3] intValue]];
							NSNumber *y = [NSNumber numberWithInt:[[chunks objectAtIndex:4] intValue]];
							
							// Find the desire subview.
							UIView* viewToTouch = [[[UIApplication sharedApplication] keyWindow]
												   findViewWithClass:class andX:x andY:y];
							
							if (viewToTouch) {
								NSLog(@"Found a good view to touch!");								
								NSDictionary* newGuitarCommand = [NSDictionary dictionaryWithObjectsAndKeys:
									 class, @"class",
									 x, @"x",
									 y, @"y",
									 @"INVOKE_TOUCH", @"action",
									 nil];
								
								[guitarCommands addObject:newGuitarCommand];
								
								[self performTouchInView:viewToTouch];
							} else {
								NSLog(@"Found no good view to touch :(");
							}
							
							NSLog(@"Sending response back");
							[self sendText:[NSString stringWithFormat:@"Touch happened for %@!", class]];
						} 
						// Handle command (just TOUCH for the time being).
						else if ([[chunks objectAtIndex:1] isEqualToString:@"PICKER_WHEEL"]) {
							NSLog(@"Received PICKER_WHEEL request.");
							
							NSString* class = [chunks objectAtIndex:2];
							NSNumber *x = [NSNumber numberWithInt:[[chunks objectAtIndex:3] intValue]];
							NSNumber *y = [NSNumber numberWithInt:[[chunks objectAtIndex:4] intValue]];
							
							// Find the desire subview.
							UIView* viewToTouch = [[[UIApplication sharedApplication] keyWindow]
												   findViewWithClass:class andX:x andY:y];
							
							if (viewToTouch) {
								NSLog(@"Found a good view to touch!");								
								NSDictionary* newGuitarCommand = [NSDictionary dictionaryWithObjectsAndKeys:
																  class, @"class",
																  x, @"x",
																  y, @"y",
																  @"INVOKE_PICKER_WHEEL", @"action",
																  nil];
								
								[guitarCommands addObject:newGuitarCommand];
								
								[self performPickerWheel:viewToTouch];
							} else {
								NSLog(@"Found no good view to touch :(");
							}
							
							NSLog(@"Sending response back");
							[self sendText:[NSString stringWithFormat:@"PICKER_WHEEL happened for %@!", class]];
						}						
						
					} else {
						NSLog(@"Unknown command: %@", output);
						[self sendText:@"Unknown command"];
					}					
					[output release];
				}
            }
			break;
        case NSStreamEventEndEncountered:;
			NSLog(@"NSStreamEventEndEncountered\n" );
			break;
        case NSStreamEventHasSpaceAvailable:
			NSLog(@"NSStreamEventHasSpaceAvailable\n" );
			break;
        case NSStreamEventErrorOccurred:
			NSLog(@"NSStreamEventErrorOccurred\n" );
			NSError *theError = [aStream streamError];
			NSLog(@"%@", [theError localizedDescription]);
			break;
        case NSStreamEventOpenCompleted:
			NSLog(@"NSStreamEventOpenCompleted\n" );
			break;
        case NSStreamEventNone:
			NSLog(@"NSStreamEventNone\n" );
        default:
            break;
    }
	
	/*
	if ([windowIndexes containsObject:[NSNumber numberWithInt:imgNum]]) {
    NSLog(@"Grabbing screenshot and GUI Structure!\n");
		NSString* efg =
			[[[UIApplication sharedApplication] keyWindow] fullDescription];

		[self writeToTextFile:efg];
		[self takeScreenshot];
	}
	imgNum++;*/
}

//
// performTouchInView:
//
// Synthesize a touch begin/end in the center of the specified view. Since there
// is no API to do this, it's a dirty hack of a job.
//
- (void)performTouchInView:(UIView *)view
{
	UITouch *touch = [[UITouch alloc] initInView:view];
	UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];
	
	[touch.view touchesBegan:[eventDown allTouches] withEvent:eventDown];
	[touch setPhase:UITouchPhaseEnded];
	UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];
	
	[touch.view touchesEnded:[eventUp allTouches] withEvent:eventUp];
	
	[eventDown release];
	[eventUp release];
	[touch release];
}

- (void)performPickerWheel:(UIView *)view
{
	NSLog(@"Inside perform pickerwheel.");
	UIPickerView* picker = (UIPickerView *)view;
	
	// Select a random component, and a random row index.
	int componentIndex = arc4random() % [picker numberOfComponents];
	int rowIndex = arc4random() % [picker numberOfRowsInComponent:componentIndex];
	[picker selectRow:rowIndex inComponent:componentIndex animated:YES];
}

//
// viewsForXPath:
//
// Generates an XML document from the current view tree and runs the specified
// XPath query on the document. If the resulting nodes contain "address" values
// then these values are interrogated to determine if they are UIViews. All
// UIViews found in this way are returned in the array.
//
- (NSArray *)viewsForXPath:(NSString *)xpath
{
	NSDictionary *keyWindowDescription =
		[[[UIApplication sharedApplication] keyWindow] fullDescription];
	NSData *resultData =
		[NSPropertyListSerialization
			dataFromPropertyList:keyWindowDescription
			format:NSPropertyListXMLFormat_v1_0
			errorDescription:nil];

	NSArray *queryResults = PerformXMLXPathQuery(resultData, xpath);
	NSMutableArray *views =
		[NSMutableArray arrayWithCapacity:[queryResults count]];
	for (NSDictionary *result in queryResults)
	{
		int i;
		int count = [[result objectForKey:@"nodeChildArray"] count];
		for (i = 0; i < count; i++)
		{
			NSDictionary *childNode = [[result objectForKey:@"nodeChildArray"] objectAtIndex:i];
			if ([[childNode objectForKey:@"nodeName"] isEqualToString:@"key"] &&
				[[childNode objectForKey:@"nodeContent"] isEqualToString:@"address"])
			{	
				if (i < count - 1)
				{
					NSDictionary *nextNode = [[result objectForKey:@"nodeChildArray"] objectAtIndex:i + 1];
					UIView *view =
						(UIView *)[[nextNode objectForKey:@"nodeContent"] integerValue];
					NSAssert([view isKindOfClass:[UIView class]],
						@"XPath selected memory address did not contain a UIView");
					[views addObject:view];
					break;
				}
			}
		}
	}
	
	return views;
}

//
// runCommand
//
// Runs the first command in the scriptCommands array and then removes it from
// the array.
//
// Two commands are supported:
//	- outputView (writes the XML for a view hierarchy to a file)
//	- simulateTouch (selects a UIView by XPath and simulates a touch within it)
//
- (void)runCommand
{
	// If we are in the SDK, load the guitar commands from the file,
	// otherwise exit gracefully.
	if (no_SDK) {
		[NSThread sleepForTimeInterval:2];
		NSLog(@"Writing out guitar commands: %@", guitarCommands);
		[guitarCommands writeToFile:@"/tmp/guitarCommands.plist" atomically:YES];
		NSLog(@"Shutting down");
		[self release];
		exit(0);
	} else {
		if ([guitarCommands count] == 0) {
			guitarCommands = [[NSMutableArray alloc] initWithContentsOfFile:@"/tmp/guitarCommands.plist"];
		}
		NSLog(@"Performing guitar commands: %@", guitarCommands);			
		if ([guitarCommands count] == 0) {
			NSLog(@"Waiting for an action...");
			[NSThread sleepForTimeInterval:.3];
		} else {
			NSDictionary *guitarCommand = [guitarCommands objectAtIndex:0];
			NSLog(@"Performing guitar command: %@", guitarCommand);

			// Find the desire subview.
			UIView* viewToTouch = [[[UIApplication sharedApplication] keyWindow]
								   findViewWithClass:[guitarCommand objectForKey:@"class"]
								   andX:[guitarCommand objectForKey:@"x"]
								   andY:[guitarCommand objectForKey:@"y"]];
			
			NSLog(@"action: %@", [guitarCommand objectForKey:@"action"]);
			if ([@"INVOKE_PICKER_WHEEL" isEqualToString:[guitarCommand objectForKey:@"action"]]) {
				NSLog(@"Performing picker wheel replay.");
				[self performPickerWheel:viewToTouch];
			} else {
				NSLog(@"Performing touch replay.");
				[self performTouchInView:viewToTouch];
			}
		}
	}

	//
	// Remove each command after execution
	//
	[guitarCommands removeObjectAtIndex:0];

	//
	// Exit the program when complete
	//
	if ([guitarCommands count] == 0) {
		[self
		 performSelector:@selector(dieQuietly)
		 withObject:nil
		 afterDelay:SCRIPT_RUNNER_INTER_COMMAND_DELAY];
	}
	else {
		//
		// If further commands remain, queue the next one
		//
		[self
		 performSelector:@selector(runCommand)
		 withObject:nil
		 afterDelay:SCRIPT_RUNNER_INTER_COMMAND_DELAY];
	}
}

- (void) dieQuietly {
	[self release];
	exit(0);
}

@end

#endif

