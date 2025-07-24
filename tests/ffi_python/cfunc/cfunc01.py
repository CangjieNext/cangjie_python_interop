# File test.py

# If you want transfer pointer type to @C function, you need import ctypes.
from ctypes import *

# `foo` get a function pointer and call it.
def foo(func):
    func(True, 10, 40)

# `fooptr` get a function pointer and call it with pointer type args.
def fooptr(func):
    a = c_int(10)
    # c_char_p will get whole symbols, but c_wchar_p only get first one symbol 'd'.
    func(pointer(a), c_char_p(b'abc'), c_wchar_p('def'))