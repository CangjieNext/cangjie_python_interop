class MyIntegral():
    def __add__(self, other):
        if isinstance(other, MyIntegral):
            print("MyIntegral add")
            return self
        else:
            return NotImplemented

    def __radd__(self, other):
        if isinstance(other, MyIntegral):
            print("MyIntegral radd")
            return self
        else:
            return NotImplemented
