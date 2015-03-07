// Copyright (c) 2015 Stojan Dimitrovski
// Distributed under the MIT license.
// See LICENSE.txt for full text or http://opensource.org/licenses/MIT.

#pragma once

#include <cstddef>
#include <cassert>

using namespace std;

namespace galois {
namespace Field {

/*
 * Implements the Rijndael Galois field, i.e.
 * GF(2^8) with P(x) = x8 + x4 + x3 + x + 1 as the reducing polynomial.
 */
class Rijndael {
private:
  static const unsigned char CARRY_SUBTRACT[];

public:
  Rijndael() {
    assert (CARRY_SUBTRACT[0] == 0);
    assert (CARRY_SUBTRACT[1] == IRREDUCIBLE);
  }

  ~Rijndael() {
    // No-op.
  }

  static const size_t ORDER;
  static const size_t WIDTH;

  static const unsigned char IRREDUCIBLE;

  // output generated by tools/rijndael-inverses.rb
  static const unsigned char INVERSES[];

  inline char* Value(unsigned char value, char* const out) const {
    *out = (char) value;

    return out;
  }

  inline int Compare(const char* const a, const char* const b) const {
    return ((int) *a) - ((int) *b);
  }

  inline char* Add(const char* const a, const char* const b, char* const out) const {
    *out = *a ^ *b;

    return out;
  }

  inline char* Sub(const char* const a, const char* const b, char* const out) const {
    return Add(a, b, out);
  }

  inline char* Mul(const char* const ia, const char* const ib, char* const out) const {
    unsigned char a = (char) *ia;
    unsigned char b = (char) *ib;
    unsigned char p = 0;
    unsigned char carry = 0;

    for (int i = 0; i < 8; i++) {
      p ^= (b & 1) * a; //if (b & 1) { p ^= a; }
      b >>= 1;
      carry = a >> 7; // carry = a & 0x80;
      a <<= 1;
      a ^= CARRY_SUBTRACT[carry]; // if (carry) { a ^= 0x1B; }
    }

    *out = (char) p;

    return out;
  }

  inline char* Div(const char* const a, const char* const b, char* const out) const {
    assert (*b != 0);

    char binv = INVERSES[(unsigned char) *b];

    return Mul(a, (char*) &binv, out);
  }
};

const size_t Rijndael::ORDER = 256;
const size_t Rijndael::WIDTH = 1;

const unsigned char Rijndael::IRREDUCIBLE = 0x1B;

const unsigned char Rijndael::CARRY_SUBTRACT[] = { 0, Rijndael::IRREDUCIBLE };

const unsigned char Rijndael::INVERSES[] = {
    0x00, 0x01, 0x8D, 0xF6, 0xCB, 0x52, 0x7B, 0xD1,
    0xE8, 0x4F, 0x29, 0xC0, 0xB0, 0xE1, 0xE5, 0xC7,
    0x74, 0xB4, 0xAA, 0x4B, 0x99, 0x2B, 0x60, 0x5F,
    0x58, 0x3F, 0xFD, 0xCC, 0xFF, 0x40, 0xEE, 0xB2,
    0x3A, 0x6E, 0x5A, 0xF1, 0x55, 0x4D, 0xA8, 0xC9,
    0xC1, 0x0A, 0x98, 0x15, 0x30, 0x44, 0xA2, 0xC2,
    0x2C, 0x45, 0x92, 0x6C, 0xF3, 0x39, 0x66, 0x42,
    0xF2, 0x35, 0x20, 0x6F, 0x77, 0xBB, 0x59, 0x19,
    0x1D, 0xFE, 0x37, 0x67, 0x2D, 0x31, 0xF5, 0x69,
    0xA7, 0x64, 0xAB, 0x13, 0x54, 0x25, 0xE9, 0x09,
    0xED, 0x5C, 0x05, 0xCA, 0x4C, 0x24, 0x87, 0xBF,
    0x18, 0x3E, 0x22, 0xF0, 0x51, 0xEC, 0x61, 0x17,
    0x16, 0x5E, 0xAF, 0xD3, 0x49, 0xA6, 0x36, 0x43,
    0xF4, 0x47, 0x91, 0xDF, 0x33, 0x93, 0x21, 0x3B,
    0x79, 0xB7, 0x97, 0x85, 0x10, 0xB5, 0xBA, 0x3C,
    0xB6, 0x70, 0xD0, 0x06, 0xA1, 0xFA, 0x81, 0x82,
    0x83, 0x7E, 0x7F, 0x80, 0x96, 0x73, 0xBE, 0x56,
    0x9B, 0x9E, 0x95, 0xD9, 0xF7, 0x02, 0xB9, 0xA4,
    0xDE, 0x6A, 0x32, 0x6D, 0xD8, 0x8A, 0x84, 0x72,
    0x2A, 0x14, 0x9F, 0x88, 0xF9, 0xDC, 0x89, 0x9A,
    0xFB, 0x7C, 0x2E, 0xC3, 0x8F, 0xB8, 0x65, 0x48,
    0x26, 0xC8, 0x12, 0x4A, 0xCE, 0xE7, 0xD2, 0x62,
    0x0C, 0xE0, 0x1F, 0xEF, 0x11, 0x75, 0x78, 0x71,
    0xA5, 0x8E, 0x76, 0x3D, 0xBD, 0xBC, 0x86, 0x57,
    0x0B, 0x28, 0x2F, 0xA3, 0xDA, 0xD4, 0xE4, 0x0F,
    0xA9, 0x27, 0x53, 0x04, 0x1B, 0xFC, 0xAC, 0xE6,
    0x7A, 0x07, 0xAE, 0x63, 0xC5, 0xDB, 0xE2, 0xEA,
    0x94, 0x8B, 0xC4, 0xD5, 0x9D, 0xF8, 0x90, 0x6B,
    0xB1, 0x0D, 0xD6, 0xEB, 0xC6, 0x0E, 0xCF, 0xAD,
    0x08, 0x4E, 0xD7, 0xE3, 0x5D, 0x50, 0x1E, 0xB3,
    0x5B, 0x23, 0x38, 0x34, 0x68, 0x46, 0x03, 0x8C,
    0xDD, 0x9C, 0x7D, 0xA0, 0xCD, 0x1A, 0x41, 0x1C };

} // Field
} // galois
