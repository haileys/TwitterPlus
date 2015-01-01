#include <stdio.h>
#include <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "hackery.hh"

IVAR_DECL(NSAttributedString*, ABUITextRenderer, attributedString);
IVAR_DECL(id, TMTimelineStatusCell, _fullNameRenderer);
IVAR_DECL(id, TMTimelineStatusCell, _usernameRenderer);
IVAR_DECL(id, TMTimelineStatusCell, _metaRenderer);
IVAR_DECL(id, TMDetailedStatusCell, _fullNameRenderer);
IVAR_DECL(id, TMDetailedStatusCell, _usernameRenderer);
IVAR_DECL(id, TMDetailedStatusCell, _metaTextRenderer);
IVAR_DECL(id, TMUserCell, _fullNameRenderer);
IVAR_DECL(id, TMUserCell, _usernameRenderer);
IVAR_DECL(id, TwitterStatus, _fromUser);
IVAR_DECL(id, TwitterStatus, _retweetedStatus);
IVAR_DECL(id, TwitterUser, _username);

static void
swap_full_name_and_username_renderers(id fullNameRenderer, id usernameRenderer)
{
    NSAttributedString* fullNameRendererStr = ABUITextRenderer_attributedString.get(fullNameRenderer);
    NSAttributedString* usernameRendererStr = ABUITextRenderer_attributedString.get(usernameRenderer);

    // sketchy way to check if we've already swapped the full name and username
    // yes, this will break if someone's full name starts with a '@'.
    // patches welcome.
    if([[fullNameRendererStr string] hasPrefix:@"@"]) {
        return;
    }

    // some users have an empty full name. In this case fullNameRendererStr
    // doesn't actually have any attributes so we can't simply swap in the
    // username with the existing attributes. Just return for now so we at
    // least don't crash the entire app.
    if([fullNameRendererStr length] == 0) {
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
put_username_in_retweet_attribution(id metaRenderer, id status)
{
    if(!TwitterStatus__retweetedStatus.get(status)) {
        return;
    }

    NSAttributedString* metaRendererStr = ABUITextRenderer_attributedString.get(metaRenderer);

    NSDictionary* metaRendererStrAttributes = [metaRendererStr attributesAtIndex:0 effectiveRange:NULL];

    NSString* username = TwitterUser__username.get(TwitterStatus__fromUser.get(status));

    NSString* retweetAttributionLabel = [NSString stringWithFormat:@"@%@ retweeted", username];

    ABUITextRenderer_attributedString.set(metaRenderer,
        [[NSAttributedString alloc] initWithString:retweetAttributionLabel
                                    attributes:metaRendererStrAttributes]);
}

static void
act_on_timeline_status_cell(id timeline_status_cell)
{
    id fullNameRenderer = TMTimelineStatusCell__fullNameRenderer.get(timeline_status_cell);
    id usernameRenderer = TMTimelineStatusCell__usernameRenderer.get(timeline_status_cell);
    swap_full_name_and_username_renderers(fullNameRenderer, usernameRenderer);

    id metaRenderer = TMTimelineStatusCell__metaRenderer.get(timeline_status_cell);
    put_username_in_retweet_attribution(metaRenderer, (id)[timeline_status_cell status]);
}

static void
act_on_detailed_status_cell(id detailed_status_cell)
{
    id fullNameRenderer = TMDetailedStatusCell__fullNameRenderer.get(detailed_status_cell);
    id usernameRenderer = TMDetailedStatusCell__usernameRenderer.get(detailed_status_cell);
    swap_full_name_and_username_renderers(fullNameRenderer, usernameRenderer);

    id metaRenderer = TMDetailedStatusCell__metaTextRenderer.get(detailed_status_cell);
    put_username_in_retweet_attribution(metaRenderer, (id)[detailed_status_cell status]);
}

static void
act_on_user_cell(id user_cell)
{
    id fullNameRenderer = TMUserCell__fullNameRenderer.get(user_cell);
    id usernameRenderer = TMUserCell__usernameRenderer.get(user_cell);
    swap_full_name_and_username_renderers(fullNameRenderer, usernameRenderer);
}

@interface TwitterPlus_TMTimelineStatusCell : NSObject
- (void)original_prepareForDisplay;
- (BOOL)original_drawAsSpecial;
- (BOOL)original_drawWithHighlight;
@end

@implementation TwitterPlus_TMTimelineStatusCell
- (void)prepareForDisplay
{
    [self original_prepareForDisplay];
    act_on_timeline_status_cell(self);
}

- (BOOL)drawAsSpecial
{
    act_on_timeline_status_cell(self);
    return [self original_drawAsSpecial];
}

- (BOOL)drawWithHighlight
{
    act_on_timeline_status_cell(self);
    return [self original_drawWithHighlight];
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
    act_on_detailed_status_cell(self);
}

- (BOOL)drawAsSpecial
{
    act_on_detailed_status_cell(self);
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
    act_on_user_cell(self);
}

- (BOOL)drawAsSpecial
{
    act_on_user_cell(self);
    return [self original_drawAsSpecial];
}
@end

__attribute__((constructor)) void
twitter_plus_main()
{
    twitter_plus_patch("TMTimelineStatusCell", "prepareForDisplay");
    twitter_plus_patch("TMTimelineStatusCell", "drawAsSpecial");
    twitter_plus_patch("TMTimelineStatusCell", "drawWithHighlight");

    twitter_plus_patch("TMDetailedStatusCell", "prepareForDisplay");
    twitter_plus_patch("TMDetailedStatusCell", "drawAsSpecial");

    twitter_plus_patch("TMUserCell", "prepareForDisplay");
    twitter_plus_patch("TMUserCell", "drawAsSpecial");
    fprintf(stderr, "TwitterPlus loaded!\n");
}
