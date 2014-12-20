#include <stdio.h>
#include <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "hackery.hh"

IVAR_DECL(NSAttributedString*, ABUITextRenderer, attributedString);
IVAR_DECL(id, TMTimelineStatusCell, _fullNameRenderer);
IVAR_DECL(id, TMTimelineStatusCell, _usernameRenderer);
IVAR_DECL(id, TMDetailedStatusCell, _fullNameRenderer);
IVAR_DECL(id, TMDetailedStatusCell, _usernameRenderer);
IVAR_DECL(id, TMUserCell, _fullNameRenderer);
IVAR_DECL(id, TMUserCell, _usernameRenderer);

static void
swap_full_name_and_username_renderers(id fullNameRenderer, id usernameRenderer)
{
    NSAttributedString* fullNameRendererStr = ABUITextRenderer_attributedString.get(fullNameRenderer);
    NSAttributedString* usernameRendererStr = ABUITextRenderer_attributedString.get(usernameRenderer);

    // sketchy way to check if we've already swapped the full name and username
    // yes, this will break if someone's full name starts with a '@'.
    // patches welcome.
    if([[fullNameRendererStr string] UTF8String][0] == '@') {
        return;
    }

    NSDictionary* fullNameRendererStrAttributes = [fullNameRendererStr attributesAtIndex:0 effectiveRange:NULL];
    NSDictionary* usernameRendererStrAttributes = [usernameRendererStr attributesAtIndex:0 effectiveRange:NULL];

    ABUITextRenderer_attributedString.set(usernameRenderer,
        [[NSAttributedString alloc] initWithString:[fullNameRendererStr string]
                                    attributes:usernameRendererStrAttributes]);

    ABUITextRenderer_attributedString.set(fullNameRenderer,
        [[NSAttributedString alloc] initWithString:[usernameRendererStr string]
                                    attributes:fullNameRendererStrAttributes]);

    [fullNameRendererStrAttributes release];
    [usernameRendererStrAttributes release];
}

static void
swap_timeline_status_full_name_and_username(id timeline_status_cell)
{
    id fullNameRenderer = TMTimelineStatusCell__fullNameRenderer.get(timeline_status_cell);
    id usernameRenderer = TMTimelineStatusCell__usernameRenderer.get(timeline_status_cell);
    swap_full_name_and_username_renderers(fullNameRenderer, usernameRenderer);
}

static void
swap_detailed_status_full_name_and_username(id detailed_status_cell)
{
    id fullNameRenderer = TMDetailedStatusCell__fullNameRenderer.get(detailed_status_cell);
    id usernameRenderer = TMDetailedStatusCell__usernameRenderer.get(detailed_status_cell);
    swap_full_name_and_username_renderers(fullNameRenderer, usernameRenderer);
}

static void
swap_user_full_name_and_username(id user_cell)
{
    id fullNameRenderer = TMUserCell__fullNameRenderer.get(user_cell);
    id usernameRenderer = TMUserCell__usernameRenderer.get(user_cell);
    swap_full_name_and_username_renderers(fullNameRenderer, usernameRenderer);
}

@interface TwitterPlus_TMTimelineStatusCell : NSObject
- (void)original_prepareForDisplay;
- (BOOL)original_drawAsSpecial;
@end

@implementation TwitterPlus_TMTimelineStatusCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];
    swap_timeline_status_full_name_and_username(self);
}

- (BOOL)drawAsSpecial
{
    swap_timeline_status_full_name_and_username(self);
    return [self original_drawAsSpecial];
}
@end

@interface TwitterPlus_TMDetailedStatusCell : NSObject
- (void)original_prepareForDisplay;
- (BOOL)original_drawAsSpecial;
@end

@implementation TwitterPlus_TMDetailedStatusCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];
    swap_detailed_status_full_name_and_username(self);
}

- (BOOL)drawAsSpecial
{
    swap_detailed_status_full_name_and_username(self);
    return [self original_drawAsSpecial];
}
@end

@interface TwitterPlus_TMUserCell : NSObject
- (void)original_prepareForDisplay;
- (BOOL)original_drawAsSpecial;
@end

@implementation TwitterPlus_TMUserCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];
    swap_user_full_name_and_username(self);
}

- (BOOL)drawAsSpecial
{
    swap_user_full_name_and_username(self);
    return [self original_drawAsSpecial];
}
@end

__attribute__((constructor)) void
flint_plus_main()
{
    twitter_plus_patch("TMTimelineStatusCell", "prepareForDisplay");
    twitter_plus_patch("TMTimelineStatusCell", "drawAsSpecial");

    twitter_plus_patch("TMDetailedStatusCell", "prepareForDisplay");
    twitter_plus_patch("TMDetailedStatusCell", "drawAsSpecial");

    twitter_plus_patch("TMUserCell", "prepareForDisplay");
    twitter_plus_patch("TMUserCell", "drawAsSpecial");
    fprintf(stderr, "TwitterPlus loaded!\n");
}
