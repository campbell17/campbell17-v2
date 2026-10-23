#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

BOOL GAvailable(void);
NSArray *GDisplays(void);
NSArray<NSNumber *> *GWindowSpaces(uint32_t window);
CGError GMove(uint32_t window, uint64_t space);
uint32_t GWindowID(AXUIElementRef element);
NSArray *GApplicationWindows(pid_t pid);
NSArray *GWindowInventory(void);
BOOL GPostDesktopStep(BOOL right);
