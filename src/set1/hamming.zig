const std = @import("std");

pub fn distance(a: []const u8, b: []const u8) !u32 {
    if (a.len != b.len) return error.InvalidInput;

    var dist: u32 = 0;
    for (0..a.len) |i| {
        dist += @popCount(a[i] ^ b[i]);
    }

    return dist;
}

pub fn mean_block_distance(key_size: u8, encrypted: []const u8) !f64 {
    var mean: f64 = 0.0;
    const max_blocks = encrypted.len / key_size;
    _ = max_blocks;

    for (0..10) |i| {
        const start = i * key_size;
        var block_a: []const u8 = encrypted[start .. start + key_size];
        var block_b: []const u8 = encrypted[start + key_size .. start + key_size * 2];
        const dist = try distance(block_a, block_b);
        const normalized = @as(f64, @floatFromInt(dist)) / @as(f64, @floatFromInt(key_size));
        mean += normalized;
        mean /= 2;
    }

    return mean;
}

const Candidate = struct {
    key_size: u8,
    mean_distance: f64,

    pub fn less_than(context: void, lhs: Candidate, rhs: Candidate) bool {
        return std.sort.asc(f64)(context, lhs.mean_distance, rhs.mean_distance);
    }
};

pub fn find_key_sizes(encrypted: []const u8) ![3]Candidate {
    var candidates = std.ArrayList(Candidate).init(std.heap.page_allocator);
    defer candidates.deinit();

    for (2..40 + 1) |key_size| {
        const ks = @as(u8, @intCast(key_size));
        var mean_distance: f64 = try mean_block_distance(ks, encrypted);
        try candidates.append(Candidate{ .key_size = ks, .mean_distance = mean_distance });
    }

    std.mem.sort(Candidate, candidates.items, {}, Candidate.less_than);

    return [3]Candidate{
        candidates.items[0],
        candidates.items[1],
        candidates.items[2],
    };
}
