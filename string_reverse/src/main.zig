const std = @import("std");
const writer = std.io.getStdOut().writer();
const heap = std.heap;
const mem = std.mem;
const process = std.process;

const error_no_space = error{no_space_error};

pub fn main() !void {
    const main_sentence = "erff, this is my main program sentence";
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const main_allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const new_string = try string_reverse(main_allocator, main_sentence);
    defer main_allocator.free(new_string);

    try writer.print("MAIN REVERSE: {s}\n", .{new_string});
}

pub fn string_reverse(allocator: mem.Allocator, input_string: []const u8) ![]u8 {
    var new_string_arraylist = std.ArrayList(u8).init(allocator);
    defer new_string_arraylist.deinit();

    const input_string_endbyte: usize = input_string.len - 1;
    var i: usize = input_string_endbyte;
    while (true) : (i -= 1) {
        try new_string_arraylist.append(input_string[i]);
        if (i == 0) break;
    }

    const new_string = try new_string_arraylist.toOwnedSlice();
    //new_string_arraylist.clearRetainingCapacity();
    return new_string;
}

test "simple test" {
    const test_sentence = "hi this is my awesome test sentence";
    const test_allocator = std.testing.allocator;

    const new_string = try string_reverse(test_allocator, test_sentence);
    defer test_allocator.free(new_string);

    std.debug.print("TEST REVERSE: {s}\n", .{new_string});
    try std.testing.expectEqualStrings("ecnetnes tset emosewa ym si siht ih", new_string);
}
