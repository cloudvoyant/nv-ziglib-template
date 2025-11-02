const std = @import("std");
const testing = std.testing;

/// Checks if a string starts with a given prefix
pub fn startsWith(str: []const u8, prefix: []const u8) bool {
    if (prefix.len > str.len) return false;
    return std.mem.eql(u8, str[0..prefix.len], prefix);
}

/// Checks if a string ends with a given suffix
pub fn endsWith(str: []const u8, suffix: []const u8) bool {
    if (suffix.len > str.len) return false;
    return std.mem.eql(u8, str[str.len - suffix.len ..], suffix);
}

/// Counts the number of occurrences of a substring in a string
pub fn countOccurrences(str: []const u8, needle: []const u8) usize {
    if (needle.len == 0) return 0;
    var count: usize = 0;
    var i: usize = 0;
    while (i + needle.len <= str.len) {
        if (std.mem.eql(u8, str[i .. i + needle.len], needle)) {
            count += 1;
            i += needle.len;
        } else {
            i += 1;
        }
    }
    return count;
}

/// Reverses a string, allocating a new buffer
pub fn reverse(allocator: std.mem.Allocator, str: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, str.len);
    var i: usize = 0;
    while (i < str.len) : (i += 1) {
        result[str.len - 1 - i] = str[i];
    }
    return result;
}

// Tests
test "startsWith returns true for matching prefix" {
    try testing.expect(startsWith("hello world", "hello"));
    try testing.expect(startsWith("hello world", "h"));
    try testing.expect(startsWith("hello world", ""));
}

test "startsWith returns false for non-matching prefix" {
    try testing.expect(!startsWith("hello world", "world"));
    try testing.expect(!startsWith("hello world", "Hello"));
    try testing.expect(!startsWith("hi", "hello"));
}

test "endsWith returns true for matching suffix" {
    try testing.expect(endsWith("hello world", "world"));
    try testing.expect(endsWith("hello world", "d"));
    try testing.expect(endsWith("hello world", ""));
}

test "endsWith returns false for non-matching suffix" {
    try testing.expect(!endsWith("hello world", "hello"));
    try testing.expect(!endsWith("hello world", "World"));
    try testing.expect(!endsWith("hi", "world"));
}

test "countOccurrences finds all occurrences" {
    try testing.expectEqual(@as(usize, 2), countOccurrences("hello hello", "hello"));
    try testing.expectEqual(@as(usize, 2), countOccurrences("aaaa", "aa"));
    try testing.expectEqual(@as(usize, 0), countOccurrences("hello", "world"));
    try testing.expectEqual(@as(usize, 0), countOccurrences("hello", ""));
}

test "reverse creates reversed string" {
    const allocator = testing.allocator;
    const reversed = try reverse(allocator, "hello");
    defer allocator.free(reversed);
    try testing.expectEqualStrings("olleh", reversed);
}

test "reverse handles empty string" {
    const allocator = testing.allocator;
    const reversed = try reverse(allocator, "");
    defer allocator.free(reversed);
    try testing.expectEqualStrings("", reversed);
}
