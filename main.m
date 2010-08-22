#include <Cocoa/Cocoa.h>
#include "CGSPrivate.h"
#include "SMSLib/smslib.h"

int main (int argc, const char * argv[]) {
	smsStartup(NULL, NULL);
	sms_acceleration accel;
	int accelThreshold = 20;
	
	int currentWorkspace;
	CGSGetWorkspace(_CGSDefaultConnection(), &currentWorkspace);
	
	CGSTransitionSpec transition;
	transition.unknown1 = 0;
	transition.type = CGSWarpFade;
	transition.option = CGSLeft;
	transition.wid = 0;
	transition.backColour = NULL;
	
	float transitionDuration = 0.4;
	
	bool shouldSwitch = FALSE;
	
	
	while (1) {
		smsGetUncalibratedData(&accel);
		if (accel.x > accelThreshold) {
			currentWorkspace = (currentWorkspace == 4 ? 1 : currentWorkspace + 1);
			transition.option = CGSLeft;
			shouldSwitch = TRUE;
		} else if (accel.x < -accelThreshold) {
			currentWorkspace = (currentWorkspace == 1 ? 4 : currentWorkspace - 1);
			transition.option = CGSRight;
			shouldSwitch = TRUE;
		}
		
		if (shouldSwitch) {
			int handle;
			CGSNewTransition(_CGSDefaultConnection(), &transition, &handle);
			OSStatus result = CGSSetWorkspace(_CGSDefaultConnection(), currentWorkspace);
			if (result != noErr) {
				CGSReleaseTransition(_CGSDefaultConnection(), handle);
				smsShutdown();
				return 1;
			}
			usleep(1000);	// Let the window server redraw before we transition.
			
			CGSInvokeTransition(_CGSDefaultConnection(), handle, transitionDuration);
			usleep(1000000 * transitionDuration);	// Make sure we don't release the transition until it's done.
			
			CGSReleaseTransition(_CGSDefaultConnection(), handle);
			//printf("Switched to space %i: result=%i\n", currentWorkspace, result);
			shouldSwitch = FALSE;
		}
		
		usleep(10000);
	}
    
	return 0;
}
