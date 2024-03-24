# Original 16-bit number
original_number = 0x3f1bc

# Sign-extend to 32-bit and shift left by 2 bits
extended_number = original_number & 0xFFFF  # Mask to ensure only 16 bits are considered
if original_number & 0x8000:  # If sign bit is set
    extended_number |= 0xFFFF0000  # Sign extend by setting all higher bits to 1

# Shift left by 2 bits
shifted_number = extended_number << 2

# Convert '000019cc' and '32'h4' to decimal
num1_decimal = int('000019cc', 16)
num2_decimal = int('4', 16)

# Add the shifted number to the sum of '000019cc' and '32'h4'
result_decimal = num1_decimal + num2_decimal + shifted_number

# Convert the result back to hexadecimal
result_hex = hex(result_decimal)

print("Result in hexadecimal:", result_hex)
