# Galois

This is a small, header-only C++ library that features various
[Galois field](http://en.wikipedia.org/wiki/Finite_field) implementations.

## Field Definition

This library tries to be as minimal as possible. It does *not* use fancy
features like polymorphism, C++11, etc. (Templates are OK.)

Here is an outline for a minimal field implementation. All of the parameters
**must** be included. Everything else is optional.

```c++
class FieldName {
public:
  // width of argument data (in bytes)
  static const size_t WIDTH;

  // order (number of elements in field)
  static const size_t ORDER;

  FieldName() { /* no-op. */ }
  ~FieldName() { /* no-op. */ }

  // comparator
  // returns a value greater than 0 if value at a > value at b
  // returns a value less than 0    if value at a < value at b
  // returns 0                      if value at a == value at b
  inline int Compare(const char* const a, const char* const b) const;

  // setter
  // places value into out
  // TYPE is an appropriate type that can hold ORDER values. it is left
  // unspecified
  // returns out
  inline char* const
  Value(TYPE value, char* const out) const;

  // addition
  // adds value at a with value at b and places it into out
  // returns out
  inline char* const
  Add(const char* const a, const char* const b, char* const out) const;

  // subtraction
  // subtracts value at a with value at b and places it into out
  // returns out
  inline char* const
  Sub(const char* const a, const char* const b, char* const out) const;

  // multiplication
  // multiplies value at a with value at b and places it into out
  // returns out
  inline char* const
  Mul(const char* const a, const char* const b, char* const out) const;

  // division
  // divides value at a with value at b (b != 0) and places it into out
  // returns out
  inline char* const
  Div(const char* const a, const char* const b, char* const out) const;
};
```

## License

Copyright &copy; 2015 Stojan Dimitrovski

All of the code herein, except where otherwise noted is distributed under
[The MIT License](http://opensource.org/licenses/MIT).

See the file `LICENSE.txt` for the full text.

