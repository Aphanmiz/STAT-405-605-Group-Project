ppois(99, lambda = 3)

i <- 0:40; exp(-3)* sum((exp(7*i) * 3^i) / factorial(i))

# Q8
k <- 1:10; exp(-1) / factorial (k)

choose(100,k) * (1/100)^k * (99/100)^(100-k)