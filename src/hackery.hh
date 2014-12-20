#include <cstdlib>
#include <cstdio>

template<typename T>
class ivar {
    int offset;
public:
    ivar(const char* className, const char* ivarName) {
        offset = ivar_getOffset(class_getInstanceVariable(objc_getClass(className), ivarName));

        if(offset == 0) {
            fprintf(stderr, "couldn't find offset for ivar: %s::%s\n", className, ivarName);
            abort();
        }
    }

    T* ptr(id instance) {
        return (T*)((intptr_t)instance + offset);
    }

    T get(id instance) {
        return *ptr(instance);
    }

    void set(id instance, T val) {
        *ptr(instance) = val;
    }
};

#define IVAR_DECL(type,cls,name) \
    static ivar<type> cls##_##name = ivar<type>(#cls, #name)

void
twitter_plus_patch(const char* klass, const char* mid);
