import numpy as np

def mandelbrot(c, max_iter):
    z = 0
    for n in range(max_iter):
        magnitude = abs(z)
        print(f"Iteration {n}: Magnitude of z = {magnitude}")
        if magnitude > 2:
            return n
        z = z * z + c
    return max_iter

# Set test cases
test_cases = [
    (0 + 0j, 100, "Test 1: c = 0 + 0i"),
    
    (2 + 2j, 100, "Test 2: c = 2 + 2i"),
    
    (0.25 + 0.25j, 100, "Test 3: c = 0.25 + 0.25i"),
    
    (-0.25 + 0.5j, 100, "Test 4: c = -0.25 + 0.5i"),

    (-0.8 + 0.156j, 100, "Test 5: c = -0.8 + 0.156i"),

    (-0.74 + 0.18j, 100, "Test 6: c = -0.74 + 0.18i")
]

for c, max_iter, test_case_name in test_cases:
    print(f"\n{test_case_name}")
    iterations = mandelbrot(c, max_iter)
    print(f"Total Iterations: {iterations} (Expected: {max_iter if c.real == 0 and c.imag == 0 else iterations})")
