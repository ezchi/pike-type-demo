// constants_test_pkg_tb.sv
`timescale 1ns/1ps

module constants_test_pkg_tb;
  import constants_pkg::*;
  import constants_test_pkg::*;

  initial begin
    test_addr_ct();
    test_mask_ct();
    test_flag_ct();
    test_big_data_ct();
    test_header_ct();
    test_packet_ct();
    $display("ALL TESTS COMPLETED");
    $finish;
  end

  task automatic test_addr_ct();
    addr_ct ct1, ct2, ct3;
    addr_t val = 13'h1ABC;
    byte unsigned bytes[];

    $display("Testing addr_ct (13-bit)...");
    ct1 = new(val);
    
    // Test copy/clone
    ct2 = new();
    ct2.copy(ct1);
    if (!ct1.compare(ct2)) $fatal(1, "addr_ct copy failed");
    ct3 = ct1.clone();
    if (!ct1.compare(ct3)) $fatal(1, "addr_ct clone failed");

    // Test roundtrip
    ct1.to_bytes(bytes);
    ct2 = new();
    ct2.from_bytes(bytes);
    if (!ct1.compare(ct2)) begin
      $display("  FAILED: addr_ct roundtrip: expected 0x%h, got 0x%h", ct1.value, ct2.value);
    end else begin
      $display("  PASSED: addr_ct roundtrip");
    end
  endtask

  task automatic test_mask_ct();
    mask_ct ct1, ct2;
    mask_t val = 8'sh5A;
    byte unsigned bytes[];

    $display("Testing mask_ct (8-bit signed)...");
    ct1 = new(val);
    ct1.to_bytes(bytes);
    ct2 = new();
    ct2.from_bytes(bytes);
    if (!ct1.compare(ct2)) begin
      $display("  FAILED: mask_ct roundtrip: expected 0x%h, got 0x%h", ct1.value, ct2.value);
    end else begin
      $display("  PASSED: mask_ct roundtrip");
    end
  endtask

  task automatic test_flag_ct();
    flag_ct ct1, ct2;
    flag_t val = 1'b1;
    byte unsigned bytes[];

    $display("Testing flag_ct (1-bit)...");
    ct1 = new(val);
    ct1.to_bytes(bytes);
    ct2 = new();
    ct2.from_bytes(bytes);
    if (!ct1.compare(ct2)) begin
      $display("  FAILED: flag_ct roundtrip: expected 0x%h, got 0x%h", ct1.value, ct2.value);
    end else begin
      $display("  PASSED: flag_ct roundtrip");
    end
  endtask

  task automatic test_big_data_ct();
    big_data_ct ct1, ct2;
    big_data_t val = 67'h123456789ABCDEF01;
    byte unsigned bytes[];

    $display("Testing big_data_ct (67-bit)...");
    ct1 = new(val);
    ct1.to_bytes(bytes);
    ct2 = new();
    ct2.from_bytes(bytes);
    if (!ct1.compare(ct2)) begin
      $display("  FAILED: big_data_ct roundtrip: expected 0x%h, got 0x%h", ct1.value, ct2.value);
    end else begin
      $display("  PASSED: big_data_ct roundtrip");
    end
  endtask

  task automatic test_header_ct();
    header_ct ct1, ct2;
    byte unsigned bytes[];

    $display("Testing header_ct...");
    ct1 = new();
    ct1.addr = 13'h1ABC;
    ct1.enable = 1'b1;
    ct1.data = 67'h0;

    // Test copy/clone
    ct2 = ct1.clone();
    if (!ct1.compare(ct2)) $fatal(1, "header_ct clone failed");

    // Test roundtrip
    ct1.to_bytes(bytes);
    ct2 = new();
    ct2.from_bytes(bytes);
    if (!ct1.compare(ct2)) begin
      $display("  FAILED: header_ct roundtrip: %s vs %s", ct1.sprint(), ct2.sprint());
    end else begin
      $display("  PASSED: header_ct roundtrip");
    end
  endtask

  task automatic test_packet_ct();
    packet_ct ct1, ct2;
    byte unsigned bytes[];

    $display("Testing packet_ct...");
    ct1 = new();
    ct1.header.addr = 13'h555;
    ct1.header.enable = 1'b0;
    ct1.header.data = 67'h0;
    ct1.mode = 2'd2;
    ct1.error_code = 3'd5;
    ct1.data1 = 32'hDEADBEEF;
    ct1.data2 = 32'hCAFEBABE;

    // Test copy/clone
    ct2 = ct1.clone();
    if (!ct1.compare(ct2)) $fatal(1, "packet_ct clone failed");

    // Test roundtrip
    ct1.to_bytes(bytes);
    ct2 = new();
    ct2.from_bytes(bytes);
    if (!ct1.compare(ct2)) begin
      $display("  FAILED: packet_ct roundtrip: %s vs %s", ct1.sprint(), ct2.sprint());
    end else begin
      $display("  PASSED: packet_ct roundtrip");
    end
  endtask

endmodule
