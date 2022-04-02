#ifndef PC
//stream access macros
#define IO_SET(base, location, value) (*((volatile int*) ( (base) + (sizeof(int)) * (location) )) = (value) )
#define IO_GET(base, location)        (*((volatile int*) ( (base) + (sizeof(int)) * (location) )))
#endif

