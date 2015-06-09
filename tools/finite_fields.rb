# Copyright (C) 2015 Stojan Dimitrovski
#
# Licensed under the MIT X11 license. Consult the file LICENSE.txt included
# in this distribution.

Fixnum.class_eval do
  def to_bytes
    bytes = []
    i = self

    while i > 0
      bytes << (i & 0xFF)
      i >>= 8
    end

    bytes.reverse
  end
end

def polynomial powers
  p = 0

  powers.each do |power|
    p |= 1 << power
  end

  p
end

def mul ia, ib, ip = 0x1B, bits = 8
  max = (1 << bits) - 1
  a = ia
  b = ib
  p = 0
  carry = 0

  bits.times do |i|
    p = (p ^ ((b & 1) * a)) & max
    b = (b >> 1) & max
    carry = (a >> (bits - 1)) & max
    a = (a << 1) & max

    if carry != 0
      a = (a ^ ip) & max
    end
  end

  p
end

def rightmost n, bits = 8
  return [0, 0] if n == 0

  i = 0

  while n & (1 << (bits - 1)) == 0
    n <<= 1
    i += 1
  end

  [n, i]
end

def leftmost n, bits = 8
  return [0, 0] if n == 0

  i = 0

  while n & 1 == 0
    n >>= 1
    i += 1
  end

  [n, i]
end

def div n, d, bits = 8
  max = (1 << bits) - 1
  n = rightmost n, bits
  d = rightmost d, bits

  # puts n[1], d[1]

  divisor = d[0]
  dividend = n[0]

  quotient = 0

  remainder = 0

  (d[1] - n[1] + 1).times do
    coefficient = (dividend & divisor) >> (bits - 1)
    quotient = (quotient << 1) | coefficient
    quotient &= max
    # print "#{dividend.to_s(2)} / #{divisor.to_s(2)} = #{quotient.to_s(2)}"
    dividend ^= divisor
    # puts " #{remainder.to_s(2)}"
    dividend <<= 1
    dividend &= max
  end

  quotient
end

def divw n, d, bits = 8
  max = (1 << bits) - 1
  n = [n, 0]
  d = rightmost d, bits

  # puts n[1], d[1]

  divisor = d[0]
  dividend = n[0]

  dividend ^= (divisor << 1) & max

  quotient = 1

  remainder = 0

  (d[1] - n[1] + 1).times do
    coefficient = (dividend & divisor) >> (bits - 1)
    quotient = (quotient << 1) | coefficient
    quotient &= max
    # print "#{dividend.to_s(2)} / #{divisor.to_s(2)} = #{quotient.to_s(2)}"
    dividend ^= divisor
    # puts " #{remainder.to_s(2)}"
    dividend <<= 1
    dividend &= max
  end

  quotient
end

# def inverse a, p = 0x11B
#   t = 0
#   newt = 1
#   r = p
#   newr = a

#   q = divw(r & 0xFF, newr & 0xFF)

#   while newr != 0
#     r, newr = newr, ((r == 0x11B ? 0 : r) ^ mul(q, newr))
#     t, newt = newt, (t ^ mul(q, newt))
#     q = div(r, newr, 8)
#   end

#   [t, newt, r, newr, a, p]
# end

def inverse a, p, bits = 8
  max = (1 << bits) - 1
  t = 0
  newt = 1
  r = p
  newr = a
  temp = 0

  q = divw(r & max, newr & max, bits)

  run = newr != 0

  temp = mul(q & max, newr & max, p & max, bits)

  counter = 0

  while run
    r = newr
    newr = temp

    temp = ((t & max) ^ mul(q & max, newt & max, p & max, bits))
    t = newt
    newt = temp

    q = div(r & max, newr & max, bits)

    run = newr != 0

    temp = ((r & max) ^ mul(q & max, newr & max, p & max, bits))

    #puts "newr #{newr}"
    counter += 1
  end

  [t, newt, r, newr, a, p, counter]
end

def qsum
  sum = 0
  256.times do |a|
    255.times do |b|
      sum += div(a, b + 1)
    end
  end
  sum
end

def qpsum
  sum = 0
  256.times do |a|
    255.times do |b|
      sum += divw(a, b + 1)
    end
  end
  sum
end

def isum
  sum = 0

  255.times do |a|
    sum += inverse(a + 1)[0]
  end

  sum
end
