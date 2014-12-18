#include <stdio.h>
#include <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "hackery.h"

IVAR_DECL(ABUITextRenderer, attributedString);
IVAR_DECL(TMTimelineStatusCell, _fullNameRenderer);
IVAR_DECL(TMTimelineStatusCell, _usernameRenderer);

@interface TwitterPlus_TMTimelineStatusCell : NSObject
- (void)original_prepareForDisplay;
@end

@implementation TwitterPlus_TMTimelineStatusCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];

    void* fullNameRenderer = IVAR(TMTimelineStatusCell, _fullNameRenderer, self);
    void* usernameRenderer = IVAR(TMTimelineStatusCell, _usernameRenderer, self);

    NSAttributedString* fullNameRendererStr = IVAR(ABUITextRenderer, attributedString, fullNameRenderer);
    NSAttributedString* usernameRendererStr = IVAR(ABUITextRenderer, attributedString, usernameRenderer);

    NSDictionary* fullNameRendererStrAttributes = [fullNameRendererStr attributesAtIndex:0 effectiveRange:NULL];
    NSDictionary* usernameRendererStrAttributes = [usernameRendererStr attributesAtIndex:0 effectiveRange:NULL];

    IVAR(ABUITextRenderer, attributedString, usernameRenderer) =
        [[NSAttributedString alloc] initWithString:[fullNameRendererStr string]
                                    attributes:usernameRendererStrAttributes];

    IVAR(ABUITextRenderer, attributedString, fullNameRenderer) =
        [[NSAttributedString alloc] initWithString:[usernameRendererStr string]
                                    attributes:fullNameRendererStrAttributes];

    [fullNameRendererStrAttributes release];
    [usernameRendererStrAttributes release];
}
@end

static void
twitter_plus_init()
{
    IVAR_DEFN(ABUITextRenderer, attributedString);
    IVAR_DEFN(TMTimelineStatusCell, _fullNameRenderer);
    IVAR_DEFN(TMTimelineStatusCell, _usernameRenderer);

    twitter_plus_patch("TMTimelineStatusCell", "prepareForDisplay");

    fprintf(stderr, "TwitterPlus loaded!\n");

    // exit(0);
}

static sig_t old_sigalrm;

static void
sigalrm()
{
    signal(SIGALRM, old_sigalrm);
    twitter_plus_init();
}

__attribute__((constructor)) void
flint_plus_main()
{
    old_sigalrm = signal(SIGALRM, sigalrm);
    alarm(1);
}
