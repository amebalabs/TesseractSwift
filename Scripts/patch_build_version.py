#!/usr/bin/env python3

"""
Rewrite LC_BUILD_VERSION min/sdk values for Mach-O object files.

Usage:
    patch_build_version.py <min_ver> <sdk_ver> <obj>...

Versions are strings like 13.5 or 13.5.0. This keeps the existing load
command size intact (no new tools are added), so it works for small object
files with zero build tools recorded.
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path


def encode_version(version: str) -> int:
    parts = version.split(".")
    parts += ["0"] * (3 - len(parts))
    major, minor, patch = (int(p) for p in parts[:3])
    return (major << 16) | (minor << 8) | patch


def patch_file(path: Path, min_int: int, sdk_int: int) -> None:
    data = bytearray(path.read_bytes())
    magic = struct.unpack_from("<I", data, 0)[0]
    if magic in (0xCFFAEDFE, 0xCEFAEDFE):
        endian = ">"  # big-endian magic
        magic = struct.unpack_from(">I", data, 0)[0]
    else:
        endian = "<"

    is_64 = magic in (0xFEEDFACF, 0xCFFAEDFE)
    header_size = 32 if is_64 else 28

    ncmds = struct.unpack_from(endian + "I", data, 16)[0]
    offset = header_size
    patched = False

    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from(endian + "II", data, offset)
        if cmd == 0x32:  # LC_BUILD_VERSION
            # struct build_version_command {
            #   uint32_t cmd;        // LC_BUILD_VERSION
            #   uint32_t cmdsize;
            #   uint32_t platform;   // unchanged
            #   uint32_t minos;      // update
            #   uint32_t sdk;        // update
            #   uint32_t ntools;
            # };
            struct.pack_into(endian + "II", data, offset + 12, min_int, sdk_int)
            patched = True
        offset += cmdsize

    if not patched:
        print(f"warning: no LC_BUILD_VERSION in {path}", file=sys.stderr)

    path.write_bytes(data)


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        print("usage: patch_build_version.py <min_ver> <sdk_ver> <obj>...", file=sys.stderr)
        return 1

    min_int = encode_version(argv[0])
    sdk_int = encode_version(argv[1])

    for obj_path in argv[2:]:
        patch_file(Path(obj_path), min_int, sdk_int)

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
