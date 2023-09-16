const std = @import("std");
const hex = @import("hex.zig");
const base64 = @import("base64.zig");
const xor = @import("xor.zig");

test "test set 1 challenge 1" {
    const decoded = try hex.decode("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d");
    const encoded = try base64.encode(decoded);
    const expectedEncoding = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t";
    try std.testing.expectEqualStrings(encoded, expectedEncoding);
}

test "test set 1 challenge 2" {
    const src = try hex.decode("1c0111001f010100061a024b53535009181c");
    const key = try hex.decode("686974207468652062756c6c277320657965");
    const expected = try hex.decode("746865206b696420646f6e277420706c6179");
    const out = try xor.fixed_xor(src, key);
    try std.testing.expectEqualSlices(u8, out, expected);
}
