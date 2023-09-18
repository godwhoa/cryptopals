const std = @import("std");
const english = @import("english.zig");
const xor = @import("xor.zig");
const hamming = @import("hamming.zig");

pub fn repeating_key(encrypted: []const u8) !xor.Key {
    const best_key_sizes = try hamming.find_key_sizes(encrypted);
    var best_key_overall: []const u8 = "";
    var best_score_overall: f64 = 0.0;

    for (best_key_sizes) |c| {
        const blocks = try transpose(encrypted, c.key_size);
        var key = std.ArrayList(u8).init(std.heap.page_allocator);
        defer key.deinit();

        var total_score: f64 = 0.0;
        for (blocks) |block| {
            const result = try best_possible_key(block);
            try key.append(result.key);
            total_score += result.score;
            std.heap.page_allocator.free(block);
        }

        if (total_score > best_score_overall) {
            best_key_overall = try key.toOwnedSlice();
            best_score_overall = total_score;
        }
        std.heap.page_allocator.free(blocks);
    }

    return xor.Key{ .repeating_key = best_key_overall };
}

const Result = struct {
    key: u8,
    score: f64,
};

fn best_possible_key(encrypted: []const u8) !Result {
    var best_key: u8 = 0;
    var best_score: f64 = 0.0;

    for (0..256) |i| {
        const fixed_key: u8 = @as(u8, @intCast(i));
        const candidate = try xor.apply(encrypted, xor.Key{ .fixed_key = fixed_key });
        const score = english.englishness_score(candidate);
        if (score > best_score) {
            best_score = score;
            best_key = fixed_key;
        }
    }

    return Result{ .key = best_key, .score = best_score };
}

fn transpose(encrypted: []const u8, key_size: usize) ![][]u8 {
    var blocks: [][]u8 = try std.heap.page_allocator.alloc([]u8, key_size);
    for (0..key_size) |i| {
        blocks[i] = try std.heap.page_allocator.alloc(u8, (encrypted.len / key_size) + 1);
    }

    for (0..encrypted.len) |i| {
        blocks[i % key_size][i / key_size] = encrypted[i];
    }

    return blocks;
}
