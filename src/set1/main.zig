const std = @import("std");
const hex = @import("hex.zig");
const base64 = @import("base64.zig");
const xor = @import("xor.zig");
const english = @import("english.zig");
const io = @import("io.zig");
const hamming = @import("hamming.zig");
const crack = @import("crack.zig");

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
    const out = try xor.apply(src, xor.Key{ .key = key });
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

test "test set 1 challenge 5" {
    const text = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal";
    const expected = "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f";
    const key = xor.Key{ .repeating_key = "ICE" };
    const encrypted = try xor.apply(text, key);
    const encoded = try hex.encode(encrypted);
    try std.testing.expectEqualSlices(u8, expected, encoded);
}

test "test hamming distance" {
    const dist = try hamming.distance("this is a test", "wokka wokka!!!");
    try std.testing.expectEqual(dist, 37);
}

test "test base64 encoding" {
    const raw = try io.read_all("data/s1c6.txt");
    const data = try base64.decode(raw);
    const encoded = try base64.encode(data);
    try std.testing.expectEqualSlices(u8, raw, encoded);
}

test "test set 1 challenge 6" {
    const raw = try io.read_all("data/s1c6.txt");
    const encrypted = try base64.decode(raw);

    const key = try crack.repeating_key(encrypted);
    const decrypted = try xor.apply(encrypted, key);
    try io.write_all("data/s1c6-decrypted.txt", decrypted);
    try std.testing.expectEqualSlices(u8, "Terminator X: Bring the noise", key.repeating_key);
}

pub fn main() !void {}
