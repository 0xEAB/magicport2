
// c library

public import core.stdc.stdarg : va_list, va_start, va_end;
public import core.stdc.stdio : printf, sprintf, fprintf, vprintf, vfprintf, fputs, fwrite, _vsnprintf, putchar, remove, _snprintf, fflush, stdout, stderr;
public import core.stdc.stdlib : malloc, free, alloca, exit, EXIT_FAILURE, EXIT_SUCCESS, strtol, strtoull, getenv, calloc;
public import core.stdc.ctype : isspace, isdigit, isalnum, isprint, isalpha, isxdigit, islower, tolower;
public import core.stdc.errno : errno, EEXIST, ERANGE;
public import core.stdc.limits : INT_MAX;
public import core.stdc.math : sinl, cosl, tanl, sqrtl, fabsl;
public import core.stdc.time : time_t, ctime, time;
public import core.stdc.stdint : int64_t, uint64_t, int32_t, uint32_t, int16_t, uint16_t, int8_t, uint8_t;
public import core.stdc.float_;

private import core.stdc.string : strcmp, strlen, strncmp, strchr, memset, memmove, strdup, strcpy, strcat, xmemcmp = memcmp, xmemcpy = memcpy;

public import core.sys.windows.windows;

// generated source

import dmd;

// win32

alias GetModuleFileNameA GetModuleFileName;
alias CreateFileA CreateFile;
alias CreateFileMappingA CreateFileMapping;
alias WIN32_FIND_DATA WIN32_FIND_DATAA;
extern(Windows) DWORD GetFullPathNameA(LPCTSTR lpFileName, DWORD nBufferLength, LPTSTR lpBuffer, LPTSTR *lpFilePart);
alias GetFullPathNameA GetFullPathName;

// c lib

// So we can accept string literals
int memcmp(const char* a, const char* b, size_t len) { return .xmemcmp(a, b, len); }
int memcmp(const void* a, const void* b, size_t len) { return .xmemcmp(a, b, len); }
int memcmp(void* a, void* b, size_t len) { return .xmemcmp(a, b, len); }

// Not defined for some reason
extern(C) int stricmp(const char*, const char*);
extern(C) int putenv(const char*);
extern(C) int spawnlp(int, const char*, const char*, const char*, const char*);
extern(C) int spawnl(int, const char*, const char*, const char*, const char*);
extern(C) int spawnv(int, const char*, const char**);
extern(C) int mkdir(const char*);
alias mkdir _mkdir;
private extern(C) int memicmp(const char*, const char*, size_t);
private extern(C) char* strupr(const char*);

extern extern(C) uint _xi_a;
extern extern(C) uint _end;

// root.Object

class RootObject
{
    extern(C++) int dyncast() { assert(0); }
    extern(C++) bool equals(RootObject) { assert(0); }
    extern(C++) int compare(RootObject) { assert(0); }
    extern(C++) char *toChars() { assert(0); }
    extern(C++) void toBuffer(OutBuffer* buf) { assert(0); }
    extern(C++) void print()
    {
        printf("%s %p\n", toChars(), this);
    }
}

// root.Array

struct Array(U)
{
    static if (!is(U == class))
        alias U* T;
    else
        alias U T;

public:
    size_t dim;
    void** data;

private:
    size_t allocdim;

public:
    void push(size_t line = __LINE__)(T ptr)
    {
        static if (is(T == Dsymbol) && 0)
        {
            printf("from %d\n", line);
            printf("pushing 0x%.8X\n", ptr);
            printf("%s\n", ptr.kind());
            if (ptr.ident)
            {
                printf("ident 0x%.8X\n", ptr.ident);
                printf("ident %.*s\n", ptr.ident.len, ptr.ident.toChars());
            }
        }
        reserve(1);
        data[dim++] = cast(void*)ptr;
    }
    void append(typeof(this)* a)
    {
        insert(dim, a);
    }
    void reserve(size_t nentries)
    {
        //printf("Array::reserve: dim = %d, allocdim = %d, nentries = %d\n", (int)dim, (int)allocdim, (int)nentries);
        if (allocdim - dim < nentries)
        {
            if (allocdim == 0)
            {   // Not properly initialized, someone memset it to zero
                allocdim = nentries;
                data = cast(void **)mem.malloc(allocdim * (*data).sizeof);
            }
            else
            {   allocdim = dim + nentries;
                data = cast(void **)mem.realloc(data, allocdim * (*data).sizeof);
            }
        }
    }
    void remove(size_t i)
    {
        if (dim - i - 1)
            memmove(data + i, data + i + 1, (dim - i - 1) * (data[0]).sizeof);
        dim--;
    }
    void insert(size_t index, typeof(this)* a)
    {
        if (a)
        {
            size_t d = a.dim;
            reserve(d);
            if (dim != index)
                memmove(data + index + d, data + index, (dim - index) * (*data).sizeof);
            xmemcpy(data + index, a.data, d * (*data).sizeof);
            dim += d;
        }
    }
    void insert(size_t index, T ptr)
    {
        reserve(1);
        memmove(data + index + 1, data + index, (dim - index) * (*data).sizeof);
        data[index] = cast(void*)ptr;
        dim++;
    }
    void setDim(size_t newdim)
    {
        if (dim < newdim)
        {
            reserve(newdim - dim);
        }
        dim = newdim;
    }
    ref T opIndex(size_t i)
    {
        return tdata()[i];
    }
    T* tdata()
    {
        return cast(T*)data;
    }
    typeof(this)* copy()
    {
        auto a = new typeof(this)();
        a.setDim(dim);
        xmemcpy(a.data, data, dim * (void *).sizeof);
        return a;
    }
    void shift(T ptr)
    {
        reserve(1);
        memmove(data + 1, data, dim * (*data).sizeof);
        data[0] = cast(void*)ptr;
        dim++;
    }
    void zero()
    {
        memset(data,0,dim * (data[0]).sizeof);
    }
    void pop() { assert(0); }
    extern(C++) int apply(int function(T, void*) fp, void* param)
    {
        static if (is(typeof(T.init.apply(fp, null))))
        {
            for (size_t i = 0; i < dim; i++)
            {   T e = tdata()[i];

                if (e)
                {
                    if (e.apply(fp, param))
                        return 1;
                }
            }
            return 0;
        }
        else
            assert(0);
    }
};

// root.rmem

struct Mem
{
    import core.memory;
extern(C++):
    char* strdup(const char *p)
    {
        return p[0..strlen(p)+1].dup.ptr;
    }
    void free(void *p) {}
    void mark(void *pointer) {}
    void* malloc(size_t n) { return GC.malloc(n); }
    void* calloc(size_t size, size_t n) { return GC.calloc(size, n); }
    void* realloc(void *p, size_t size) { return GC.realloc(p, size); }
    void _init() {}
    void setStackBottom(void *bottom) {}
    void addroots(char* pStart, char* pEnd) {}
}
extern(C++) Mem mem;

// root.response

int response_expand(size_t*, const(char)***)
{
    return 0;
}

// root.man

void browse(const char*) { assert(0); }

// root.port

__gshared extern(C) const(char)* __locale_decpoint;

extern(C) float strtof(const(char)* p, char** endp);
extern(C) double strtod(const(char)* p, char** endp);
extern(C) real strtold(const(char)* p, char** endp);

struct Port
{
    enum nan = double.nan;
    enum infinity = double.infinity;
    enum ldbl_max = real.max;
    enum ldbl_nan = real.nan;
    enum ldbl_infinity = real.infinity;
extern(C++):
    static real snan;
    static this()
    {
        /*
         * Use a payload which is different from the machine NaN,
         * so that uninitialised variables can be
         * detected even if exceptions are disabled.
         */
        ushort* us = cast(ushort *)&snan;
        us[0] = 0;
        us[1] = 0;
        us[2] = 0;
        us[3] = 0xA000;
        us[4] = 0x7FFF;

        /*
         * Although long doubles are 10 bytes long, some
         * C ABIs pad them out to 12 or even 16 bytes, so
         * leave enough space in the snan array.
         */
        assert(Target.realsize <= snan.sizeof);
    }
    static bool isNan(double r) { return !(r == r); }
    static real fmodl(real a, real b) { return a % b; }
    static int memicmp(const char* s1, const char* s2, size_t n) { return .memicmp(s1, s2, n); }
    static char* strupr(const char* s) { return .strupr(s); }
    static int isSignallingNan(double r) { return isNan(r) && !(((cast(ubyte*)&r)[6]) & 8); }
    static int isSignallingNan(real r) { return isNan(r) && !(((cast(ubyte*)&r)[7]) & 0x40); }
    static int isInfinity(double r) { return r is double.infinity || r is -double.infinity; }
    static float strtof(const(char)* p, char** endp)
    {
        auto save = __locale_decpoint;
        __locale_decpoint = ".";
        auto r = .strtof(p, endp);
        __locale_decpoint = save;
        return r;
    }
    static double strtod(const(char)* p, char** endp)
    {
        auto save = __locale_decpoint;
        __locale_decpoint = ".";
        auto r = .strtod(p, endp);
        __locale_decpoint = save;
        return r;
    }
    static real strtold(const(char)* p, char** endp)
    {
        auto save = __locale_decpoint;
        __locale_decpoint = ".";
        auto r = .strtold(p, endp);
        __locale_decpoint = save;
        return r;
    }
}

// IntRange

struct SignExtendedNumber
{
    ulong value;
    bool negative;
    static SignExtendedNumber fromInteger(uinteger_t value)
    {
        assert(0);
    }
    static SignExtendedNumber extreme(bool minimum)
    {
        assert(0);
    }
    static SignExtendedNumber max()
    {
        assert(0);
    }
    static SignExtendedNumber min()
    {
        return SignExtendedNumber(0, true);
    }
    bool isMinimum() const
    {
        return negative && value == 0;
    }
    bool opEquals(const ref SignExtendedNumber a) const
    {
        assert(0);
    }
    int opCmp(const ref SignExtendedNumber a) const
    {
        if (negative != a.negative)
        {
            if (negative)
                return -1;
            else
                return 1;
        }
        if (value < a.value)
            return -1;
        else if (value > a.value)
            return 1;
        else
            return 0;
    }
    SignExtendedNumber opNeg() const
    {
        assert(0);
    }
    SignExtendedNumber opAdd(const ref SignExtendedNumber a) const
    {
        assert(0);
    }
    SignExtendedNumber opSub(const ref SignExtendedNumber a) const
    {
        assert(0);
    }
    SignExtendedNumber opMul(const ref SignExtendedNumber a) const
    {
        assert(0);
    }
    SignExtendedNumber opDiv(const ref SignExtendedNumber a) const
    {
        assert(0);
    }
    SignExtendedNumber opMod(const ref SignExtendedNumber a) const
    {
        assert(0);
    }
    ref SignExtendedNumber opAddAssign(int a)
    {
        assert(0);
    }
    SignExtendedNumber opShl(const ref SignExtendedNumber a)
    {
        assert(0);
    }
    SignExtendedNumber opShr(const ref SignExtendedNumber a)
    {
        assert(0);
    }
}

struct IntRange
{
    SignExtendedNumber imin, imax;

    this(dinteger_t)
    {
        assert(0);
    }
    this(const ref SignExtendedNumber a)
    {
        imin = a;
        imax = a;
    }
    this(SignExtendedNumber lower, SignExtendedNumber upper)
    {
        imin = lower;
        imax = lower;
    }

    static IntRange fromType(Type type)
    {
        return fromType(type, type.isunsigned());
    }
    static IntRange fromType(Type type, bool isUnsigned)
    {
        if (!type.isintegral())
            return widest();

        uinteger_t mask = type.sizemask();
        auto lower = SignExtendedNumber(0);
        auto upper = SignExtendedNumber(mask);
        if (type.toBasetype().ty == Tdchar)
            upper.value = 0x10FFFFUL;
        else if (!isUnsigned)
        {
            lower.value = ~(mask >> 1);
            lower.negative = true;
            upper.value = (mask >> 1);
        }
        return IntRange(lower, upper);
    }
    static IntRange fromNumbers4(SignExtendedNumber* numbers)
    {
        assert(0);
    }
    static IntRange widest()
    {
        assert(0);
    }
    IntRange castSigned(uinteger_t mask)
    {
        assert(0);
    }
    IntRange castUnsigned(uinteger_t mask)
    {
        assert(0);
    }
    IntRange castDchar()
    {
        assert(0);
    }
    IntRange _cast(Type type)
    {
        assert(0);
    }
    IntRange castUnsigned(Type type)
    {
        assert(0);
    }
    bool contains(const ref IntRange a)
    {
        return imin <= a.imin && imax >= a.imax;
    }
    bool containsZero() const
    {
        assert(0);
    }
    IntRange absNeg() const
    {
        assert(0);
    }
    IntRange unionWidth(const ref IntRange other) const
    {
        assert(0);
    }
    IntRange unionOrAssign(IntRange other, ref bool union_)
    {
        assert(0);
    }
    ref const(IntRange) dump(const(char)* funcName, Expression e) const
    {
        assert(0);
    }
    IntRange splitBySign(ref IntRange negRange, ref bool hasNegRange, ref IntRange nonNegRange, ref bool hasNonNegRange) const
    {
        assert(0);
    }
}

// complex_t

real creall(creal x) { return x.re; }
real cimagl(creal x) { return x.im; }

// longdouble.h

real ldouble(T)(T x) { return cast(real)x; }

size_t ld_sprint(char* str, int fmt, real x)
{
    tracein("ld_sprint");
    scope(success) traceout("ld_sprint");
    scope(failure) traceerr("ld_sprint");

    if ((cast(real)cast(ulong)x) == x)
    {   // ((1.5 -> 1 -> 1.0) == 1.5) is false
        // ((1.0 -> 1 -> 1.0) == 1.0) is true
        // see http://en.cppreference.com/w/cpp/io/c/fprintf
        char sfmt[5] = "%#Lg\0";
        sfmt[3] = fmt;
        return sprintf(str, sfmt, x);
    }
    else
    {
        char sfmt[4] = "%Lg\0";
        sfmt[2] = fmt;
        return sprintf(str, sfmt, x);
    }
}

// Backend

struct Symbol;
struct TYPE;
struct elem;
struct code;
struct block;
struct dt_t;
struct IRState;

extern extern(C++) void backend_init();
extern extern(C++) void backend_term();
extern extern(C++) void obj_start(char *srcfile);
extern extern(C++) void obj_end(Library library, File* objfile);
extern extern(C++) void obj_write_deferred(Library library);
extern extern(C++) Expression createTypeInfoArray(Scope* sc, Expression *args, size_t dim);

// Util

int binary(char *, const(char)**, size_t) { assert(0); }

struct AA;
RootObject _aaGetRvalue(AA* aa, RootObject o)
{
    tracein("_aaGetRvalue");
    scope(success) traceout("_aaGetRvalue");
    scope(failure) traceerr("_aaGetRvalue");
    auto x = *cast(RootObject[void*]*)&aa;
    auto k = cast(void*)o;
    if (auto p = k in x)
        return *p;
    return null;
}
RootObject* _aaGet(AA** aa, RootObject o)
{
    tracein("_aaGet");
    scope(success) traceout("_aaGet");
    scope(failure) traceerr("_aaGet");
    auto x = *cast(RootObject[void*]**)&aa;
    auto k = cast(void*)o;
    if (auto p = k in *x)
        return p;
    else
        (*x)[k] = null;
    return k in *x;
}

// root.speller

extern(C++) void* speller(const char*, void* function(void*, const(char)*), Scope*, const char*) { return null; }
extern(C++) void* speller(const char*, void* function(void*, const(char)*), Dsymbol, const char*) { return null; }

const(char)* idchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";

// root.stringtable

struct StringValue
{
    void *ptrvalue;

private:
    const(char)[] value;

public:
    size_t len() const { return value.length; }
    const(char)* toDchars() const { return value.ptr; }
};

struct StringTable
{
private:
    StringValue*[const(char)[]] table;

public:
    extern(C++) void _init(size_t size = 37)
    {
    }
    ~this()
    {
        table = null;
    }

    extern(C++) StringValue *lookup(const(char)* s, size_t len)
    {
        auto p = s[0..len] in table;
        if (p)
            return *p;
        return null;
    }
    extern(C++) StringValue *insert(const(char)* s, size_t len)
    {
        auto key = s[0..len];
        auto p = key in table;
        if (p)
            return null;
        key = key ~ '\0';
        return (table[key[0..$-1]] = new StringValue(null, key));
    }
    extern(C++) StringValue *update(const(char)* s, size_t len)
    {
        //printf("StringTable::update %d %.*s\n", len, len, s);
        auto key = s[0..len];
        auto p = key in table;
        if (p)
            return *p;
        key = key ~ '\0';
        return (table[key[0..$-1]] = new StringValue(null, key));
    }
};

// root.outbuffer

struct OutBuffer
{
    ubyte* data;
    size_t offset;
    size_t size;

    int doindent;
    int level;
    int notlinehead;
extern(C++):
    char *extractData();
    void mark();

    void reserve(size_t nbytes);
    void setsize(size_t size);
    void reset();
    void write(const(void)* data, size_t nbytes);
    void writebstring(ubyte* string);
    void writestring(const(char)* string);
    void prependstring(const(char)* string);
    void writenl();                     // write newline
    void writeByte(uint b);
    void writebyte(uint b) { writeByte(b); }
    void writeUTF8(uint b);
    void prependbyte(uint b);
    void writewchar(uint w);
    void writeword(uint w);
    void writeUTF16(uint w);
    void write4(uint w);
    void write(OutBuffer *buf);
    void write(RootObject obj);
    void fill0(size_t nbytes);
    void _align(size_t size);
    void vprintf(const(char)* format, va_list args) { vprintf(format, cast(char*)args); }
    void vprintf(const(char)* format, char* args);
    void printf(const(char)* format, ...);
    void bracket(char left, char right);
    size_t bracket(size_t i, const(char)* left, size_t j, const(char)* right);
    void spread(size_t offset, size_t nbytes);
    size_t insert(size_t offset, const(void)* data, size_t nbytes);
    size_t insert(size_t offset, const(char)* data, size_t nbytes);
    void remove(size_t offset, size_t nbytes);
    char* toChars();
    char* extractString();
};

// hacks to support cloning classed with memcpy

import typenames : typeTypes, expTypes;

void* memcpy()(void* dest, const void* src, size_t size) { return xmemcpy(dest, src, size); }
Type memcpy(T : Type)(ref T dest, T src, size_t size)
{
    dest = cast(T)src.clone();;
    assert(dest);
    assert(typeid(dest) == typeid(src));
    switch(typeid(src).toString())
    {
        foreach(s; typeTypes.expand)
        {
            case "dmd." ~ s:
                mixin("copyMembers!(" ~ s ~ ")(cast(" ~ s ~ ")dest, cast(" ~ s ~ ")src);");
                return dest;
        }
    default:
        assert(0, "Cannot copy type " ~ typeid(src).toString());
    }
    return dest;
}
T memcpy(T : Parameter)(ref T dest, T src, size_t size)
{
    dest = new Parameter(src.storageClass, src.type, src.ident, src.defaultArg);
    return dest;
}
Expression memcpy(T : Expression)(ref T dest, T src, size_t size)
{
    dest = cast(T)src.clone();;
    assert(dest);
    assert(typeid(dest) == typeid(src), typeid(src).toString());
    switch(typeid(src).toString())
    {
        foreach(s; expTypes.expand)
        {
            case "dmd." ~ s:
                mixin("copyMembers!(" ~ s ~ ")(cast(" ~ s ~ ")dest, cast(" ~ s ~ ")src);");
                return dest;
        }
    default:
        assert(0, "Cannot copy expression " ~ typeid(src).toString());
    }
    return dest;
}
void* memcpy(T : VarDeclaration)(ref T dest, T src, size_t size) { assert(0); }

void copyMembers(T : Type)(T dest, T src)
{
    static if (!is(T == RootObject))
    {
        foreach(i, v; dest.tupleof)
            dest.tupleof[i] = src.tupleof[i];
        static if (!is(T == Type) && is(T U == super))
            copyMembers!(U)(dest, src);
   }
}
void copyMembers(T : Expression)(T dest, T src)
{
    static if (!is(T == RootObject))
    {
        foreach(i, v; dest.tupleof)
            dest.tupleof[i] = src.tupleof[i];
        static if (!is(T == Expression) && is(T U == super))
            copyMembers!(U)(dest, src);
   }
}
void copyMembers(T : RootObject)(T dest, T src)
{
}

void main(string[] args)
{
    scope(success) exit(0);
    scope(failure) tracedepth = -1;

    int argc = cast(int)args.length;
    auto argv = (new const(char)*[](argc)).ptr;
    foreach(i, a; args)
        argv[i] = (a ~ '\0').ptr;

    // try
    // {
        xmain(argc, argv);
    // }
    // catch (Error e)
    // {
        // printf("Error: %.*s\n", e.msg);
    // }
}

int tracedepth;

version=trace;
// version=fulltrace;

version(trace)
{
    void trace(string pretty = __PRETTY_FUNCTION__, size_t line = __LINE__)
    {
        printf("%.*s:%d\n", pretty.length, pretty.ptr, line);
    }
    void tracein(string pretty = __PRETTY_FUNCTION__, size_t line = __LINE__)
    {
        if (tracedepth < 0)
            return;
        version(fulltrace)
        {
            foreach(i; 0..tracedepth*2)
                putchar(' ');
            printf("+ %.*s:%d\n", pretty.length, pretty.ptr, line);
        }
        tracedepth++;
    }

    void traceout(string pretty = __PRETTY_FUNCTION__, size_t line = __LINE__)
    {
        if (tracedepth < 0)
            return;
        tracedepth--;
        version(fulltrace)
        {
            foreach(i; 0..tracedepth*2)
                putchar(' ');
            printf("+ %.*s:%d\n", pretty.length, pretty.ptr, line);
        }
    }

    void traceerr(string pretty = __PRETTY_FUNCTION__, size_t line = __LINE__)
    {
        if (tracedepth < 0)
            return;
        tracedepth--;
        foreach(i; 0..tracedepth*2)
            putchar(' ');
        printf("! %.*s:%d\n", pretty.length, pretty.ptr, line);
    }
}
else
{
    void trace() {}
    void tracein() {}
    void traceout() {}
    void traceerr() {}
}

// Preprocessor symbols (sometimes used as values)
enum DDMD = true;

enum linux = false;
enum __APPLE__ = false;
enum __FreeBSD__ = false;
enum __OpenBSD__ = false;
enum __sun = false;
enum MACINTOSH = false;
enum _WIN32 = true;

enum IN_GCC = false;
enum __DMC__ = true;
enum _MSC_VER = false;

enum LOG = false;
enum ASYNCREAD = false;
enum UNITTEST = false;
enum CANINLINE_LOG = false;
enum TEXTUAL_ASSEMBLY_OUT = false;
enum LOGSEMANTIC = false;

enum TARGET_LINUX = false;
enum TARGET_OSX = false;
enum TARGET_FREEBSD = false;
enum TARGET_OPENBSD = false;
enum TARGET_SOLARIS = false;
enum TARGET_WINDOS = true;
