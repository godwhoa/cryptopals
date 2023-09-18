const std = @import("std");

pub const KeyTypeTag = enum {
    key,
    fixed_key,
};

pub const Key = union(KeyTypeTag) {
    key: []const u8,
    fixed_key: u8,
};

pub fn simd_xor(src: [30]u8, key: u8) [30]u8 {
    const a: @Vector(30, u8) = src;
    const b: @Vector(30, u8) = @splat(key);
    return a ^ b;
}

pub fn fixed_xor(src: []const u8, key: Key) ![]u8 {
    const allocator = std.heap.page_allocator;
    var dst = try allocator.alloc(u8, src.len);

    switch (key) {
        KeyTypeTag.key => |k| {
            for (0..src.len) |i| {
                dst[i] = src[i] ^ k[i];
            }
        },
        KeyTypeTag.fixed_key => |k| {
            for (0..src.len) |i| {
                dst[i] = src[i] ^ k;
            }
        },
    }

    return dst;
}

pub fn decipher(encrypted: [30]u8) ![][30]u8 {
    const allocator = std.heap.page_allocator;
    var candidates = std.ArrayList([30]u8).init(allocator);

    for (0..256) |i| {
        const fixed_key: u8 = @truncate(i);
        const candidate = simd_xor(encrypted, fixed_key);
        try candidates.append(candidate);
    }

    return candidates.toOwnedSlice();
}
