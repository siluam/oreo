from autoslot import SlotsMeta
from rich.progress import Progress
from time import sleep


# Adapted From:
# Answer 1: https://stackoverflow.com/a/1800999/10827766
# User 1: https://stackoverflow.com/users/36433/a-coady
# Answer 2: https://stackoverflow.com/a/31537249/10827766
# User 2: https://stackoverflow.com/users/302343/timur
class meclair(SlotsMeta):
    def __init__(cls, *args, **kwargs):
        cls.Progress = Progress(auto_refresh=False)


class eclair(metaclass=meclair):
    def __init__(self, iterable, name, color, sleep=0.025):
        self.color = color
        self.iterable = tuple(iterable)
        self.len = len(iterable)
        self.increment = 100 / self.len
        self.n = 0
        self.name = name
        self.sleep = sleep

        # Append preliminary invisible task to list of progress tasks
        if len(self.__class__.Progress.task_ids) == 0:
            self.first_task = self.__class__.Progress.add_task(
                f"[green]start", total=0, visible=False
            )

        # Append rich.progress task to list of progress tasks.
        # Adapted From:
        # Answer 1: https://stackoverflow.com/a/26626707/10827766
        # User 1: https://stackoverflow.com/users/100297/martijn-pieters
        # Answer 2: https://stackoverflow.com/a/328882/10827766
        # User 2: https://stackoverflow.com/users/9567/torsten-marek
        self.task = self.__class__.Progress.add_task(
            f"[{self.color}]{self.name}", total=self.len, start=False
        )

    def __iter__(self):
        self.n = 0
        if len(self.__class__.Progress.task_ids) == 2:
            self.__class__.Progress.start()
            self.__class__.Progress.start_task(self.__class__.Progress.task_ids[1])
        else:
            self.__class__.Progress.start_task(self.task)
        return self

    def __next__(self):
        if self.n < self.len:
            try:
                sleep(self.sleep)
                self.__class__.Progress.update(
                    self.task, advance=self.increment, refresh=True
                )
                return self.iterable[self.n]
            finally:
                self.n += 1
        else:
            try:
                raise StopIteration
            finally:
                self.__class__.Progress.stop_task(self.task)
                if self.__class__.Progress.finished:
                    self.__class__.Progress.stop()
