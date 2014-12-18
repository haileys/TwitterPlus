#define IVAR__VAR_NAME(cls,ivar) cls##_##ivar##_offset

#define IVAR_DECL(cls,ivar) \
    static ptrdiff_t IVAR__VAR_NAME(cls,ivar)

#define IVAR_DEFN(cls,ivar) do { { \
    IVAR__VAR_NAME(cls,ivar) = \
        ivar_getOffset(class_getInstanceVariable(objc_getClass(#cls), #ivar)); \
    fprintf(stderr, "%s::%s at offset: %d\n", #cls, #ivar, (int)IVAR__VAR_NAME(cls,ivar)); \
} } while(0)

#define IVAR(cls,ivar,instance) \
    *(void**)((char*)instance + IVAR__VAR_NAME(cls,ivar))

void
twitter_plus_patch(const char* klass, const char* mid);
