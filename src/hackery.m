#include <objc/runtime.h>
#include <stdlib.h>
#include <string.h>

#import "hackery.h"

void
twitter_plus_patch(const char* klass_name, const char* mid)
{
    char patch_klass_name[strlen(klass_name) + 20];
    strcpy(patch_klass_name, "TwitterPlus_");
    strcat(patch_klass_name, klass_name);

    Class patch_klass = objc_getClass(patch_klass_name);
    Class target_klass = objc_getClass(klass_name);

    char original_mid[strlen(mid) + 20];
    strcpy(original_mid, "original_");
    strcat(original_mid, mid);

    SEL mid_sel = sel_registerName(mid);
    SEL original_mid_sel = sel_registerName(original_mid);

    Method target_method = class_getInstanceMethod(target_klass, mid_sel);
    Method patch_method = class_getInstanceMethod(patch_klass, mid_sel);

    class_addMethod(target_klass, original_mid_sel,
        method_getImplementation(target_method),
        method_getTypeEncoding(target_method));

    class_replaceMethod(target_klass, mid_sel,
        method_getImplementation(patch_method),
        method_getTypeEncoding(patch_method));
}
