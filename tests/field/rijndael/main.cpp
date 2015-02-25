#define CATCH_CONFIG_MAIN

#include <catch.hpp>
#include <galois/field/rijndael.hpp>

#include <cstddef>

using namespace std;

TEST_CASE ("Rijndael field should be defined properly.", "[galois::Field::Rijndael]") {
  REQUIRE (galois::Field::Rijndael::ORDER == 256);
  REQUIRE (galois::Field::Rijndael::WIDTH == 1);
  REQUIRE (galois::Field::Rijndael::IRREDUCIBLE == 0x1B);
}

TEST_CASE ("Rijndael field should add / subtract correctly.", "[galois::Field::Rijndael]") {
  galois::Field::Rijndael field;

  for (size_t i = 0; i <= 0xFF; i++) {
    for (size_t j = 0; j <= 0xFF; j++) {
      unsigned char a = i & 0xFF;
      unsigned char b = j & 0xFF;
      unsigned char r = 0;

      REQUIRE (field.Add((char*) &a, (char*) &b, (char*) &r) == (char*) &r);
      REQUIRE (field.Sub((char*) &r, (char*) &b, (char*) &r) == (char*) &r);

      REQUIRE (r == a);

      field.Add((char*) &a, (char*) &b, (char*) &r);
      field.Sub((char*) &r, (char*) &a, (char*) &r);

      REQUIRE (r == b);
    }
  }
}

TEST_CASE ("Rijndael field should multiply and behave correctly with multiplicative inverses", "[galois::Field::Rijndael]") {
  galois::Field::Rijndael field;

  REQUIRE (galois::Field::Rijndael::INVERSES[0] == 0);

  for (size_t i = 1; i <= 0xFF; i++) {
    unsigned char result = i & 0xFF;
    unsigned char inv = galois::Field::Rijndael::INVERSES[i];

    REQUIRE (field.Mul((char*) &result, (char*) &inv, (char*) &result) == (char*) &result);

    REQUIRE (result == 1);
  }
}
