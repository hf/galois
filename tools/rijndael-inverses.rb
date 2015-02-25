# Copyright (c) 2015 Stojan Dimitrovski
# Distributed under the MIT license.
# See LICENSE.txt for full text or http://opensource.org/licenses/MIT.

# generates all 255 inverses for a 1 byte galois field with 0x1B as
# the irreducible polynomial

def multiply a, b
  p = 0

  8.times do
    p ^= a if (b & 1) != 0

    b >>= 1
    carry = a & 0x80
    a <<= 1
    a &= 0xFF # clamp a to 255

    a ^= 0x1B if carry != 0
  end

  p
end

INVERSES = [ 0, (1..255).map do |i|
  (1..255).find do |j|
    multiply(i, j) == 1
  end
end ].flatten

puts INVERSES.map { |i| "0x#{i.to_s(16).rjust(2, '0').upcase}" }.each_slice(8).map { |s| s.join(', ') }.join(",\n")
