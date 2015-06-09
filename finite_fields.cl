// Copyright (C) 2015 Stojan Dimitrovski
//
// Licensed under the MIT X11 license. Consult the file LICENSE.txt included
// in this distribution.

// Global macros:
// ffwidth: size of finite field width in bytes

#define FiniteFieldUnion(a, result) { \
  size_t ffu_i = 0; \
\
  *(result) = 0; \
\
  for (ffu_i = 0; ffu_i < ffwidth; ffu_i++) { \
    *(result) = *(result) | (a)[ffu_i]; \
  } \
}

#define FiniteFieldCompare(a, b, result) { \
  size_t ffc_i = 0; \
 \
  *(result) = 0; \
 \
  for (ffc_i = 0; ffc_i < ffwidth; ffc_i++) { \
    *(result) = *(result) + (a)[ffc_i] ^ (b)[ffc_i]; \
  } \
}

#define FiniteFieldShiftLeft(a, places) { \
  (a)[0] = (a)[0] << (places); \
\
  size_t ffsl_i = 0; \
  for (ffsl_i = 1; ffsl_i < ffwidth; ffsl_i++) { \
    (a)[ffsl_i - 1] = (a)[ffsl_i - 1] | ((a)[ffsl_i] >> (8 - (places))); \
    (a)[ffsl_i] = (a)[ffsl_i] << (places); \
  } \
}

#define FiniteFieldShiftRight(a, places) { \
  size_t ffsl_i = 0; \
\
  for (ffsl_i = 0; ffsl_i < ffwidth - 1; ffsl_i++) { \
    (a)[ffwidth - ffsl_i - 1] = (a)[ffwidth - ffsl_i - 1] >> (places); \
    (a)[ffwidth - ffsl_i - 1] = (a)[ffwidth - ffsl_i - 1] | ((a)[ffwidth - ffsl_i - 2] << (8 - (places))); \
  } \
\
  (a)[0] = (a)[0] >> (places); \
}

#define FiniteFieldValue(value, result) { \
  size_t ffv_i = 0; \
  ulong ffv_v  = (ulong) (value); \
\
  for (ffv_i = 0; ffv_i < ffwidth; ffv_i++) { \
    (result)[ffv_i] = ((ffv_v) >> ((ffwidth - ffv_i - 1) * 8)); \
  } \
}

#define FiniteFieldToValue(from, to) { \
  size_t fftvi = 0; \
 \
  *(to) = 0; \
\
  for (fftvi = 0; fftvi < ffwidth; fftvi++) { \
    *(to) = (*(to) << 8) | (from)[fftvi]; \
  } \
}

#define FiniteFieldCopy(from, to) { \
  size_t ffc_i = 0; \
\
  for (ffc_i = 0; ffc_i < ffwidth; ffc_i++) { \
    ((to)[ffc_i]) = ((from)[ffc_i]); \
  } \
}

#define FiniteFieldAdd(a, b, result) { \
  size_t ffa_i = 0; \
\
  for (ffa_i = 0; ffa_i < ffwidth; ffa_i++) { \
    ((result)[ffa_i]) = ((a)[ffa_i]) ^ ((b)[ffa_i]); \
  } \
}

#define FiniteFieldSubtract(a, b, result) { \
  FiniteFieldAdd(a, b, result); \
}

 #define FiniteFieldMultiply(a, b, result, ffip) { \
  uchar ia[ffwidth]; \
  uchar ib[ffwidth]; \
  uchar p[ffwidth]; \
 \
  FiniteFieldValue(0, p); \
  FiniteFieldCopy(a, ia); \
  FiniteFieldCopy(b, ib); \
 \
  size_t i = 0; \
  size_t j = 0; \
  int carry = 0; \
  int add_a = 0; \
 \
  for (i = 0; i < ffwidth * 8; i++) { \
    add_a = ib[ffwidth - 1] & 1; \
\
    for (j = 0; j < ffwidth; j++) { \
      p[j] = p[j] ^ (add_a * ia[j]); \
    } \
 \
    FiniteFieldShiftRight(ib, 1); \
 \
    carry = ia[0] / 128; \
 \
    FiniteFieldShiftLeft(ia, 1); \
\
    for (j = 0; j < ffwidth; j++) { \
      ia[j] = ia[j] ^ ((ffip)[j] * carry); \
    } \
  } \
 \
  FiniteFieldCopy(p, result); \
}

#define FiniteFieldLeftAlign(a, n) { \
  size_t fflai = 0; \
  size_t ffla_bits = 0; \
 \
  for (fflai = 0; fflai < (ffwidth * 8); fflai++) { \
    size_t ffla_leftmost = (a[0] >> 7) ^ 1; \
    FiniteFieldShiftLeft(a, ffla_leftmost); \
    ffla_bits += ffla_leftmost; \
  } \
 \
  *(n) = ffla_bits % (ffwidth * 8); \
}

#define FiniteFieldQuotient(n, d, result) { \
  FiniteFieldValue(0, result); \
\
  int ffq_dividend_bits = 0; \
  int ffq_divisor_bits = 0; \
\
  uchar ffq_divisor[ffwidth]; \
  FiniteFieldCopy(d, ffq_divisor); \
\
  uchar ffq_dividend[ffwidth]; \
  FiniteFieldCopy(n, ffq_dividend); \
\
  FiniteFieldLeftAlign(ffq_divisor, &ffq_divisor_bits); \
  FiniteFieldLeftAlign(ffq_dividend, &ffq_dividend_bits); \
\
  uchar ffq_quotient[ffwidth]; \
  FiniteFieldValue(0, ffq_quotient); \
\
  int ffq_i = 0; \
  uchar ffq_c = 0; \
\
  for (ffq_i = 0; ffq_i < (ffq_divisor_bits - ffq_dividend_bits + 1); ffq_i++) { \
    ffq_c = (ffq_dividend[0] & ffq_divisor[0]) >> 7; \
    FiniteFieldShiftLeft(ffq_quotient, 1); \
    ffq_quotient[ffwidth - 1] = ffq_quotient[ffwidth - 1] | ffq_c; \
    FiniteFieldSubtract(ffq_dividend, ffq_divisor, ffq_dividend); \
    FiniteFieldShiftLeft(ffq_dividend, 1); \
  } \
\
  FiniteFieldCopy(ffq_quotient, result); \
}

#define FiniteFieldQuotientPrepend(n, d, result) { \
  FiniteFieldValue(0, result); \
\
  int ffq_divisor_bits = 0; \
\
  uchar ffq_divisor[ffwidth]; \
  FiniteFieldCopy(d, ffq_divisor); \
\
  uchar ffq_dividend[ffwidth]; \
  FiniteFieldCopy(n, ffq_dividend); \
\
  FiniteFieldLeftAlign(ffq_divisor, &ffq_divisor_bits); \
\
  { \
    uchar ffq_temporary[ffwidth]; \
\
    FiniteFieldCopy(ffq_divisor, ffq_temporary); \
    FiniteFieldShiftLeft(ffq_temporary, 1); \
    FiniteFieldSubtract(ffq_dividend, ffq_temporary, ffq_dividend); \
  } \
\
  uchar ffq_quotient[ffwidth]; \
  FiniteFieldValue(1, ffq_quotient); \
\
  int ffq_i = 0; \
  uchar ffq_c = 0; \
\
  for (ffq_i = 0; ffq_i < (ffq_divisor_bits + 1); ffq_i++) { \
    ffq_c = (ffq_dividend[0] & ffq_divisor[0]) >> 7; \
    FiniteFieldShiftLeft(ffq_quotient, 1); \
    ffq_quotient[ffwidth - 1] = ffq_quotient[ffwidth - 1] | ffq_c; \
    FiniteFieldSubtract(ffq_dividend, ffq_divisor, ffq_dividend); \
    FiniteFieldShiftLeft(ffq_dividend, 1); \
  } \
\
  FiniteFieldCopy(ffq_quotient, result); \
}

#define FiniteFieldMultiplicativeInverse(a, result, ffip) { \
  FiniteFieldValue(0, result); \
\
  uchar ffmi_t[ffwidth]; \
  uchar ffmi_newt[ffwidth]; \
  uchar ffmi_r[ffwidth]; \
  uchar ffmi_newr[ffwidth]; \
  uchar ffmi_quotient[ffwidth]; \
  uchar ffmi_temporary[ffwidth]; \
\
  FiniteFieldValue(0, ffmi_t); \
  FiniteFieldValue(1, ffmi_newt); \
\
  FiniteFieldCopy(ffip, ffmi_r); \
  FiniteFieldCopy(a, ffmi_newr); \
\
  FiniteFieldQuotientPrepend(ffmi_r, ffmi_newr, ffmi_quotient); \
\
  uchar ffmi_union; \
  FiniteFieldUnion(ffmi_newr, &ffmi_union); \
\
  bool ffmi_run = ffmi_union != 0; \
\
  FiniteFieldMultiply(ffmi_quotient, ffmi_newr, ffmi_temporary, ffip); \
\
  while (ffmi_run) { \
    FiniteFieldCopy(ffmi_newr, ffmi_r); \
    FiniteFieldCopy(ffmi_temporary, ffmi_newr); \
\
    FiniteFieldMultiply(ffmi_quotient, ffmi_newt, ffmi_temporary, ffip); \
    FiniteFieldSubtract(ffmi_t, ffmi_temporary, ffmi_temporary); \
\
    FiniteFieldCopy(ffmi_newt, ffmi_t); \
    FiniteFieldCopy(ffmi_temporary, ffmi_newt); \
\
    FiniteFieldQuotient(ffmi_r, ffmi_newr, ffmi_quotient); \
\
    FiniteFieldUnion(ffmi_newr, &ffmi_union); \
    ffmi_run = ffmi_union != 0; \
\
    FiniteFieldMultiply(ffmi_quotient, ffmi_newr, ffmi_temporary, ffip); \
    FiniteFieldSubtract(ffmi_r, ffmi_temporary, ffmi_temporary); \
  } \
\
  FiniteFieldCopy(ffmi_t, result); \
\
}
