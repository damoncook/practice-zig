const std = @import("std");
const writer = std.io.getStdOut().writer();
const reader = std.io.getStdIn().reader();
const heap = std.heap;
const mem = std.mem;
const process = std.process;

const SearchError = error{NotFound};

pub fn main() !u8 {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const main_allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var in_buffer: [4096]u8 = undefined;
    _ = try reader.readUntilDelimiterOrEof(&in_buffer, '\n');
    const in_string: []u8 = in_buffer[0..];

    const search_string: ?[]const u8 = processArguments(main_allocator);

    if (search_string) |_| {
        const processed_string: []const u8 = processInput(main_allocator, in_string, search_string) catch {
            try writer.print("search string not found.\n", .{});
            return 1;
        };
        try writer.print("{s}", .{processed_string});
    } else {
        try writer.print("no search string provided.\n", .{});
        return 1;
    }

    return 0; // return success (found string)
}

fn processInput(allocator: mem.Allocator, input_buffer: []const u8, search_string: ?[]const u8) ![]const u8 {
    var new_string = std.ArrayList(u8).init(allocator);
    defer new_string.deinit();

    if (mem.indexOf(u8, input_buffer, search_string.?)) |_| {
        return "found search string.\n";
    } else return error.NotFound;
}

fn processArguments(allocator: mem.Allocator) ?[]const u8 {
    var args = try process.argsWithAllocator(allocator);
    defer args.deinit();

    var argIndex: usize = 0;
    while (args.next()) |arg| {
        if (argIndex == 1) {
            return arg;
        } else {
            argIndex += 1;
            continue;
        }
    }

    return null;
}

test "grep success test" {
    const test_sentence = "hi this is my awesome test sentence";
    const test_allocator = std.testing.allocator;

    const found_string = try processInput(test_allocator, test_sentence, "this");
    try std.testing.expectEqualStrings("found search string.\n", found_string);
}

test "grep fail test" {
    const test_sentence = "hi this is my awesome test sentence";
    const test_allocator = std.testing.allocator;

    const not_found_string: SearchError![]const u8 = processInput(test_allocator, test_sentence, "banana");
    try std.testing.expectError(SearchError.NotFound, not_found_string);
}
