const std = @import("std");
const bufferSize: i32 = 1024;

const charHashtag: u8 = 35;
const charSpace: u8 = 32;
const charNewline: u8 = 10;
const charGT: u8 = 62;

pub fn main() !void {
    const process = std.process;
    const stdReader = std.io.getStdIn().reader();
    const stdWriter = std.io.getStdOut().writer();

    var gpa = try std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const arguments = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, arguments);

    var lineBuffer: [bufferSize]u8 = undefined;

    if (arguments.len < 2) { // we should assume we received from stdin
        while (true) {
            const line = try stdReader.readUntilDelimiterOrEof(&lineBuffer, '\n') orelse break;
            try processHeaders(line);
            try processParagraphs(line);
        }
        try stdWriter.print("\n", .{});
    } else return;
}

fn processHeaders(inputStr: []u8) !void {
    //std.debug.print(" -- debug -- processHeaders processing string length: {d}\n", .{inputStr.len});
    var headerCount: u8 = 0;

    for (inputStr, 0..) |inputCharacter, inputIndex| {
        if (inputIndex == 0 and inputCharacter == charHashtag) { // Proper beginning of a header
            for (inputStr, 0..) |headerCharacter, headerIndex| {
                if (headerCharacter == charHashtag) {
                    headerCount += 1;
                    continue;
                } else if (headerCharacter == charSpace) {
                    //try std.debug.print("proper header here (H{d}): ", .{headerCount});
                    try std.io.getStdOut().writer().writeAll("\x1B[1m");
                    try std.io.getStdOut().writer().print("{s}", .{inputStr[headerIndex + 1 ..]});
                    try std.io.getStdOut().writer().print("\n", .{});

                    var x: u8 = 0;
                    while (x < inputStr.len - headerIndex) {
                        try std.io.getStdOut().writer().print("-", .{});
                        x += 1;
                    }
                    try std.io.getStdOut().writer().writeAll("\x1B[0m");
                    try std.io.getStdOut().writer().print("\n", .{});
                    break;
                }
            }
        } else break;
    }
}

fn processParagraphs(inputStr: []u8) !void {
    for (inputStr, 0..) |inputCharacter, inputIndex| {
        if (inputIndex == 0 and inputCharacter != charHashtag) {
            try std.io.getStdOut().writer().print("{s}\n", .{inputStr});
        }
    }
}
