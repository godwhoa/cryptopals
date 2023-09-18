const std = @import("std");

pub fn read_lines(path: []const u8) ![][]u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var lines = std.ArrayList([]u8).init(std.heap.page_allocator);
    defer lines.deinit();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    while (true) {
        const line = in_stream.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 64) catch |err| {
            if (err == error.EndOfStream) {
                break;
            } else return err;
        };
        try lines.append(line);
    }
    return lines.toOwnedSlice();
}

pub fn read_all(path: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var data = std.ArrayList(u8).init(std.heap.page_allocator);
    defer data.deinit();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    while (true) {
        const line = in_stream.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 1024) catch |err| {
            if (err == error.EndOfStream) {
                break;
            } else return err;
        };
        try data.appendSlice(line);
    }
    return data.toOwnedSlice();
}

pub fn write_all(path: []const u8, data: []const u8) !void {
    var file = try std.fs.cwd().openFile(path, .{ .mode = .read_write });
    defer file.close();
    return file.writeAll(data);
}
