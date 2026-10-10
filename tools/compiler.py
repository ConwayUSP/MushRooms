"""Build distributable packages for the MushRooms LÖVE game.

The script intentionally has no graphical interface so it can run both locally
and in GitHub Actions. It expects extracted official LÖVE Windows archives and
produces Win64, Win32 and portable Unix packages.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import stat
import sys
import tempfile
import zipfile
from pathlib import Path


IGNORED_DIRECTORY_NAMES = {
    ".git",
    ".github",
    ".vscode",
    "__pycache__",
}

IGNORED_ROOT_DIRECTORIES = {
    ".build",
    "build",
    "dist",
    "tools",
}

IGNORED_EXTENSIONS = {
    ".md",
    ".pyc",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build LÖVE packages without a graphical interface."
    )
    parser.add_argument("--name", required=True, help="Name used for output files.")
    parser.add_argument(
        "--game-dir",
        type=Path,
        default=Path.cwd(),
        help="Game directory containing main.lua (default: current directory).",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("dist"),
        help="Directory that receives the build files (default: dist).",
    )
    parser.add_argument(
        "--love-version",
        required=True,
        help="LÖVE version required by the game, for example 11.5.",
    )
    parser.add_argument(
        "--love64-dir",
        type=Path,
        required=True,
        help="Extracted official LÖVE Win64 directory.",
    )
    parser.add_argument(
        "--love32-dir",
        type=Path,
        required=True,
        help="Extracted official LÖVE Win32 directory.",
    )
    return parser.parse_args()


def validate_game_name(game_name: str) -> None:
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", game_name):
        raise ValueError(
            "Game name must start with an alphanumeric character and contain "
            "only letters, numbers, dots, underscores or hyphens."
        )


def validate_inputs(
    game_name: str,
    game_dir: Path,
    love64_dir: Path,
    love32_dir: Path,
) -> None:
    validate_game_name(game_name)

    if not game_dir.is_dir():
        raise FileNotFoundError(f"Game directory not found: {game_dir}")
    if not (game_dir / "main.lua").is_file():
        raise FileNotFoundError(f"main.lua not found in: {game_dir}")

    for architecture, runtime_dir in (
        ("Win64", love64_dir),
        ("Win32", love32_dir),
    ):
        if not runtime_dir.is_dir():
            raise FileNotFoundError(
                f"Extracted LÖVE {architecture} directory not found: {runtime_dir}"
            )
        if not (runtime_dir / "love.exe").is_file():
            raise FileNotFoundError(
                f"love.exe not found in the LÖVE {architecture} directory: "
                f"{runtime_dir}"
            )


def should_ignore(relative_path: Path, output_dir: Path, game_dir: Path) -> bool:
    if any(part in IGNORED_DIRECTORY_NAMES for part in relative_path.parts):
        return True

    if relative_path.parts and relative_path.parts[0] in IGNORED_ROOT_DIRECTORIES:
        return True

    if relative_path.suffix.lower() in IGNORED_EXTENSIONS:
        return True

    absolute_path = (game_dir / relative_path).resolve()
    try:
        absolute_path.relative_to(output_dir)
        return True
    except ValueError:
        return False


def create_love_file(game_dir: Path, output_dir: Path, love_path: Path) -> None:
    print(f"Creating {love_path.name}...")

    with zipfile.ZipFile(love_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for root, directories, files in os.walk(game_dir):
            root_path = Path(root)
            relative_root = root_path.relative_to(game_dir)

            directories[:] = sorted(
                directory
                for directory in directories
                if not should_ignore(
                    relative_root / directory, output_dir, game_dir
                )
            )

            for filename in sorted(files):
                source_path = root_path / filename
                relative_path = source_path.relative_to(game_dir)

                if should_ignore(relative_path, output_dir, game_dir):
                    continue

                archive.write(source_path, relative_path.as_posix())


def copy_runtime_files(runtime_dir: Path, package_dir: Path) -> None:
    for source_path in sorted(runtime_dir.rglob("*")):
        if not source_path.is_file():
            continue

        relative_path = source_path.relative_to(runtime_dir)
        if relative_path.as_posix().lower() in {"love.exe", "lovec.exe"}:
            continue

        destination_path = package_dir / relative_path
        destination_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_path, destination_path)


def create_fused_executable(
    runtime_dir: Path,
    love_path: Path,
    executable_path: Path,
) -> None:
    with executable_path.open("wb") as output_file:
        with (runtime_dir / "love.exe").open("rb") as love_executable:
            shutil.copyfileobj(love_executable, output_file)
        with love_path.open("rb") as game_archive:
            shutil.copyfileobj(game_archive, output_file)


def zip_directory(source_dir: Path, output_zip: Path) -> None:
    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as archive:
        for source_path in sorted(source_dir.rglob("*")):
            if source_path.is_file():
                archive.write(
                    source_path,
                    source_path.relative_to(source_dir).as_posix(),
                )


def create_windows_package(
    game_name: str,
    architecture: str,
    runtime_dir: Path,
    love_path: Path,
    output_zip: Path,
    temporary_root: Path,
) -> None:
    print(f"Creating Windows {architecture} package...")
    package_dir = temporary_root / f"windows-{architecture.lower()}"
    package_dir.mkdir(parents=True)

    create_fused_executable(
        runtime_dir,
        love_path,
        package_dir / f"{game_name}.exe",
    )
    copy_runtime_files(runtime_dir, package_dir)
    zip_directory(package_dir, output_zip)


def write_executable_zip_entry(
    archive: zipfile.ZipFile,
    filename: str,
    content: str,
) -> None:
    entry = zipfile.ZipInfo(filename)
    entry.create_system = 3
    entry.external_attr = (stat.S_IFREG | 0o755) << 16
    archive.writestr(entry, content.encode("utf-8"))


def create_unix_package(
    game_name: str,
    love_version: str,
    love_path: Path,
    output_zip: Path,
) -> None:
    print("Creating portable Unix package...")

    launcher = f'''#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec love "$SCRIPT_DIR/{game_name}.love" "$@"
'''
    readme = f"""{game_name} for Unix-like systems

Requirements:
- LÖVE {love_version} installed and available as the `love` command.

Run:
  ./{game_name}

Alternatively:
  love {game_name}.love
"""

    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as archive:
        archive.write(love_path, f"{game_name}.love")
        write_executable_zip_entry(archive, game_name, launcher)
        archive.writestr("README.txt", readme.encode("utf-8"))


def build(args: argparse.Namespace) -> list[Path]:
    game_dir = args.game_dir.resolve()
    output_dir = args.output_dir.resolve()
    love64_dir = args.love64_dir.resolve()
    love32_dir = args.love32_dir.resolve()

    validate_inputs(args.name, game_dir, love64_dir, love32_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    love_path = output_dir / f"{args.name}.love"
    win64_zip = output_dir / f"{args.name}-win64.zip"
    win32_zip = output_dir / f"{args.name}-win32.zip"
    unix_zip = output_dir / f"{args.name}-unix.zip"

    create_love_file(game_dir, output_dir, love_path)

    with tempfile.TemporaryDirectory(prefix="love-build-") as temporary_dir:
        temporary_root = Path(temporary_dir)
        create_windows_package(
            args.name,
            "64-bit",
            love64_dir,
            love_path,
            win64_zip,
            temporary_root,
        )
        create_windows_package(
            args.name,
            "32-bit",
            love32_dir,
            love_path,
            win32_zip,
            temporary_root,
        )

    create_unix_package(args.name, args.love_version, love_path, unix_zip)
    return [win64_zip, win32_zip, unix_zip]


def main() -> int:
    try:
        artifacts = build(parse_args())
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        return 1

    print("Build completed successfully:")
    for artifact in artifacts:
        print(f"- {artifact}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
