from collections import OrderedDict
from copy import deepcopy
from hy import models

from .py import is_coll, is_either


# A play on words between `ginseng' tea and `gen-string'!
# To override `slice' functionality, refer to:
# Answer: https://stackoverflow.com/a/16033058/10827766
# User: https://stackoverflow.com/users/100297/martijn-pieters
class tea(OrderedDict):
    def __init__(self, *args, **kwargs):
        super_dict = dict(enumerate(args)) | kwargs
        return super().__init__(((k, v) for [k, v] in super_dict.items()))

    def gin(self, delimiter=" ", override_type=None):
        values = tuple(self.values())
        if override_type:
            values = tuple(map(override_type, values))
        try:
            first_value = values[0]
        except IndexError:
            return ""
        else:
            if isinstance(first_value, str):
                return delimiter.join(map(str, values)).strip()
            elif isinstance(first_value, int):
                return sum(map(int, values))
            elif all((isinstance(value, type(first_value)) for value in values)):
                total = first_value
                for value in values[1 : len(values)]:
                    total += value
                return total
            else:
                raise TypeError(
                    "Sorry; all values in the tea must be of the same type to join!"
                )

    def __call__(self, delimiter=" ", override_type=None):
        return self.gin(delimiter=delimiter, override_type=override_type)

    def __str__(self):
        return self.gin(override_type=str)

    def get_next_free_index(self):
        current_len = len(self)
        keys = self.keys()
        if current_len in keys:
            while current_len in keys:
                current_len += 1
        return current_len

    def append(self, summand, key=None):
        self[key or self.get_next_free_index()] = summand

    def shifted(self, *args):
        shift = self.get_next_free_index()
        return {i + shift: s for [i, s] in enumerate(args)}

    def extend(self, *args, **kwargs):
        self.update(self.shifted(*args))
        return self.update(kwargs)

    def glue(self, summand, override_type=None):
        [last_key, last_value] = self.popitem(last=True)
        last_value = override_type(last_value) if override_type else last_value
        summand_is_collection = is_coll(summand)
        summand_is_dict = isinstance(summand, dict)
        if summand_is_collection and (not summand_is_dict):
            summand = list(summand)

        # Adapted From:
        # Answer: https://stackoverflow.com/a/39292086/10827766
        # User: https://stackoverflow.com/users/3218806/maxbellec
        if summand_is_collection:
            summand_first_value = summand.pop(
                next(iter(summand)) if summand_is_dict else 0
            )
        else:
            summand_first_value = summand

        if override_type:
            summand_first_value = override_type(summand_first_value)
        if not is_either(last_value, summand_first_value):
            raise TypeError(
                "Sorry! The last value of this tea and first value of the provided collection must be of the same type!"
            )
        self[last_key] = last_value + summand_first_value
        if summand_is_collection:
            self.update(summand if summand_is_dict else self.shifted(*summand))

    def __add__(self, summand):
        scopy = deepcopy(self)
        if isinstance(summand, dict):
            scopy.update(summand)
        elif is_coll(summand):
            scopy.update(scopy.shifted(*summand))
        else:
            scopy[scopy.get_next_free_index()] = summand
        return scopy

    def __sub__(self, subtrahend):
        scopy = deepcopy(self)
        for key in subtrahend:
            del scopy[key]
        return scopy

    def __eq__(self, expr):
        if isinstance(expr, self.__class__):
            return expr() == self()
        elif isinstance(expr, dict):
            expressions = dict()
            for k, v in expr.items():
                expressions[k.name if isinstance(k, models.Keyword) else k] = v
            return super().__eq__(expressions)
        elif is_coll(expr):
            return all((a == b for [a, b] in zip(self.values(), expr, strict=True)))
        elif isinstance(expr, str):
            return self() == expr
