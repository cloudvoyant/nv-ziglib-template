const std = @import("std");
const lib = @import("lib.zig");

pub fn main() !void {
    std.debug.print("String Utilities Library Demo\n", .{});
    std.debug.print("=============================\n\n", .{});

    const test_string = "Hello, Zig!";
    std.debug.print("Test string: \"{s}\"\n\n", .{test_string});

    // Test startsWith
    std.debug.print("Starts with \"Hello\": {}\n", .{lib.startsWith(test_string, "Hello")});
    std.debug.print("Starts with \"Zig\": {}\n", .{lib.startsWith(test_string, "Zig")});

    // Test endsWith
    std.debug.print("Ends with \"Zig!\": {}\n", .{lib.endsWith(test_string, "Zig!")});
    std.debug.print("Ends with \"Hello\": {}\n", .{lib.endsWith(test_string, "Hello")});

    // Test countOccurrences
    const repeat_string = "banana";
    std.debug.print("\nCounting 'an' in \"{s}\": {}\n", .{ repeat_string, lib.countOccurrences(repeat_string, "an") });

    // Test reverse
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const reversed = try lib.reverse(allocator, test_string);
    defer allocator.free(reversed);
    std.debug.print("\nReversed: \"{s}\"\n", .{reversed});
}
