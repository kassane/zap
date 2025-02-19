const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const op = b.option([]const u8, "Example", "choice qsort examples (coro, parallel, strand [default]) to build.") orelse "strand";

    const exe = b.addExecutable("asio-qsort", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addIncludePath("vendor/asio/asio/include");
    if (std.mem.eql(u8, op, "coro")) {
        exe.addCSourceFile("src/coro-qsort.cpp", &.{
            "-Oz",
            "-Wall",
            "-Wextra",
            "-std=c++20",
            "-fno-sanitize=all",
            "-fcoroutines-ts",
        });
    } else if (std.mem.eql(u8, op, "parallel")) {
        exe.addCSourceFile("src/parallel-qsort.cpp", &.{
            "-Oz",
            "-Wall",
            "-Wextra",
            "-std=c++14",
            "-fno-sanitize=all",
        });
    } else {
        exe.addCSourceFile("src/qsort.cpp", &.{
            "-Oz",
            "-Wall",
            "-Wextra",
            "-std=c++14",
            "-fno-sanitize=all",
        });
    }
    exe.linkLibCpp();
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
