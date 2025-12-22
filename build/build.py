#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""cangjie ffi_python build entry"""

import argparse
import os
import platform
import shutil
import subprocess
import sys

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))

IS_WINDOWS = platform.system() == "Windows"
IS_LINUX = platform.system() == "Linux"
IS_MACOS = platform.system() == "Darwin"
SUPPORTED_BUILD_TYPE = ["debug", "release"]
SUPPORTED_TARGET = ["native"]

def build(args):
    if not (IS_LINUX and args.target == 'native'):
        print("error: ffi_python compile is only supported for native Linux.")
        return 1

    command = ['cjpm', 'build']
    if args.build_type == "debug":
        command.append("--debug")
    else:
        command.append("--release")
    py_interop_dir = os.path.join(CURRENT_DIR, '..', 'src', 'ffi', 'ffi_python')

    try:
        subprocess.check_call(command, cwd=py_interop_dir)
    except subprocess.CalledProcessError as e:
        print(f"Command '{e.cmd}' returned non-zero exit status {e.returncode}.")
        sys.exit(e.returncode)

def install(args):
    prefix = args.prefix
    if not os.path.exists(os.path.join(CURRENT_DIR, '..', 'target', 'release', 'ffi_python')):
        print("error: no ffi_python output, please run command 'build' first.")
        return 1

    if prefix:
        os.makedirs(os.path.abspath(prefix), exist_ok=True)
        if os.path.exists(os.path.join(CURRENT_DIR, '..', 'target', 'release', 'ffi_python', 'ffi_python.cjo')):
            shutil.copy(os.path.join(CURRENT_DIR, '..', 'target', 'release', 'ffi_python', 'ffi_python.cjo'), os.path.abspath(prefix))
        if os.path.exists(os.path.join(CURRENT_DIR, '..', 'target', 'release', 'ffi_python', 'libffi_python.so')):
            shutil.copy(os.path.join(CURRENT_DIR, '..', 'target', 'release', 'ffi_python', 'libffi_python.so'), os.path.abspath(prefix))
        print("Successfully install ffi_python!")

def clean():
    if os.path.exists(os.path.join(CURRENT_DIR, '..', 'target')):
        shutil.rmtree(os.path.join(CURRENT_DIR, '..', 'target'))
    print("Successfully clean ffi_python!")

def main():
    # set options
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Build command
    build_parser = subparsers.add_parser('build', help='Build ffi_python')
    build_parser.add_argument('-t', '--build-type', default='release', choices=list(SUPPORTED_BUILD_TYPE), help='Select target build type')
    build_parser.add_argument('--target', default='native', choices=list(SUPPORTED_TARGET), help='Specify the target platform for cross compilation')

    # Install command
    install_parser = subparsers.add_parser('install', help='Install ffi_python')
    install_parser.add_argument('--prefix', help='Specify installation prefix')

    # Clean command
    subparsers.add_parser('clean', help='Clean build files')

    args = parser.parse_args()
    if args.command == 'build':
        return build(args)
    elif args.command == 'install':
        return install(args)
    elif args.command == 'clean':
        return clean()
    else:
        parser.print_help()
        return 0

if __name__ == '__main__':
    main()