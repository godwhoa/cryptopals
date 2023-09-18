const std = @import("std");

pub const KeyTypeTag = enum {
    key,
    fixed_key,
    repeating_key,
};

pub const Key = union(KeyTypeTag) {
    key: []const u8,
    fixed_key: u8,
    repeating_key: []const u8,
};

pub fn apply(src: []const u8, key: Key) ![]u8 {
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
        KeyTypeTag.repeating_key => |k| {
            for (0..src.len) |i| {
                // std.debug.print("{c}", .{k[i % k.len]});
                dst[i] = src[i] ^ k[i % k.len];
            }
        },
    }

    return dst;
}

pub fn decipher(encrypted: []const u8) ![][]u8 {
    const allocator = std.heap.page_allocator;
    var candidates = std.ArrayList([]u8).init(allocator);

    for (0..256) |i| {
        const fixed_key: u8 = @truncate(i);
        const candidate = try apply(encrypted, Key{ .fixed_key = fixed_key });
        try candidates.append(candidate);
    }

    return candidates.toOwnedSlice();
}
