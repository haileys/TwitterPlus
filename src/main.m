#include <stdio.h>
#include <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "hackery.h"

IVAR_DECL(NSAttributedString*, ABUITextRenderer, attributedString);
IVAR_DECL(id, TMTimelineStatusCell, _fullNameRenderer);
IVAR_DECL(id, TMTimelineStatusCell, _usernameRenderer);

static void
swap_handle_and_full_name(id timeline_status_cell)
{
    id fullNameRenderer = TMTimelineStatusCell__fullNameRenderer_get(timeline_status_cell);
    id usernameRenderer = TMTimelineStatusCell__usernameRenderer_get(timeline_status_cell);

    NSAttributedString* fullNameRendererStr = ABUITextRenderer_attributedString_get(fullNameRenderer);
    NSAttributedString* usernameRendererStr = ABUITextRenderer_attributedString_get(usernameRenderer);

    // sketchy way to check if we've already swapped the full name and username
    // yes, this will break if someone's full name starts with a '@'.
    // patches welcome.
    if([[fullNameRendererStr string] UTF8String][0] == '@') {
        return;
    }

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

@interface TwitterPlus_TMTimelineStatusCell : NSObject
- (void)original_prepareForDisplay;
- (BOOL)original_drawAsSpecial;
@end

@implementation TwitterPlus_TMTimelineStatusCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];
    swap_handle_and_full_name(self);
}

- (BOOL)drawAsSpecial
{
    swap_handle_and_full_name(self);
    return [self original_drawAsSpecial];
}
@end

__attribute__((constructor)) void
flint_plus_main()
{
    IVAR_DEFN(ABUITextRenderer, attributedString);
    IVAR_DEFN(TMTimelineStatusCell, _fullNameRenderer);
    IVAR_DEFN(TMTimelineStatusCell, _usernameRenderer);

    twitter_plus_patch("TMTimelineStatusCell", "prepareForDisplay");
    twitter_plus_patch("TMTimelineStatusCell", "drawAsSpecial");

    fprintf(stderr, "TwitterPlus loaded!\n");
}
