# Galois

This is a tiny, header only C / OpenCL library for dealing with
[Galois fields](http://en.wikipedia.org/wiki/Finite_field).

It was mainly developed for a cryptography project in OpenCL, but since it does
not use OpenCL specifics it can be used in-place for any C99 implementation.

It supports `GF(2^n)` fields where `n` is a non-zero multiple of 8.

For full performance it requires a loop-unrolling compiler (such as GCC or an
LLVM based compiler).

Most of the 'functions' are essentially macros. (This is so it can work with
any arguments of the disjoint memory spaces in OpenCL.)

It does not use any caching techniques such as logarithm tables or tables of
inverses.

It uses big-endian ordering.

## Usage

Code is in the file `finite_fields.cl`.

Include it in your OpenCL sources or your C99-compatible program. The macro
`ffwidth` should be defined to the number of bytes in the field.

```c
uchar a[ffwidth];
uchar b[ffwidth];
uchar result[ffwidth];
uchar irreducible_polynomial[ffwidth];

FiniteFieldAdd(a, b, result);
FiniteFieldMultiply(a, b, result, irreducible_polynomial);
FiniteFieldMultiplicativeInverse(a, result, irreducible_polynomial);
```

Pure C users may need to: `#define uchar unsigned char`.

### Polynomials

The Rijndael (AES) polynomial can be represented by `0x1B`.

A 16-bit polynomial that is suitable is `0x3F 0x80`.

## Tools

Included inside the `tools` directory are some Ruby scripts that are helpful
to develop finite field implementations.

## License

Copyright &copy; 2015 Stojan Dimitrovski

All of the code herein, except where otherwise noted is distributed under
[The MIT License](http://opensource.org/licenses/MIT).

See the file `LICENSE.txt` for the full text.

