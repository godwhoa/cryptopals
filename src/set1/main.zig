const std = @import("std");
const hex = @import("hex.zig");
const base64 = @import("base64.zig");
const xor = @import("xor.zig");
const english = @import("english.zig");
const io = @import("io.zig");

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
    const out = try xor.fixed_xor(src, xor.Key{ .key = key });
    try std.testing.expectEqualSlices(u8, out, expected);
}

test "test set 1 challenge 3" {
    const encrypted = try hex.decode("1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736");
    const candidates = try xor.decipher(encrypted);
    const top = try english.most_english_like(candidates);
    const expected = "Cooking MC's like a pound of bacon";
    try std.testing.expectEqualStrings(top, expected);
}

test "test set 1 challenge 4" {
    const chiphers = try io.read_lines("data/s1c4.txt");
    const allocator = std.heap.page_allocator;
    var candidates = std.ArrayList([]u8).init(allocator);
    defer candidates.deinit();
    for (chiphers) |chipher| {
        const decoded = try hex.decode(chipher);
        const possible_candidates = try xor.decipher(decoded);
        const top_candidate = try english.most_english_like(possible_candidates);
        try candidates.append(top_candidate);
    }
    const top = try english.most_english_like(candidates.items);
    const expected = "Now that the party is jumping\n";
    try std.testing.expectEqualStrings(top, expected);
}

pub fn main() !void {
    const chiphers = try io.read_lines("data/s1c4.txt");
    const allocator = std.heap.page_allocator;
    var candidates = std.ArrayList([]u8).init(allocator);
    defer candidates.deinit();
    for (chiphers) |chipher| {
        const decoded = try hex.decode(chipher);
        const possible_candidates = try xor.decipher(decoded);
        const top_candidate = try english.most_english_like(possible_candidates);
        try candidates.append(top_candidate);
    }
    const top = try english.most_english_like(candidates.items);
    std.debug.print("top: {s}\n", .{top});
}
