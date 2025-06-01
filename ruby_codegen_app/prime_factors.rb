n = gets.to_i

if n < 2
  puts [].inspect
  exit
end

factors = []
while n % 2 == 0
  factors << 2
  n /= 2
end

factor = 3
while factor * factor <= n
  if n % factor == 0
    factors << factor
    n /= factor
  else
    factor += 2
  end
end

factors << n if n > 1

puts factors.inspect