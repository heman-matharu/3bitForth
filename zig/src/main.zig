const std = @import("std");
const print = std.debug.print;

const ray = @cImport({
    @cInclude("raylib.h");
});

// Combinatorial Blocks

var muxB: u12 = undefined;
var muxA: u12 = undefined;
var muxC: u3 = 0;
var muxD: u3 = undefined;
var alu: u3 = undefined;

fn setA(address: u12) void {
    muxA = address;
}

// Registers - Sequential/Clocked:

var regH: [4]u3 = [_]u3{0} ** 4; // kernel mode inst ptr
var regI: [4]u3 = [_]u3{ 0, 0, 0, 0 };
var regJ: [4]u3 = [_]u3{0} ** 4;
var regS: [4]u3 = [_]u3{0} ** 4; // note [S] is only 11b.
var regD: [4_096]u3 = [_]u3{0} ** 4_096;
var regT: u3 = 0;
var regF: [2]u1 = [2]u1{ 0, 0 };
var regQ: u3 = 0;
var regP: u3 = 0;

fn setT() void {
    regT = muxC;
}

fn setF0(value: u1) void {
    regF[0] = value;
}

fn setF1(value: u1) void {
    regF[1] = value;
}

//-----------------------------------------------------------------------------
fn setD() void {
    const address = muxA; // & 03777; // TEMP HACK, ROM folded onto RAM.
    const data = regT;
    regD[address] = data;
    // ramu();
}
// no reset. Init above.

fn valD() u3 {
    return regD[muxA];
}

fn setQ() void {
    regQ = alu;
}

//-----------------------------------------------------------------------------

fn setI() void {
    setI_(valJ());
}
fn setI_(t: u12) void {
    regI[0] = @intCast(@mod(t, 8));
    regI[1] = @intCast(@mod(@divFloor(t, 8), 8));
    regI[2] = @intCast(@mod(@divFloor(t, 64), 8));
    regI[3] = @intCast(@mod(@divFloor(t, 512), 8));
    // regI[3] = regI[3]; // & 03; // TEMP HACK, ROM folded onto RAM.
}

fn incI() void {
    var t = valI();
    t += 1;
    if (t == 2048) { // wrap-around to 0000 (not 0100, less gates).
        regI[0] = 0;
        regI[1] = 0;
        regI[2] = 0;
        regI[3] = 0;
    } else {
        regI[0] = @truncate(@mod(t, 8));
        regI[1] = @truncate(@mod(@divFloor(t, 8), 8));
        regI[2] = @truncate(@mod(@divFloor(t, 64), 8));
        regI[3] = @truncate(@mod(@divFloor(t, 512), 8));
    }
    regI[3] = regI[3]; // & 03; // TEMP HACK, ROM folded onto RAM.

}

fn decI() void {
    var t = valI();
    t -= 1;
    if (t == 2048) { // wrap-around to 0000 (not 0100, less gates).
        regI[0] = 0;
        regI[1] = 0;
        regI[2] = 0;
        regI[3] = 0;
    } else {
        regI[0] = @truncate(@mod(t, 8));
        regI[1] = @truncate(@mod(@divFloor(t, 8), 8));
        regI[2] = @truncate(@mod(@divFloor(t, 64), 8));
        regI[3] = @truncate(@mod(@divFloor(t, 512), 8));
    }
    regI[3] = regI[3]; // & 03; // TEMP HACK, ROM folded onto RAM.

}

fn valI() u12 {
    const regI0: u12 = @intCast(regI[0]);
    const regI1: u12 = @intCast(regI[1]);
    const regI2: u12 = @intCast(regI[2]);
    const regI3: u12 = @intCast(regI[3]);
    return regI3 * 512 + regI2 * 64 + regI1 * 8 + regI0;
}

//-----------------------------------------------------------------------------

fn setH() void {
    setH_(valJ());
}

fn setH_(t: u12) void {
    regH[0] = @intCast(@mod(t, 8));
    regH[1] = @intCast(@mod(@divFloor(t, 8), 8));
}

fn incH() void {
    var t = valH();
    t += 1;
    if (t == 4096) { // wrap-around to 7700 (not 0100, less gates).
        regH[0] = 0;
        regH[1] = 0;
    } else {
        regH[0] = @mod(t, 8);
        regH[1] = @mod(@divFloor(t, 8), 8);
    }
    setA(valH());
}

fn valH() u12 {
    const regH0: u12 = regH[0];
    const regH1: u12 = regH[1];
    return (7 * 512) + (7 * 64) + (regH1 * 8) + regH0;
}

//-----------------------------------------------------------------------------
// clock blocks

fn setJ() void {
    regJ[0] = @intCast(@mod(muxB, 8));
    regJ[1] = @intCast(@mod(@divFloor(muxB, 8), 8));
    regJ[2] = @intCast(@mod(@divFloor(muxB, 64), 8));
    regJ[3] = @intCast(@mod(@divFloor(muxB, 512), 8));
}

fn valJ() u12 {
    const regJ0: u12 = regJ[0];
    const regJ1: u12 = regJ[1];
    const regJ2: u12 = regJ[2];
    const regJ3: u12 = regJ[3];
    return regJ3 * 512 + regJ2 * 64 + regJ1 * 8 + regJ0;
}

fn incJ() void {
    var t = valJ();
    t += 1;
    if (t == 2048) { // wrap-around to 0000 (not 0100, less gates).
        regJ[0] = 0;
        regJ[1] = 0;
        regJ[2] = 0;
        regJ[3] = 0;
    } else {
        regJ[0] = @truncate(@mod(t, 8));
        regJ[1] = @truncate(@mod(@divFloor(t, 8), 8));
        regJ[2] = @truncate(@mod(@divFloor(t, 64), 8));
        regJ[3] = @truncate(@mod(@divFloor(t, 512), 8));
    }
    regJ[3] = regJ[3]; // & 03; // TEMP HACK, ROM folded onto RAM.

}

//-----------------------------------------------------------------------------
// clock blocks

fn setS() void {
    regS[0] = @truncate(@mod(muxA, 8));
    regS[1] = @truncate(@mod(@divFloor(muxA, 8), 8));
    // regS[2] = @truncate(@mod(@divFloor(muxA, 64), 8));
    // regS[3] = @truncate(@mod(@divFloor(muxA, 512), 8));
    setS_();
}

fn setS_() void {
    if (regS[3] >= 0x4) {
        @panic("[OOPS] Stack ptr only 11b. (s3>=4) will be in ROM: s3=");
    }
}

fn resetS() void {
    regS[0] = 0;
    regS[1] = @mod(@divFloor(32, 8), 8);
    regS[2] = @mod(@divFloor(32, 64), 8);
    regS[3] = @mod(@divFloor(32, 512), 8);
}

fn valS() u12 {
    const regS0: u12 = regS[0];
    const regS1: u12 = regS[1];
    const regS2: u12 = regS[2];
    const regS3: u12 = regS[3];
    return ((regS3 << 9) + (regS2 << 6) + (regS1 << 3) + regS0);
}

fn incS() void {
    var t = valS();
    t += 1;
    if (t == 2048) { // wrap-around to 0000
        regS[0] = 0;
        regS[1] = 0;
        regS[2] = 0;
        regS[3] = 0;
    } else {
        regS[0] = @truncate(@mod(t, 8));
        regS[1] = @truncate(@mod(@divFloor(t, 8), 8));
        regS[2] = @truncate(@mod(@divFloor(t, 64), 8));
        regS[3] = @truncate(@mod(@divFloor(t, 512), 8));
    }
    if (regS[1] == 6) {
        setF1(1); // set inst.pointer to trap handler [H].
    }
    setS_();
}

fn decS() void {
    var t = valS();
    t -= 1;
    if (t == -1) { // wrap-around to 2048
        regS[0] = 7;
        regS[1] = 7;
        regS[3] = 7;
        regS[1] = 7;
    } else {
        regS[0] = @truncate(@mod(t, 8));
        regS[1] = @truncate(@mod(@divFloor(t, 8), 8));
        regS[2] = @truncate(@mod(@divFloor(t, 64), 8));
        regS[3] = @truncate(@mod(@divFloor(t, 512), 8));
    }
    if (regS[1] == 0) {
        setF1(1); // set inst.pointer to trap handler [H].
    }
    setS_();
}

//-----------------------------------------------------------------------------
// Instruction decoder

var phase: u1 = 0;

fn step() void {
    peckOn(valI());
    if (phase == 0) {
        setS_();
        setA(valI());
        step0();
        phase = 1;
    } else {
        step1();
        phase = 0;
        // flip muxA only if [S] or [J] used.
    }
}

fn step0() void {
    if (regF[1] == 0) {
        setA(valI());
    } else {
        setA(valH()); // kernel trap on stack over-/underflow.
    }
}

fn step1() void {
    switch (valD()) {
        0 => {
            doBlk();
            incI();
        },
        1 => {
            doRit();
            incI();
        },
        2 => {
            doGet();
            incI();
        },
        3 => {
            doYnk();
            incI();
        },
        4 => {
            doDbl();
            incI();
        },
        5 => {
            doMin();
            incI();
        },
        6 => {
            doCal();
        },
        7 => {
            doWit();
            incI();
        },
    }
}

//-----------------------------------------------------------------------------
// [K] BLK ::= [T] = ([T]<<1 | 0);
fn doBlk() void {
    //regF[0] = (regT >> 2);
    //document.getElementById("f0").className = "c" + regF[0];
    const T: u4 = regT << 1;
    alu = @truncate(@mod(T, 8));
    muxD = alu;
    muxC = muxD;
    setT();
    //wireup(["z0", "z2"]);
}

// [W] WIT ::= [T] = ([T]<<1 | 1);
fn doWit() void {
    //regF[0] = (regT >> 2);
    //document.getElementById("f0").className = "c" + regF[0];
    const T: u4 = regT << 1;
    alu = @truncate(@mod(T, 8) + 1);
    muxD = alu;
    muxC = muxD;
    setT();
    //wireup(["z0", "z2"]);
}

// [B] DBL ::= [S]++; [S]->[A]; [T] -> [D];
fn doDbl() void {
    //document.getElementById("k0").className = "c0";
    //document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    decS(); // CLK
    setA(valS()); // COMB
    setD(); //CLK
    //wireup(["z9", "z5"]);
}

// [M] MIN ::= [S]->[A]; ([D] - [T]) -> [F][T]; [S]--;
fn doMin() void {
    setA(valS());
    //document.getElementById("k0").className = "c0";
    //document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    const subraction = @subWithOverflow(valD(), regT);
    if (subraction[1] != 0) {
        alu = subraction[0];
        muxD = alu;
        muxC = muxD;
        setT();
        setF0(1);
    } else {
        alu = subraction[0];
        muxD = alu;
        muxC = muxD;
        setT();
        setF0(0);
    }
    incS();
    //wireup(["z9", "z2"]);
}

// [C] CAL ::= if ![F] { [I] <-> [J] } else { NOOP };
fn doCal() void {
    setF1(0); // end trap-handler [H]. Swap [J] <-> [I], and use [I].
    if (regF[0] != 0) {
        setA(valI()); // was: muxA = valI();
        muxB = muxA;
        setI(); // sets regI to value of regJ, !Though this technically should change the value of muxB to I
        setJ(); // however, muxB is still the old value of I
        //wireup(["z3", "z6", "z8"]);
        setF0(0);
    } else {
        incI();
    }
}

// [Y] YNK ::= switch([T]) --->
fn doYnk() void {
    switch (regT) {
        0 => doYnkSJ(),
        1 => doYnkJS(),
        2 => doYnkTQ(),
        3 => doYnkPT(),
        4 => doYnkDJ0(),
        5 => doYnkDJ1(),
        6 => doYnkDJ2(),
        7 => doYnkDJ3(),
    }
}

// [Y] 0: "00" + [S0][S1] -> [J0][J1]; pop;
fn doYnkSJ() void {
    setA(valS());
    //document.getElementById("k0").className = "c0";
    //document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    muxB = muxA;
    setJ();
    alu = (valD());
    muxD = alu;
    muxC = muxD;
    setT();
    incS(); // pop;
    //wireup(["z5", "z8"]);
}

// [Y] 1: [J0][J1] -> [S0][S1]
fn doYnkJS() void {
    setA(valJ());
    //document.getElementById("k0").className = "c0";
    //document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    setS();
    //wireup(["z3", "z8"]);
}

// [Y] 2: [D] -> [Q] -> [T] (IO out); pop;
fn doYnkTQ() void {
    setA(valS());
    //document.getElementById("k0").className = "c0";
    //document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    alu = (valD());
    setQ();
    muxD = alu;
    muxC = muxD;
    setT();
    incS(); // pop
    //wireup(["z2"]);
}

// [Y] 3: [P] -> [T] (IO in)
fn doYnkPT() void {
    muxD = regP;
    muxC = muxD;
    setT();
    //wireup(["z4", "z2"]);
}

// [Y] 4: [T] <-> [J0]
fn doYnkDJ0() void {
    setA(valS());
    muxC = regJ[0];
    // print("valJ() is {d}\n", .{valJ()});
    // print("value of valJ() and 0o7770 is {d}\n", .{valJ()});
    // print("Value of valD() is {d}\n", .{valD()});
    muxB = ((valJ() & 0o7770) | valD()); // or gated enable for each peck?
    const j0: u3 = @intCast(@mod(muxB, 8));
    // print("Muxb is {d}\n", .{muxB});
    print("the value of J[0] is {d}\n", .{j0});
    setT();
    setJ();
    incS();
    // wireup(["z1"]);
}

// [Y] 5: [T] <-> [J1]
fn doYnkDJ1() void {
    setA(valS());
    muxC = regJ[1];
    const d: u12 = valD();
    const D: u12 = d << 3;
    // print("valJ() is {d}\n", .{valJ()});
    // print("value of valJ() and 0o7770 is {d}\n", .{valJ()});
    // print("Value of valD() << 3 is {d}\n", .{D});
    muxB = ((valJ() & 0o7707) | D);
    // print("Muxb is {d}\n", .{muxB});
    const j1: u3 = @intCast(@mod(@divFloor(muxB, 8), 8));
    print("the value of J[1] is {d}\n", .{j1});
    setT();
    setJ();
    incS();
    //wireup(["z1"]);
}

// [Y] 6: [T] <-> [J2]
fn doYnkDJ2() void {
    setA(valS());
    const d: u12 = valD();
    const D: u12 = d << 6;
    muxC = regJ[2];
    // print("valJ() is {d}\n", .{valJ()});
    // print("value of valJ() and 0o7770 is {d}\n", .{valJ()});
    // print("Value of valD() << 6 is {d}\n", .{D});
    muxB = ((valJ() & 0o7077) | D);
    // print("Muxb is {d}\n", .{muxB});
    const j2: u3 = @intCast(@mod(@divFloor(muxB, 64), 8));
    print("the value of J[2] is {d}\n", .{j2});
    setT();
    setJ();
    incS();
    //wireup(["z1"]);
}

// [Y] 7: [T] <-> [J3]
fn doYnkDJ3() void {
    setA(valS());
    const d: u12 = valD();
    const D: u12 = d << 9;
    muxC = regJ[3];
    // print("valJ() is {d}\n", .{valJ()});
    // print("value of valJ() and 0o7770 is {d}\n", .{valJ()});
    // print("Value of valD() << 9 is {d}\n", .{D});
    muxB = ((valJ() & 0o0777) | D);
    // print("Muxb is {d}\n", .{muxB});
    const j3: u3 = @intCast(@mod(@divFloor(muxB, 512), 8));
    print("the value of J[3] is {d}\n", .{j3});
    setT();
    setJ();
    incS();
    //wireup(["z1"]);
}

// [R] RIT ::= [J]->[A]; [T]->[D];
fn doRit() void {
    setA(valJ());
    //document.getElementById("k0").className = "c0";
    //document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    setD();
    incJ();
    //wireup(["z3", "z9"]);
}

// [G] GET ::= [J]->[A]; [D]->[T];
fn doGet() void {
    setA(valJ());
    // document.getElementById("k0").className = "c0";
    // document.getElementById("k1").className = "c5"; // "c5" only if [S] or [J]
    alu = valD();
    muxD = alu;
    muxC = muxD;
    setT();
    incJ();
    // wireup(["z3", "z2"]);
}

var edit_mode: bool = false;

pub fn main() !void {
    setT();
    setI_(64); // 0100. Reset.
    setA(valI());
    setH_(0); // 7700. Reset.

    muxB = 64 * 8; // no reset. should be random?
    setJ();

    // setS(32); // reset
    // !TODO needs fixing
    resetS();
    setS_();

    if (std.os.argv.len > 1) {
        const input = std.os.argv[1];
        var input_counter: usize = 0;
        var file_name_length: usize = 0;
        while (input[input_counter] != 0) : (input_counter += 1) {
            file_name_length += 1;
        }
        const path = std.os.argv[1][0..file_name_length];

        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1985]u8 = undefined;
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |_| {}
        for (buf, 0..1985) |peck, i| {
            const b = @subWithOverflow(peck, 48)[0];
            const number: u3 = @truncate(b);
            regD[i + 64] = number;
        }
    }

    const WHITE = ray.WHITE;
    const BLACK = ray.BLACK;
    const CYAN = ray.ColorFromNormalized(.{ .x = 0, .y = 1, .z = 1, .w = 1 });
    const RED = ray.ColorFromNormalized(.{ .x = 1, .y = 0, .z = 0, .w = 1 });
    const GREEN = ray.ColorFromNormalized(.{ .x = 0, .y = 1, .z = 0, .w = 1 });
    const BLUE = ray.ColorFromNormalized(.{ .x = 0, .y = 0, .z = 1, .w = 1 });
    const YELLOW = ray.ColorFromNormalized(.{ .x = 1, .y = 1, .z = 0, .w = 1 });
    const MAGENTA = ray.ColorFromNormalized(.{ .x = 1, .y = 0, .z = 1, .w = 1 });

    const n = 64 * 32;
    const screenWidth = 2048 + 64;
    const screenHeight = 1024 + 64 + 64;

    const save_button: ray.Rectangle = .{ .x = 32 * 32, .y = 1024 + 64 + 32, .width = 64, .height = 64 };

    var pre_edit_i_register: u12 = valI();

    const colors = [_]ray.Color{ BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE };
    // const color_name = [8][]const u8{ "BLACK", "RED", "GREEN", "YELLOW", "BLUE", "MAGENTA", "CYAN", "WHITE" };

    var rects: [n]ray.Rectangle = [_]ray.Rectangle{.{ .x = 0, .y = 0, .width = 32, .height = 32 }} ** n;

    for (0..n) |i| {
        rects[i].x = @floatFromInt(64 + (32 * @mod(i, 64)));
        rects[i].y = @floatFromInt(64 + (32 * @divFloor(i, 64)));
    }

    //j_rectangle
    var j_rectangle: [4]ray.Rectangle = [_]ray.Rectangle{.{ .x = 0, .y = 0, .width = 32, .height = 32 }} ** 4;
    for (0..4) |i| {
        const w = 64 + (32 * (3 - i));
        const z: f32 = @floatFromInt(w);
        j_rectangle[i].x = z;
        j_rectangle[i].y = 1024 + 64 + 32;
    }

    //i_rectangle
    var i_rectangle: [4]ray.Rectangle = [_]ray.Rectangle{.{ .x = 0, .y = 0, .width = 32, .height = 32 }} ** 4;
    for (0..4) |i| {
        const w = 64 + (32 * (8 - i));
        const z: f32 = @floatFromInt(w);
        i_rectangle[i].x = z;
        i_rectangle[i].y = 1024 + 64 + 32;
    }

    ray.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    var save_counter_time: usize = 0;
    var is_saved: bool = false;

    while (!ray.WindowShouldClose()) {
        if (ray.IsKeyDown(ray.KEY_CAPS_LOCK) and !edit_mode) {
            pre_edit_i_register = valI();
            edit_mode = true;
        }
        if (ray.IsKeyReleased(ray.KEY_CAPS_LOCK)) {
            setI_(pre_edit_i_register);
            edit_mode = false;
        }

        if (!edit_mode) {
            if (ray.IsKeyDown(ray.KEY_SPACE)) {
                step();
                current_rectangle_stack.x = @floatFromInt(64 + 32 * @mod(valS(), 64));
            }

            if (ray.IsKeyPressed(ray.KEY_ENTER)) {
                step();
                current_rectangle_stack.x = @floatFromInt(64 + 32 * @mod(valS(), 64));
            }

            if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                const pos = ray.GetMousePosition();

                if (ray.CheckCollisionPointRec(pos, save_button)) {
                    var array: [1984]u8 = undefined;

                    const output_file = try std.fs.cwd().createFile("output.txt", .{});
                    defer output_file.close();

                    for (64..2048) |i| {
                        const number: u8 = regD[i];
                        array[i - 64] = number + 48;
                    }

                    try output_file.writeAll(&array);
                    is_saved = true;
                    save_counter_time = 60 * 1.5;
                }

                for (rects, 0..) |rectangle, i| {
                    if (ray.CheckCollisionPointRec(pos, rectangle)) {
                        // print("pressed insided rectangle {d} with color {s}\n", .{ i, color_name[regD[i]] });
                        const old_d: usize = regD[i];
                        const new_d: usize = @mod(old_d + 1, 8);
                        regD[i] = @truncate(new_d);
                    }
                }
                for (j_rectangle, 0..) |rectangle, i| {
                    if (ray.CheckCollisionPointRec(pos, rectangle)) {
                        const old_j: usize = regJ[i];
                        const new_j: usize = @mod(old_j + 1, 8);
                        regJ[i] = @truncate(new_j);
                    }
                }
                for (i_rectangle, 0..) |rectangle, i| {
                    if (ray.CheckCollisionPointRec(pos, rectangle)) {
                        const old_i: usize = regI[i];
                        const new_i: usize = @mod(old_i + 1, 8);
                        regI[i] = @truncate(new_i);
                    }
                }
            }
        }

        if (edit_mode) {
            if (ray.IsKeyDown(ray.KEY_R) and ray.IsKeyDown(ray.KEY_TAB)) {
                for (64..(64 * 32)) |i| {
                    regD[i] = 0;
                }
            }
            if (ray.IsKeyDown(ray.KEY_K)) {
                //left
                if (valI() > 0) decI();
            }
            if (ray.IsKeyDown(ray.KEY_L)) {
                //up
                if (regI[3] != 0 or regI[2] != 0) {
                    const result = @subWithOverflow(regI[2], 1);
                    regI[2] = result[0];
                    regI[3] -= result[1];
                }
            }
            if (ray.IsKeyDown(ray.KEY_SEMICOLON)) {
                //down
                if (regI[3] != 3 or regI[2] != 7) {
                    const result = @addWithOverflow(regI[2], 1);
                    regI[2] = result[0];
                    regI[3] += result[1];
                }
            }
            if (ray.IsKeyDown(ray.KEY_APOSTROPHE)) {
                //right
                if (valI() < (32 * 64 - 1)) incI();
            }
            const key = ray.GetKeyPressed();

            peckOn(valI());
            switch (key) {
                ray.KEY_I => setI_(64),
                ray.KEY_SPACE => {
                    for (0..(32 * 64 - valI() - 1)) |i| {
                        regD[(32 * 64) - 1 - i] = regD[(32 * 64 - 2) - i];
                    }
                    regD[valI()] = 0;
                    incI();
                },
                ray.KEY_BACKSPACE => {
                    for (valI()..(32 * 64)) |i| {
                        regD[i] = regD[i + 1];
                    }
                    regD[2047] = 0;
                    if (valI() != 64) decI();
                },
                ray.KEY_S => {
                    resetS();
                    for (0..64) |i| {
                        regD[i] = 0;
                    }
                },
                ray.KEY_J => {
                    muxB = 64 * 8;
                    setJ();
                },
                ray.KEY_RIGHT => if (valI() < (32 * 64 - 1)) incI(),
                ray.KEY_LEFT => if (valI() > 0) decI(),
                ray.KEY_DOWN => {
                    if (regI[3] != 3 or regI[2] != 7) {
                        const result = @addWithOverflow(regI[2], 1);
                        regI[2] = result[0];
                        regI[3] += result[1];
                    }
                },
                ray.KEY_UP => {
                    if (regI[3] != 0 or regI[2] != 0) {
                        const result = @subWithOverflow(regI[2], 1);
                        regI[2] = result[0];
                        regI[3] -= result[1];
                    }
                },
                ray.KEY_ENTER => {
                    if (regI[3] != 0 or regI[2] != 0) {
                        const modI = @mod(valI(), 64);
                        for (0..(32 - @divFloor(valI(), 64) - 1)) |j| {
                            for (0..(64 - modI)) |i| {
                                regD[((32 - j) * 64) - 1 - i] = regD[(((32 - j) * 64) - 1) - i - 64];
                            }
                        }
                        for (0..(64 - modI)) |i| {
                            regD[valI() + i] = 0;
                        }

                        if (regI[3] != 3 or regI[2] != 7) {
                            const result = @addWithOverflow(regI[2], 1);
                            regI[2] = result[0];
                            regI[3] += result[1];
                        }
                    }
                },
                ray.KEY_RIGHT_SHIFT => {
                    if (regI[3] != 0 or regI[2] != 1) {
                        const modI = @mod(valI(), 64);
                        for (0..(64 - @divFloor(valI(), 64))) |j| {
                            for (0..(64 - modI)) |i| {
                                regD[valI() - 64 + i + (64 * j)] = regD[valI() + i + (64 * j)];
                            }
                        }
                        // for (0..64) |i| {
                        //     regD[31 * 64 + i] = 0;
                        // }
                        const result = @subWithOverflow(regI[2], 1);
                        regI[2] = result[0];
                        regI[3] -= result[1];
                    }
                },
                ray.KEY_RIGHT_BRACKET => {
                    const modI = @mod(valI(), 64);
                    for (1..(64 - modI)) |i| {
                        regD[valI() - modI + 64 - i] = regD[valI() - modI + 64 - i - 1];
                    }
                    regD[valI()] = 0;
                    if (regI[0] != 7 or regI[1] != 7) incI();
                },
                ray.KEY_LEFT_BRACKET => {
                    const modI = @mod(valI(), 64);
                    if (modI != 0) {
                        for (0..(64 - modI)) |i| {
                            regD[valI() + i - 1] = regD[valI() + i];
                        }
                        decI();
                    } else {
                        for (0..(64 - modI)) |i| {
                            regD[valI() + i] = regD[valI() + i + 1];
                        }
                    }
                    // regD[valI() - modI + 64 - 1] = 0;

                },
                ray.KEY_ZERO => {
                    regD[valI()] = 0;
                    incI();
                },
                ray.KEY_ONE => {
                    regD[valI()] = 1;
                    incI();
                },
                ray.KEY_TWO => {
                    regD[valI()] = 2;
                    incI();
                },
                ray.KEY_THREE => {
                    regD[valI()] = 3;
                    incI();
                },
                ray.KEY_FOUR => {
                    regD[valI()] = 4;
                    incI();
                },
                ray.KEY_FIVE => {
                    regD[valI()] = 5;
                    incI();
                },
                ray.KEY_SIX => {
                    regD[valI()] = 6;
                    incI();
                },
                ray.KEY_SEVEN => {
                    regD[valI()] = 7;
                    incI();
                },
                else => {},
            }
        }

        if (ray.IsKeyPressed(ray.KEY_R)) setI_(64);

        ray.BeginDrawing();
        defer ray.EndDrawing();

        if (edit_mode) ray.DrawText("EDIT MODE", 32 * 40, 1024 + 64, 50, ray.RED);

        //row colors
        for (0..64) |i| {
            const w: u32 = @intCast(64 + 32 * @mod(i, 64));
            const z: c_int = @intCast(w);
            ray.DrawRectangle(z, 0, 32, 32, colors[@divFloor(i, 8)]);
            ray.DrawRectangle(z, 32, 32, 32, colors[@mod(i, 8)]);
        }

        //column colors
        for (0..32) |i| {
            const w: u32 = @intCast(64 + 32 * @mod(i, 64));
            const z: c_int = @intCast(w);
            ray.DrawRectangle(0, z, 32, 32, colors[@divFloor(i, 8)]);
            ray.DrawRectangle(32, z, 32, 32, colors[@mod(i, 8)]);
        }

        for (0..n) |i| {
            ray.DrawRectangleRec(rects[i], colors[regD[i]]);
        }
        // instruction rectangle
        ray.DrawRectangleLinesEx(current_rectangle, 5, ray.GRAY);

        // stack rectangle
        ray.DrawRectangleLinesEx(current_rectangle_stack, 5, ray.GRAY);

        // J register
        ray.DrawText("J Register", 64, 1024 + 64, 20, WHITE);
        for (0..4) |i| {
            ray.DrawRectangleRec(j_rectangle[i], colors[regJ[i]]);
        }

        // I register
        ray.DrawText("I Register", 64 + 32 * 5, 1024 + 64, 20, WHITE);
        for (0..4) |i| {
            const w: u32 = @intCast(160 + 64 + 32 * @mod(i, 64));
            const z: c_int = @intCast(w);
            ray.DrawRectangle(z, 1024 + 64 + 32, 32, 32, colors[regI[3 - i]]);
        }

        // S register
        ray.DrawText("S Register", 64 + 32 * 10, 1024 + 64, 20, WHITE);
        for (0..4) |i| {
            const w: u32 = @intCast(320 + 64 + 32 * @mod(i, 64));
            const z: c_int = @intCast(w);
            ray.DrawRectangle(z, 1024 + 64 + 32, 32, 32, colors[regS[3 - i]]);
        }

        // D register
        ray.DrawText("D Register", 64 + 32 * 15, 1024 + 64, 20, WHITE);
        ray.DrawRectangle(32 * 15 + 64 + 32, 1024 + 64 + 32, 32, 32, colors[regD[valI()]]);

        // T register
        ray.DrawText("T Register", 64 + 32 * 20, 1024 + 64, 20, WHITE);
        ray.DrawRectangle(32 * 20 + 64 + 32, 1024 + 64 + 32, 32, 32, colors[regT]);

        // F register
        ray.DrawText("F Register", 64 + 32 * 25, 1024 + 64, 20, WHITE);
        ray.DrawRectangle(32 * 25 + 64 + 32, 1024 + 64 + 32, 32, 32, colors[regF[0]]);

        ray.DrawText("Save Button", 32 * 32, 1024 + 64, 20, WHITE);
        ray.DrawRectangleRec(save_button, ray.GREEN);

        if (is_saved and (save_counter_time > 0)) {
            ray.DrawText("SAVED", 40 * 32, 1024 + 64, 70, ray.GREEN);
            save_counter_time -= 1;
        }

        ray.ClearBackground(ray.GRAY);
    }
}

var current_rectangle: ray.Rectangle = .{ .x = 64, .y = 64 + 32, .height = 32, .width = 32 };
var current_rectangle_stack: ray.Rectangle = .{ .x = 64 + 32 * 32, .y = 64, .height = 32, .width = 32 };

fn peckOn(index: u12) void {
    current_rectangle.x = @floatFromInt(64 + 32 * @mod(index, 64));
    current_rectangle.y = @floatFromInt(64 + 32 * @divFloor(index, 64));
}
