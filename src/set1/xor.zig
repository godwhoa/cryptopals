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

pub fn decipher(encrypted: []const u8) ![][]u8 {
    const allocator = std.heap.page_allocator;
    var candidates = std.ArrayList([]u8).init(allocator);
    var key = try allocator.alloc(u8, encrypted.len);
    defer allocator.free(key);

    for (0..256) |i| {
        for (0..encrypted.len) |j| {
            key[j] = @truncate(i);
        }
        const candidate = try fixed_xor(encrypted, key);
        try candidates.append(candidate);
    }

    return candidates.toOwnedSlice();
}
