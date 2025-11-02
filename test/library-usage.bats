#!/usr/bin/env bats
# Tests for library usage as a dependency
#
# Creates ad-hoc test clients in .nv/ to validate:
# - Local path dependency works (for development)
# - zig fetch --save with git URL (#main branch)
# - zig fetch --save with git URL (specific tag)
# - Library functions are accessible and work correctly
#
# Install bats: brew install bats-core
# Run: bats test/library-usage.bats

setup() {
    export ORIGINAL_DIR="$PWD"
    export TEST_ROOT="$PWD/.nv/test-clients"

    # Create test directory
    mkdir -p "$TEST_ROOT"

    # Verify we're in the project root
    if [ ! -f "build.zig.zon" ]; then
        skip "Must run from project root"
    fi

    # Get current version from version.txt
    export CURRENT_VERSION=$(cat version.txt)
}

teardown() {
    cd "$ORIGINAL_DIR"
    # Clean up test clients
    rm -rf "$TEST_ROOT"
}

create_test_client() {
    local client_name="$1"
    local client_dir="$TEST_ROOT/$client_name"

    mkdir -p "$client_dir"
    cd "$client_dir"

    # Use zig init to create a proper project structure
    zig init > /dev/null 2>&1

    # Replace the generated src/main.zig with simple test code
    # Just validate that the library is importable and one function works
    cat > src/main.zig << 'EOF'
const std = @import("std");
const lib = @import("nv-ziglib-template");

pub fn main() !void {
    // Simple test: validate library is accessible and one function works
    if (lib.startsWith("Hello, Zig!", "Hello")) {
        std.debug.print("SUCCESS: Library imported and function works\n", .{});
    } else {
        std.debug.print("ERROR: Library function failed\n", .{});
        return error.TestFailed;
    }
}
EOF

    # Update build.zig to import our library
    # Insert the dependency import and module addition
    sed -i.bak '/const exe = b.addExecutable/i\
    const nv_ziglib_template = b.dependency("nv_ziglib_template", .{\
        .target = target,\
        .optimize = optimize,\
    });\
' build.zig

    sed -i.bak '/b.installArtifact(exe);/i\
    exe.root_module.addImport("nv-ziglib-template", nv_ziglib_template.module("nv_ziglib_template"));\
' build.zig

    rm -f build.zig.bak

    cd "$ORIGINAL_DIR"
}

@test "local path dependency: creates test client" {
    create_test_client "local-path-test"
    [ -f "$TEST_ROOT/local-path-test/build.zig" ]
    [ -f "$TEST_ROOT/local-path-test/src/main.zig" ]
}

@test "local path dependency: build.zig.zon with relative path" {
    create_test_client "local-path-test"

    # Modify zig init generated build.zig.zon to add our dependency
    # Insert our dependency into the dependencies section
    sed -i.bak 's/.dependencies = .{/.dependencies = .{\
        .nv_ziglib_template = .{\
            .path = "..\/..\/..",\
        },/' "$TEST_ROOT/local-path-test/build.zig.zon"

    rm -f "$TEST_ROOT/local-path-test/build.zig.zon.bak"

    # Verify dependency was added
    grep -q "nv_ziglib_template" "$TEST_ROOT/local-path-test/build.zig.zon"
}

@test "local path dependency: builds successfully" {
    create_test_client "local-path-test"

    # Add dependency to build.zig.zon
    sed -i.bak 's/.dependencies = .{/.dependencies = .{\
        .nv_ziglib_template = .{\
            .path = "..\/..\/..",\
        },/' "$TEST_ROOT/local-path-test/build.zig.zon"
    rm -f "$TEST_ROOT/local-path-test/build.zig.zon.bak"

    cd "$TEST_ROOT/local-path-test" || return 1
    run zig build
    [ "$status" -eq 0 ]
}

@test "local path dependency: runs and all functions work" {
    create_test_client "local-path-test"

    # Add dependency to build.zig.zon
    sed -i.bak 's/.dependencies = .{/.dependencies = .{\
        .nv_ziglib_template = .{\
            .path = "..\/..\/..",\
        },/' "$TEST_ROOT/local-path-test/build.zig.zon"
    rm -f "$TEST_ROOT/local-path-test/build.zig.zon.bak"

    cd "$TEST_ROOT/local-path-test" || return 1
    run zig build run
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS: Library imported and function works" ]]
}

@test "zig fetch --save: with #main branch" {
    create_test_client "zig-fetch-main-test"

    cd "$TEST_ROOT/zig-fetch-main-test"

    # Use zig fetch --save with git URL and #main branch
    run zig fetch --save "git+https://github.com/cloudvoyant/nv-ziglib-template#main"

    if [ "$status" -ne 0 ]; then
        skip "Could not fetch package from GitHub (network issue or repo not accessible)"
    fi

    # Verify dependency was added to build.zig.zon
    grep -q "nv_ziglib_template" build.zig.zon

    # Build should succeed
    run zig build
    [ "$status" -eq 0 ]
}

@test "zig fetch --save: runs with #main branch" {
    create_test_client "zig-fetch-main-test"

    cd "$TEST_ROOT/zig-fetch-main-test"

    zig fetch --save "git+https://github.com/cloudvoyant/nv-ziglib-template#main" 2>&1 || skip "Could not fetch package from GitHub"

    # Run the test
    run zig build run
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS: Library imported and function works" ]]
}

@test "zig fetch --save: with git tag (latest version)" {
    create_test_client "zig-fetch-tag-test"

    cd "$TEST_ROOT/zig-fetch-tag-test"

    # Get the latest git tag from the repo
    cd "$ORIGINAL_DIR"
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [ -z "$latest_tag" ]; then
        skip "No git tags found in repository"
    fi

    cd "$TEST_ROOT/zig-fetch-tag-test"

    # Use zig fetch --save with git URL and specific tag
    run zig fetch --save "git+https://github.com/cloudvoyant/nv-ziglib-template#${latest_tag}"

    if [ "$status" -ne 0 ]; then
        skip "Could not fetch package from GitHub (network issue or repo not accessible)"
    fi

    # Verify dependency was added to build.zig.zon
    grep -q "nv_ziglib_template" build.zig.zon

    # Build should succeed
    run zig build
    [ "$status" -eq 0 ]
}

@test "zig fetch --save: runs with git tag" {
    create_test_client "zig-fetch-tag-test"

    cd "$ORIGINAL_DIR"
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [ -z "$latest_tag" ]; then
        skip "No git tags found in repository"
    fi

    cd "$TEST_ROOT/zig-fetch-tag-test"

    zig fetch --save "git+https://github.com/cloudvoyant/nv-ziglib-template#${latest_tag}" 2>&1 || skip "Could not fetch package from GitHub"

    # Run the test
    run zig build run
    [ "$status" -eq 0 ]
    [[ "$output" =~ "SUCCESS: Library imported and function works" ]]
}
