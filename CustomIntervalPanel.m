/*=========================================================================
 Program:   OsiriX
 
 Copyright (c) OsiriX Team
 All rights reserved.
 Distributed under GNU - LGPL
 
 See http://www.osirix-viewer.com/copyright.html for details.
 
 This software is distributed WITHOUT ANY WARRANTY; without even
 the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.
 =========================================================================*/

#import "CustomIntervalPanel.h"
#import "browserController.h"

@interface CustomIntervalPanel ()

@end

@implementation CustomIntervalPanel

@synthesize fromDate, toDate;

+ (CustomIntervalPanel*) sharedCustomIntervalPanel
{
    static CustomIntervalPanel *sharedCustomIntervalPanel = nil;
    
    if( sharedCustomIntervalPanel == nil)
    {
        sharedCustomIntervalPanel = [[CustomIntervalPanel alloc] initWithWindowNibName: @"CustomIntervalPanel"];
        
        sharedCustomIntervalPanel.fromDate = [NSDate date];
        sharedCustomIntervalPanel.toDate = [NSDate date];
        [sharedCustomIntervalPanel sizeWindowAccordingToSettings];
        [sharedCustomIntervalPanel setFormatAccordingToSettings];
    }
    
    return sharedCustomIntervalPanel;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [BrowserController currentBrowser].timeIntervalType = 0;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
		[fromPicker setLocale: [NSLocale currentLocale]];
		[toPicker setLocale: [NSLocale currentLocale]];
		[textualFromPicker setLocale: [NSLocale currentLocale]];
		[textualToPicker setLocale: [NSLocale currentLocale]];
        
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver: self
                                                                forKeyPath: @"values.customIntervalWithHoursAndMinutes"
                                                                   options: NSKeyValueObservingOptionNew
                                                                   context: NULL];
        
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver: self
                                                                forKeyPath: @"values.betweenDatesMode"
                                                                   options: NSKeyValueObservingOptionNew
                                                                   context: NULL];
    }
    
    return self;
}

- (void) sizeWindowAccordingToSettings
{
    NSRect frame = self.window.frame;
    
    if( [[NSUserDefaults standardUserDefaults] boolForKey: @"betweenDatesMode"])
        frame = NSMakeRect( frame.origin.x, frame.origin.y - (498 - frame.size.height), frame.size.width, 498);
    else
        frame = NSMakeRect( frame.origin.x, frame.origin.y - (287 - frame.size.height), frame.size.width, 287);
    
    if( [[NSUserDefaults standardUserDefaults] boolForKey: @"betweenDatesMode"] && [[NSUserDefaults standardUserDefaults] boolForKey: @"customIntervalWithHoursAndMinutes"])
        frame = NSMakeRect( frame.origin.x, frame.origin.y, 288, frame.size.height);
    else
        frame = NSMakeRect( frame.origin.x, frame.origin.y, 154, frame.size.height);
    
    [self.window setFrame: frame display: YES animate: YES];
}

- (void) setFormatAccordingToSettings
{
    if( [[NSUserDefaults standardUserDefaults] boolForKey: @"betweenDatesMode"] && [[NSUserDefaults standardUserDefaults] boolForKey: @"customIntervalWithHoursAndMinutes"])
    {
        [toPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
        [fromPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
        
        [textualFromPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
        [textualToPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
    }
    else
    {
        [toPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag];
        [fromPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag];
        
        [textualFromPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag];
        [textualToPicker setDatePickerElements: NSYearMonthDayDatePickerElementFlag];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqual:@"values.betweenDatesMode"] || [keyPath isEqual:@"values.customIntervalWithHoursAndMinutes"])
    {
        [self setFormatAccordingToSettings];
        
        [self sizeWindowAccordingToSettings];
        
        self.fromDate = fromPicker.dateValue;
        self.toDate = toPicker.dateValue;
    }
}

- (void) setFromDate:(NSDate *) date
{
    if( [fromDate isEqualToDate: date] == NO)
    {
        [fromDate release];
        
        if( [[NSUserDefaults standardUserDefaults] boolForKey: @"customIntervalWithHoursAndMinutes"] && [[NSUserDefaults standardUserDefaults] boolForKey: @"betweenDatesMode"])
        {
            fromDate = [date copy];
        }
        else
        {
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
            NSDateComponents *components = [[NSCalendar currentCalendar] components: unitFlags fromDate: date];
            
            fromDate = [[[NSCalendar currentCalendar] dateFromComponents: components] retain];
            
            if( [[NSUserDefaults standardUserDefaults] boolForKey: @"betweenDatesMode"] == NO)
                self.toDate = date;
        }
        
        [BrowserController currentBrowser].timeIntervalType = 100;
        [[BrowserController currentBrowser] computeTimeInterval];
        [[BrowserController currentBrowser] outlineViewRefresh];
    }
}

- (void) setToDate:(NSDate *) date
{
    if( [toDate isEqualToDate: date] == NO)
    {
        [toDate release];
        
        if( [[NSUserDefaults standardUserDefaults] boolForKey: @"customIntervalWithHoursAndMinutes"] && [[NSUserDefaults standardUserDefaults] boolForKey: @"betweenDatesMode"])
        {
            toDate = [date copy];
        }
        else
        {
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
            NSDateComponents *components = [[NSCalendar currentCalendar] components: unitFlags fromDate: date];
            
            [components setHour: 23];
            [components setMinute: 59];
            [components setSecond: 59];
            
            toDate = [[[NSCalendar currentCalendar] dateFromComponents: components] retain];
        }
        
        [BrowserController currentBrowser].timeIntervalType = 100;
        [[BrowserController currentBrowser] computeTimeInterval];
        [[BrowserController currentBrowser] outlineViewRefresh];
    }
}
- (IBAction) nowFrom:(id)sender;
{
    self.fromDate = [NSDate date];
}

- (IBAction) nowTo:(id) sender;
{
     self.toDate = [NSDate date];
}

- (void) dealloc
{
    [fromDate release];
    [toDate release];
    
    [super dealloc];
}
@end
