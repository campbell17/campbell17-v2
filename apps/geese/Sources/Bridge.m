#import "Bridge.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/nlist.h>

@interface NSObject (GeeseMoveOperation)
- (instancetype)initWithWindows:(NSArray *)windows spaceID:(uint64_t)space;
@end

static int64_t (*submitMove)(void *);
// Tahoe's move operation is not exported. Locate its local symbol in the loaded image.
static void *localSymbol(const char *name) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (!strstr(_dyld_get_image_name(i), "/SkyLight.framework/")) continue;
        const struct mach_header_64 *header = (const void *)_dyld_get_image_header(i);
        if (header->magic != MH_MAGIC_64) return NULL;
        intptr_t slide = _dyld_get_image_vmaddr_slide(i);
        const struct segment_command_64 *linkedit = NULL;
        const struct symtab_command *table = NULL;
        const uint8_t *cursor = (const uint8_t *)(header + 1);
        for (uint32_t j = 0; j < header->ncmds; j++) {
            const struct load_command *command = (const void *)cursor;
            if (command->cmdsize < sizeof(*command)) return NULL;
            if (command->cmd == LC_SYMTAB) table = (const void *)command;
            if (command->cmd == LC_SEGMENT_64) {
                const struct segment_command_64 *segment = (const void *)command;
                if (!strcmp(segment->segname, SEG_LINKEDIT)) linkedit = segment;
            }
            cursor += command->cmdsize;
        }
        if (!linkedit || !table) return NULL;
        uintptr_t base = slide + linkedit->vmaddr - linkedit->fileoff;
        const struct nlist_64 *symbols = (const void *)(base + table->symoff);
        const char *strings = (const void *)(base + table->stroff);
        for (uint32_t j = 0; j < table->nsyms; j++) {
            uint32_t offset = symbols[j].n_un.n_strx;
            if (offset < table->strsize && !strcmp(strings + offset, name))
                return (void *)(slide + symbols[j].n_value);
        }
    }
    return NULL;
}

static void *sky;
static int (*connection)(void);
static CFArrayRef (*displays)(int);
static CFArrayRef (*spaces)(int, int, CFArrayRef);
static CGError (*compat)(int, uint64_t, int);
static CGError (*workspace)(int, uint32_t *, int, int);
static CGError (*isOrderedIn)(int, uint32_t, uint8_t *);
static CFArrayRef (*windowsWithTags)(int, uint32_t, CFArrayRef, uint32_t, uint64_t *, uint64_t *);
static AXError (*windowID)(AXUIElementRef, uint32_t *);

static void load(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sky = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight", RTLD_LAZY);
        connection = dlsym(sky, "SLSMainConnectionID");
        displays = dlsym(sky, "SLSCopyManagedDisplaySpaces");
        spaces = dlsym(sky, "SLSCopySpacesForWindows");
        compat = dlsym(sky, "SLSSpaceSetCompatID");
        workspace = dlsym(sky, "SLSSetWindowListWorkspace");
        isOrderedIn = dlsym(sky, "SLSWindowIsOrderedIn");
        windowsWithTags = dlsym(sky, "SLSCopyWindowsWithOptionsAndTags");
        windowID = dlsym(RTLD_DEFAULT, "_AXUIElementGetWindow");
        submitMove = localSymbol("__ZL54SLSPerformAsynchronousBridgedWindowManagementOperationP47SLSAsynchronousBridgedWindowManagementOperation");
    });
}
BOOL GAvailable(void) {
    load();
    return connection && displays && spaces && compat && workspace && windowID;
}
NSArray *GDisplays(void) {
    load();
    return connection && displays ? CFBridgingRelease(displays(connection())) ?: @[] : @[];
}
NSArray<NSNumber *> *GWindowSpaces(uint32_t window) {
    load();
    if (!connection || !spaces) return @[];
    return CFBridgingRelease(spaces(connection(), 7, (__bridge CFArrayRef)@[@(window)])) ?: @[];
}
CGError GMove(uint32_t window, uint64_t space) {
    if (!GAvailable()) return kCGErrorNotImplemented;
    if (submitMove) {
        Class cls = NSClassFromString(@"SLSBridgedMoveWindowsToManagedSpaceOperation");
        if ([cls instancesRespondToSelector:@selector(initWithWindows:spaceID:)]) {
            id operation = [[cls alloc] initWithWindows:@[@(window)] spaceID:space];
            if (operation) {
                submitMove((__bridge void *)operation);
                return kCGErrorSuccess;
            }
        }
    }
    int cid = connection();
    // The compatibility workspace is temporary. Always clear it, including on failure.
    int token = 0x67656573;
    CGError result = compat(cid, space, token);
    if (result != kCGErrorSuccess) return result;
    result = workspace(cid, &window, 1, token);
    CGError reset = compat(cid, space, 0);
    return result == kCGErrorSuccess ? reset : result;
}
uint32_t GWindowID(AXUIElementRef element) {
    if (!element) return 0;
    load();
    uint32_t result = 0;
    if (windowID) windowID(element, &result);
    return result;
}
// AXWindows omits windows on other Spaces. Retain validated references and
// supplement each scan with bounded discovery of the application's AX objects.
static void rememberWindow(AXUIElementRef element, pid_t pid, NSMutableDictionary *windows) {
    if (!element) return;
    pid_t owner = 0;
    if (AXUIElementGetPid(element, &owner) != kAXErrorSuccess || owner != pid) return;
    CFTypeRef subrole = NULL;
    AXError status = AXUIElementCopyAttributeValue(element, kAXSubroleAttribute, &subrole);
    if (status != kAXErrorSuccess || !subrole) { if (subrole) CFRelease(subrole); return; }
    BOOL standard = CFEqual(subrole, kAXStandardWindowSubrole) || CFEqual(subrole, kAXDialogSubrole);
    CFRelease(subrole);
    if (!standard) return;
    uint32_t wid = GWindowID(element);
    if (wid) {
        AXUIElementSetMessagingTimeout(element, 0.3);
        windows[@(wid)] = (__bridge id)element;
    }
}

NSArray *GApplicationWindows(pid_t pid) {
    load();
    if (!AXIsProcessTrusted()) return @[];
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    if (!app || app.terminated) return @[];
    static NSMutableDictionary *processes;
    static CFTypeRef (*createRemote)(CFDataRef);
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        processes = [NSMutableDictionary dictionary];
        createRemote = dlsym(RTLD_DEFAULT, "_AXUIElementCreateWithRemoteToken");
    });
    for (NSNumber *oldPID in [processes.allKeys copy]) {
        NSRunningApplication *old = [NSRunningApplication runningApplicationWithProcessIdentifier:oldPID.intValue];
        if (!old || old.terminated) [processes removeObjectForKey:oldPID];
    }
    id launch = app.launchDate ?: [NSNull null];
    NSMutableDictionary *state = processes[@(pid)];
    if (!state || ![state[@"launch"] isEqual:launch]) {
        state = [@{@"launch": launch, @"windows": [NSMutableDictionary dictionary], @"cursor": @128} mutableCopy];
        processes[@(pid)] = state;
    }
    NSMutableDictionary *known = state[@"windows"];
    NSMutableDictionary *found = [NSMutableDictionary dictionary];
    // Revalidate cached identities, including closed windows and PID reuse.
    for (NSNumber *wid in [known.allKeys copy]) {
        AXUIElementRef element = (__bridge AXUIElementRef)known[wid];
        if (GWindowID(element) == wid.unsignedIntValue) rememberWindow(element, pid, found);
    }
    AXUIElementRef application = AXUIElementCreateApplication(pid);
    AXUIElementSetMessagingTimeout(application, 0.3);
    CFTypeRef listed = NULL;
    if (AXUIElementCopyAttributeValue(application, kAXWindowsAttribute, &listed) == kAXErrorSuccess && listed) {
        if (CFGetTypeID(listed) == CFArrayGetTypeID()) {
            for (id element in (__bridge NSArray *)listed) {
                if (CFGetTypeID((__bridge CFTypeRef)element) == AXUIElementGetTypeID())
                    rememberWindow((__bridge AXUIElementRef)element, pid, found);
            }
        }
    }
    if (listed) CFRelease(listed);
    for (NSString *key in @[@"AXMainWindow", @"AXFocusedWindow"]) {
        CFTypeRef value = NULL;
        if (AXUIElementCopyAttributeValue(application, (__bridge CFStringRef)key, &value) == kAXErrorSuccess && value && CFGetTypeID(value) == AXUIElementGetTypeID())
            rememberWindow((AXUIElementRef)value, pid, found);
        if (value) CFRelease(value);
    }
    CFRelease(application);
    if (createRemote) {
        // Remote tokens encode pid, object kind, and the app-local AX identifier.
        uint8_t token[20] = {0};
        uint32_t kind = 0x636f636f;
        memcpy(token, &pid, sizeof(pid));
        memcpy(token + 8, &kind, sizeof(kind));
        uint64_t cursor = [state[@"cursor"] unsignedLongLongValue];
        CFAbsoluteTime deadline = CFAbsoluteTimeGetCurrent() + 0.06;
        for (uint64_t offset = 0; offset < 1152; offset++) {
            uint64_t identifier = offset < 128 ? offset : cursor++;
            memcpy(token + 12, &identifier, sizeof(identifier));
            CFDataRef data = CFDataCreate(NULL, token, sizeof(token));
            AXUIElementRef element = (AXUIElementRef)createRemote(data);
            CFRelease(data);
            if (element) {
                AXUIElementSetMessagingTimeout(element, 0.03);
                rememberWindow(element, pid, found);
                CFRelease(element);
            }
            if (CFAbsoluteTimeGetCurrent() >= deadline) break;
        }
        state[@"cursor"] = @(cursor >= 65536 ? 128 : cursor);
    }
    state[@"windows"] = found;
    return found.allValues;
}

// WindowServer keeps desktop membership even before an app creates AX objects.
NSArray *GWindowInventory(void) {
    load();
    if (!connection || !windowsWithTags) return @[];
    NSMutableArray *spaceIDs = [NSMutableArray array];
    for (NSDictionary *display in GDisplays()) {
        for (NSDictionary *space in display[@"Spaces"]) {
            if (space[@"ManagedSpaceID"]) [spaceIDs addObject:space[@"ManagedSpaceID"]];
        }
    }
    uint64_t setTags = 0, clearTags = 0;
    NSArray *all = CFBridgingRelease(windowsWithTags(connection(), 0, (__bridge CFArrayRef)spaceIDs, 7, &setTags, &clearTags));
    setTags = clearTags = 0;
    NSArray *notMinimized = CFBridgingRelease(windowsWithTags(connection(), 0, (__bridge CFArrayRef)spaceIDs, 2, &setTags, &clearTags));
    if (!all || !notMinimized) return @[];
    NSSet *allIDs = [NSSet setWithArray:all], *normalIDs = [NSSet setWithArray:notMinimized];
    NSArray *raw = CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionAll | kCGWindowListExcludeDesktopElements, kCGNullWindowID));
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *window in raw) {
        NSNumber *wid = window[(id)kCGWindowNumber];
        NSDictionary *bounds = window[(id)kCGWindowBounds];
        uint8_t ordered = 0;
        if (isOrderedIn && isOrderedIn(connection(), wid.unsignedIntValue, &ordered) == kCGErrorSuccess && !ordered &&
            ![NSRunningApplication runningApplicationWithProcessIdentifier:[window[(id)kCGWindowOwnerPID] intValue]].hidden) continue;
        if ([window[(id)kCGWindowLayer] intValue] != 0 || ![allIDs containsObject:wid] ||
            [bounds[@"Width"] doubleValue] < 32 || [bounds[@"Height"] doubleValue] < 32) continue;
        [result addObject:@{@"id": wid, @"pid": window[(id)kCGWindowOwnerPID], @"minimized": @(![normalIDs containsObject:wid])}];
    }
    return result;
}

BOOL GPostDesktopStep(BOOL right) {
    if (!AXIsProcessTrusted()) return NO;
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    if (!source) return NO;
    CGEventRef down = CGEventCreateKeyboardEvent(source, right ? 124 : 123, true);
    CGEventRef up = CGEventCreateKeyboardEvent(source, right ? 124 : 123, false);
    BOOL created = down && up;
    if (created) {
        CGEventFlags flags = kCGEventFlagMaskControl | kCGEventFlagMaskSecondaryFn;
        CGEventSetFlags(down, flags);
        CGEventSetFlags(up, flags);
        CGEventPost(kCGHIDEventTap, down);
        CGEventPost(kCGHIDEventTap, up);
    }
    if (down) CFRelease(down);
    if (up) CFRelease(up);
    CFRelease(source);
    return created;
}
