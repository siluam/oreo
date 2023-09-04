from autoslot import Slots


class Multi(Slots):
    def __init__(self, string, parts=tuple()):
        self.string = string
        self.parts = parts

    # Make multiple partitions
    def partition(self, *delims, string=None, parts=tuple()):
        if string is None:
            string = self.string
        final = []
        if delims:
            delim = delims[0]
            if not parts:
                parts = string.partition(delim)
            for item in parts:
                try:
                    if (delim in item) and (item != delim):
                        final.extend(self.partition(*delims, string=item))
                    elif (delims[1] in item) and (item != delims[1]):
                        final.extend(self.partition(*delims[1:], string=item))
                    else:
                        final.append(item)
                except IndexError:
                    final.append(item)
        return filter(None, final or (string,))

    # Make multiple splits
    def split(self, *delims, string=None, parts=tuple()):
        if string is None:
            string = self.string
        final = []
        if delims:
            if not parts:
                parts = string.split(delims[0])
            for item in parts:
                try:
                    if delims[1] in item:
                        final.extend(self.split(*delims[1:], string=item))
                    else:
                        final.append(item)
                except IndexError:
                    final.append(item)
        return filter(None, final or (string,))
