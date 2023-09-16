const std = @import("std");
const hex = @import("hex.zig");
const base64 = @import("base64.zig");

test "test set 1 challenge 1" {
    const decoded = try hex.decode("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d");
    const encoded = try base64.encode(decoded);
    const expectedEncoding = "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t";
    try std.testing.expectEqualStrings(encoded, expectedEncoding);
}

pub fn main() !void {
    const decoded = "M";
    const encoded = try base64.encode(decoded);
    std.debug.print("Encoded: {s}\n", .{encoded});
}
