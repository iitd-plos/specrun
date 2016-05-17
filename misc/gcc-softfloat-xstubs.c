#define float32_add         __addsf3
#define float64_add         __adddf3
#define floatx80_add        __addxf3
#define float128_add        __addtf3

#define float32_sub         __subsf3
#define float64_sub         __subdf3
#define floatx80_sub        __subxf3
#define float128_sub        __subtf3

#define float32_mul         __mulsf3
#define float64_mul         __muldf3
#define floatx80_mul        __mulxf3
#define float128_mul        __multf3

#define float32_div         __divsf3
#define float64_div         __divdf3
#define floatx80_div        __divxf3
#define float128_div        __divtf3

#define int32_to_float32        __floatsisf
#define int32_to_float64        __floatsidf
#define int32_to_floatx80       __floatsixf
#define int32_to_float128       __floatsitf

#define int64_to_float32        __floatdisf
#define int64_to_float64        __floatdidf
#define int64_to_floatx80       __floatdixf
#define int64_to_float128       __floatditf

#define int128_to_float32       __floattisf
#define int128_to_float64       __floattidf
#define int128_to_floatx80      __floattixf
#define int128_to_float128      __floattitf

#define uint32_to_float32       __floatunsisf
#define uint32_to_float64       __floatunsidf
#define uint32_to_floatx80      __floatunsixf
#define uint32_to_float128      __floatunsitf

#define uint64_to_float32       __floatundisf
#define uint64_to_float64       __floatundidf
#define uint64_to_floatx80      __floatundixf
#define uint64_to_float128      __floatunditf

#define uint128_to_float32      __floatuntisf
#define uint128_to_float64      __floatuntidf
#define uint128_to_floatx80     __floatuntixf
#define uint128_to_float128     __floatuntitf

#define float32_to_int32_round_to_zero   __fixsfsi
#define float64_to_int32_round_to_zero   __fixdfsi
#define floatx80_to_int32_round_to_zero  __fixxfsi
#define float128_to_int32_round_to_zero  __fixtfsi

#define float32_to_int64_round_to_zero   __fixsfdi
#define float64_to_int64_round_to_zero   __fixdfdi
#define floatx80_to_int64_round_to_zero  __fixxfdi
#define float128_to_int64_round_to_zero  __fixtfdi

#define float32_to_int128_round_to_zero  __fixsfti
#define float64_to_int128_round_to_zero  __fixdfti
#define floatx80_to_int128_round_to_zero __fixxfti
#define float128_to_int128_round_to_zero __fixtfti

#define float32_to_uint32_round_to_zero     __fixunssfsi
#define float64_to_uint32_round_to_zero     __fixunsdfsi
#define floatx80_to_uint32_round_to_zero    __fixunsxfsi
#define float128_to_uint32_round_to_zero    __fixunstfsi

#define float32_to_uint64_round_to_zero     __fixunssfdi
#define float64_to_uint64_round_to_zero     __fixunsdfdi
#define floatx80_to_uint64_round_to_zero    __fixunsxfdi
#define float128_to_uint64_round_to_zero    __fixunstfdi

#define float32_to_uint128_round_to_zero    __fixunssfti
#define float64_to_uint128_round_to_zero    __fixunsdfti
#define floatx80_to_uint128_round_to_zero   __fixunsxfti
#define float128_to_uint128_round_to_zero   __fixunstfti

#define float32_to_float64      __extendsfdf2
#define float32_to_floatx80     __extendsfxf2
#define float32_to_float128     __extendsftf2
#define float64_to_floatx80     __extenddfxf2
#define float64_to_float128     __extenddftf2

#define float128_to_float64     __trunctfdf2
#define floatx80_to_float64     __truncxfdf2
#define float128_to_float32     __trunctfsf2
#define floatx80_to_float32     __truncxfsf2
#define float64_to_float32      __truncdfsf2


extern void abort (void);
/*
void __extendsfxf2 (void) { abort(); }
void __extenddfxf2 (void) { abort(); }
void __truncxfdf2 (void) { abort(); }
void __truncxfsf2 (void) { abort(); }
void __fixxfsi (void) { abort(); }
void __floatsixf (void) { abort(); }
void __addxf3 (void) { abort(); }
void __subxf3 (void) { abort(); }
void __mulxf3 (void) { abort(); }
void __divxf3 (void) { abort(); }
void __negxf2 (void) { abort(); }
void __eqxf2 (void) { abort(); }
void __nexf2 (void) { abort(); }
void __gtxf2 (void) { abort(); }
void __gexf2 (void) { abort(); }
void __lexf2 (void) { abort(); }
void __ltxf2 (void) { abort(); }

void __extendsftf2 (void) { abort(); }
void __extenddftf2 (void) { abort(); }
void __trunctfdf2 (void) { abort(); }
void __trunctfsf2 (void) { abort(); }
void __fixtfsi (void) { abort(); }
void __floatsitf (void) { abort(); }
void __addtf3 (void) { abort(); }
void __subtf3 (void) { abort(); }
void __multf3 (void) { abort(); }
void __divtf3 (void) { abort(); }
void __negtf2 (void) { abort(); }
void __eqtf2 (void) { abort(); }
void __netf2 (void) { abort(); }
void __gttf2 (void) { abort(); }
void __getf2 (void) { abort(); }
void __letf2 (void) { abort(); }
void __lttf2 (void) { abort(); }
*/
long
__cmpdf2(double x1, double x2)
{
  abort();
}


void memset(char *dst, int c, int n) {
  int i;
  for (i = 0; i < n; i++) {
    dst[i] = c;
  }
}
