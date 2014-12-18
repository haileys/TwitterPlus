#include <stdio.h>
#include <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "hackery.h"

IVAR_DECL(NSAttributedString*, ABUITextRenderer, attributedString);
IVAR_DECL(id, TMTimelineStatusCell, _fullNameRenderer);
IVAR_DECL(id, TMTimelineStatusCell, _usernameRenderer);

@interface TwitterPlus_TMTimelineStatusCell : NSObject
- (void)original_prepareForDisplay;
@end

@implementation TwitterPlus_TMTimelineStatusCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];

    id fullNameRenderer = TMTimelineStatusCell__fullNameRenderer_get(self);
    id usernameRenderer = TMTimelineStatusCell__usernameRenderer_get(self);

    NSAttributedString* fullNameRendererStr = ABUITextRenderer_attributedString_get(fullNameRenderer);
    NSAttributedString* usernameRendererStr = ABUITextRenderer_attributedString_get(usernameRenderer);

    NSDictionary* fullNameRendererStrAttributes = [fullNameRendererStr attributesAtIndex:0 effectiveRange:NULL];
    NSDictionary* usernameRendererStrAttributes = [usernameRendererStr attributesAtIndex:0 effectiveRange:NULL];

    ABUITextRenderer_attributedString_set(usernameRenderer,
        [[NSAttributedString alloc] initWithString:[fullNameRendererStr string]
                                    attributes:usernameRendererStrAttributes]);

    ABUITextRenderer_attributedString_set(fullNameRenderer,
        [[NSAttributedString alloc] initWithString:[usernameRendererStr string]
                                    attributes:fullNameRendererStrAttributes]);

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
