#define IVAR__VAR_NAME(cls,ivar) cls##_##ivar##_offset

#define IVAR_DECL(type,cls,ivar) \
    static ptrdiff_t IVAR__VAR_NAME(cls,ivar); \
    static inline type cls##_##ivar##_get(id instance) { \
        return *(type*)((char*)instance + IVAR__VAR_NAME(cls,ivar)); \
    } \
    static inline void cls##_##ivar##_set(id instance, type value) { \
        *(type*)((char*)instance + IVAR__VAR_NAME(cls,ivar)) = value; \
    }

#define IVAR_DEFN(cls,ivar) do { { \
    IVAR__VAR_NAME(cls,ivar) = \
        ivar_getOffset(class_getInstanceVariable(objc_getClass(#cls), #ivar)); \
    fprintf(stderr, "%s::%s at offset: %d\n", #cls, #ivar, (int)IVAR__VAR_NAME(cls,ivar)); \
} } while(0)

void
twitter_plus_patch(const char* klass, const char* mid);
