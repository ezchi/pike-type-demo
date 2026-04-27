#include "../../gen/cpp/alpha/typist/constants_types.hpp"
#include <iostream>
#include <cassert>
#include <vector>
#include <stdexcept>

using namespace alpha::constants;

void test_constants() {
  std::cout << "Testing constants..." << std::endl;
  assert(FOO == 100000LL);
  assert(BAR == 0U);
  assert(A == 3U);
  assert(B == 8);
  assert(C == 13);
  assert(D == -3);
  assert(E == ~3);
  assert(W == 13);
}

void test_addr_ct() {
  std::cout << "Testing addr_ct..." << std::endl;
  addr_ct addr(1234);
  assert(addr.value == 1234);
  assert(static_cast<std::uint16_t>(addr) == 1234);
  assert(addr_ct::kWidth == 13);
  assert(addr_ct::kMaxValue == 8191);

  // Validation
  try {
    addr_ct bad(8192);
    assert(false && "Should have thrown out_of_range");
  } catch (const std::out_of_range&) {
    // Expected
  }

  // to_bytes / from_bytes
  auto bytes = addr.to_bytes();
  assert(bytes.size() == 2);
  assert(bytes[0] == (1234 & 0xFF));
  assert(bytes[1] == (1234 >> 8));

  addr_ct addr2;
  addr2.from_bytes(bytes);
  assert(addr2.value == 1234);
  assert(addr == addr2);
}

void test_mask_ct() {
  std::cout << "Testing mask_ct..." << std::endl;
  mask_ct mask(-50);
  assert(mask.value == -50);
  assert(mask_ct::kSigned == true);
  assert(mask_ct::kWidth == 8);

  // Validation: For an 8-bit signed type with an int8_t underlying type,
  // all possible int8_t values are within [-128, 127].
  // Values like 200 would be implicitly cast to int8_t (yielding -56)
  // before reaching the validate_value method.
  // Therefore, we don't test out-of-range for mask_ct here.

  // to_bytes / from_bytes
  auto bytes = mask.to_bytes();
  assert(bytes.size() == 1);
  assert(static_cast<std::int8_t>(bytes[0]) == -50);

  mask_ct mask2;
  mask2.from_bytes(bytes);
  assert(mask2.value == -50);
  assert(mask == mask2);
}

void test_flag_ct() {
  std::cout << "Testing flag_ct..." << std::endl;
  flag_ct f(1);
  assert(f.value == 1);
  assert(flag_ct::kWidth == 1);

  try {
    flag_ct bad(2);
    assert(false && "Should have thrown out_of_range");
  } catch (const std::out_of_range&) {
    // Expected
  }

  auto bytes = f.to_bytes();
  assert(bytes.size() == 1);
  assert(bytes[0] == 1);

  flag_ct f2;
  f2.from_bytes(bytes);
  assert(f2.value == 1);
}

void test_big_data_ct() {
  std::cout << "Testing big_data_ct..." << std::endl;
  std::vector<std::uint8_t> data = {1, 2, 3, 4, 5, 6, 7, 8, 9};
  big_data_ct bd(data);
  assert(bd.value == data);
  assert(big_data_ct::kWidth == 67);
  assert(big_data_ct::kByteCount == 9);

  try {
    big_data_ct bad(std::vector<std::uint8_t>{1, 2});
    assert(false && "Should have thrown invalid_argument");
  } catch (const std::invalid_argument&) {
    // Expected
  }

  auto bytes = bd.to_bytes();
  assert(bytes == data);

  big_data_ct bd2;
  bd2.from_bytes(bytes);
  assert(bd2.value == data);
}

void test_header_ct() {
  std::cout << "Testing header_ct..." << std::endl;
  header_ct h;
  h.addr = addr_ct(0x1ABC); // 13 bits: 1 1010 1011 1100
  h.enable = flag_ct(1);

  // Packing:
  // bit_offset = 14
  // bit_offset -= 13 -> 1. addr packed at [1, 13]
  // bit_offset -= 1  -> 0. enable packed at [0, 0]
  // Total 14 bits.
  // byte 0: [addr[6:0], enable]
  // byte 1: [00, addr[12:7]]

  auto bytes = h.to_bytes();
  assert(bytes.size() == 2);
  
  // addr = 0x1ABC = 0b 1 1010 1011 1100
  // LSB 7 bits of addr: 011 1100 = 0x3C
  // byte 0 = (0x3C << 1) | 1 = 0x78 | 1 = 0x79
  assert(bytes[0] == 0x79);

  // upper 6 bits of addr: 1 1010 1 = 0b110101 = 0x35
  // byte 1 = 0x35
  assert(bytes[1] == 0x35);

  header_ct h2;
  h2.from_bytes(bytes);
  assert(h2.addr.value == 0x1ABC);
  assert(h2.enable.value == 1);
  assert(h == h2);
}

void test_packet_ct() {
  std::cout << "Testing packet_ct..." << std::endl;
  packet_ct p;
  p.header.addr = addr_ct(0x555);
  p.header.enable = flag_ct(0);
  p.mode = 2;
  p.error_code = 5;

  // kWidth = 19
  // header: 14 bits at [5, 18]
  // mode: 2 bits at [3, 4]
  // error_code: 3 bits at [0, 2]

  auto bytes = p.to_bytes();
  assert(bytes.size() == 3);

  packet_ct p2;
  p2.from_bytes(bytes);
  assert(p2.header.addr.value == 0x555);
  assert(p2.header.enable.value == 0);
  assert(p2.mode == 2);
  assert(p2.error_code == 5);
  assert(p == p2);

  // Validation
  try {
    p.mode = 4; // 2 bits max 3
    p.to_bytes();
    assert(false && "Should have thrown out_of_range");
  } catch (const std::out_of_range&) {
    // Expected
  }
}

int main() {
  try {
    test_constants();
    test_addr_ct();
    test_mask_ct();
    test_flag_ct();
    test_big_data_ct();
    test_header_ct();
    test_packet_ct();
    std::cout << "All tests passed!" << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "Test failed with exception: " << e.what() << std::endl;
    return 1;
  }
  return 0;
}
