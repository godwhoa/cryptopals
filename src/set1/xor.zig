const std = @import("std");

pub fn fixed_xor(src: []const u8, key: []const u8) ![]u8 {
    if (src.len != key.len) return error.InvalidInput;

    const allocator = std.heap.page_allocator;
    var dst = try allocator.alloc(u8, src.len);

    for (0..src.len) |i| {
        dst[i] = src[i] ^ key[i];
    }

    return dst;
}
