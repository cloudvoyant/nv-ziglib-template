const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create library module
    const lib_mod = b.addModule("nv_ziglib_template", .{
        .root_source_file = b.path("src/lib.zig"),
    });
    _ = lib_mod;

    // Tests
    const lib_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);

    // Example executable
    const exe = b.addExecutable(.{
        .name = "nv-ziglib-template",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    run_exe.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run example");
    run_step.dependOn(&run_exe.step);
}
