const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const install_all = b.step("install_all", "Install all days");
    const run_all = b.step("run_all", "Run all days");

    // Set up an exe for each day
    var day: u32 = 1;
    while (day <= 25) : (day += 1) {
        const dayString = b.fmt("day{:0>2}", .{day});
        const zigFile = b.fmt("src/{s}.zig", .{dayString});

        const exe = b.addExecutable(dayString, zigFile);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        deps.addAllTo(exe);

        exe.install();

        const install_cmd = b.addInstallArtifact(exe);

        const step_key = b.fmt("install_{s}", .{dayString});
        const step_desc = b.fmt("Install {s}.exe", .{dayString});
        const install_step = b.step(step_key, step_desc);
        install_step.dependOn(&install_cmd.step);
        install_all.dependOn(&install_cmd.step);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(&install_cmd.step);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_desc = b.fmt("Run {s}", .{dayString});
        const run_step = b.step(dayString, run_desc);
        run_step.dependOn(&run_cmd.step);
        run_all.dependOn(&run_cmd.step);
    }
}
