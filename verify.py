import random

def model(a: list[int], b: list[int], c: int) -> tuple[int, int]:
    full_sum = 0
    for i in range(4):
        full_sum += a[i] * b[i]
    full_sum += c
    if full_sum > 32767: return (32767, 1)
    if full_sum < -32768: return (-32768, 1)
    return (full_sum, 0)

def twos_comp(val: int, bits: int) -> str:
    if val < 0:
        val = (1 << bits) + val
    val = val & ((1 << bits) - 1)
    hex_len = bits // 4
    return f"{val:0{hex_len}x}"

def generate_vectors(num_random_tests: int = 1000):
    corner_cases = [
        ([0, 0, 0, 0], [0, 0, 0, 0], 0),                              # All zeros
        ([127, 127, 127, 127], [127, 127, 127, 127], 0),              # Max positive
        ([-128, -128, -128, -128], [-128, -128, -128, -128], 0),      # Extreme negative
        ([100, -100, 50, -50], [10, 10, 20, 20], 0),                  # Cancellation
        ([10, 10, 10, 10], [10, 10, 10, 10], 32700),                  # Positive overflow
        ([-10, -10, -10, -10], [10, 10, 10, 10], -32700),             # Negative underflow
        ([0, 0, 0, 0], [0, 0, 0, 0], 32767),                          # +32767 limit
        ([0, 0, 0, 0], [0, 0, 0, 0], -32768)                          # -32768 limit
    ]

    with open("inputs.hex", "w") as f_in, open("expected.hex", "w") as f_exp:
        for a, b, c in corner_cases:
            d_exp, ovf_exp = model(a, b, c)
            a_hex = [twos_comp(x, 8) for x in a]
            b_hex = [twos_comp(x, 8) for x in b]
            c_hex = twos_comp(c, 16)
            d_hex = twos_comp(d_exp, 16)

            f_in.write(f"{' '.join(a_hex)} {' '.join(b_hex)} {c_hex}\n")
            f_exp.write(f"{d_hex} {ovf_exp}\n")

        for _ in range(num_random_tests):
            a = [random.randint(-128, 127) for _ in range(4)]
            b = [random.randint(-128, 127) for _ in range(4)]
            c = random.randint(-32768, 32767)

            d_exp, ovf_exp = model(a, b, c)
            a_hex = [twos_comp(x, 8) for x in a]
            b_hex = [twos_comp(x, 8) for x in b]
            c_hex = twos_comp(c, 16)
            d_hex = twos_comp(d_exp, 16)

            f_in.write(f"{' '.join(a_hex)} {' '.join(b_hex)} {c_hex}\n")
            f_exp.write(f"{d_hex} {ovf_exp}\n")

    print(f"Generated {len(corner_cases) + num_random_tests} test vectors successfully!")

if __name__ == "__main__":
    generate_vectors(1000)