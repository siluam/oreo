import click

from .py import remove_prefix_n


# Adapted From:
# Answer: https://stackoverflow.com/users/7311767/stephen-rauch
# User: https://stackoverflow.com/a/55881912/10827766
class Option(click.Option):
    @staticmethod
    def name(name):
        return remove_prefix_n(name, "-", n=2).replace("-", "_").lower()

    @staticmethod
    def opt_joined(name, opt_val, opt_len):
        return (
            f'"{opt_val[0]}"'
            if opt_len == 1
            else f'''"{'", "'.join((opt for opt in opt_val if opt != name))}"'''
        )

    @staticmethod
    def is_option(opt_len):
        return "option" if opt_len <= 2 else "options"

    @staticmethod
    def is_is(opt_len):
        return "is" if opt_len <= 2 else "are"

    @staticmethod
    def is_da_use(opt_len):
        return "the use" if opt_len == 1 else "one or more"

    @staticmethod
    def gen_help(help, end):
        return help + "\nNOTE: This option " + end

    def __init__(self, *args, **kwargs):
        # Naming convention taken from: https://click.palletsprojects.com/en/8.0.x/options/#name-your-options
        nargs = args[0]
        if len(nargs) == 1:
            name = self.__class__.name(nargs[0])
        elif len(nargs) == 2:
            name = (
                self.__class__.name(pre_name)
                if (pre_name := nargs[0]).startswith("--")
                else self.__class__.name(nargs[1])
            )
        elif len(nargs) == 3:
            name = nargs[3]

        help = kwargs.get("help", "")

        # `xor': list of options this can't be used with
        self.xor = kwargs.pop("xor", ())
        if self.xor:
            self.xor_len = len(self.xor)
            self.xor_joined = self.__class__.opt_joined(name, self.xor, self.xor_len)
            self.xor_help = f"is mutually exclusive with {self.__class__.is_option(self.xor_len)} {self.xor_joined}."
            help = self.__class__.gen_help(help, self.xor_help)

        # `one_req': list of options of which one or more must be used
        self.one_req = kwargs.pop("one_req", None) or kwargs.pop("one-req", ())
        if self.one_req:
            self.one_req_len = len(self.one_req)
            self.one_req_joined = self.__class__.opt_joined(
                name, self.one_req, self.one_req_len
            )
            self.one_req_help = f"must be used if {self.__class__.is_option(self.one_req_len)} {self.one_req_joined} {self.__class__.is_is(self.one_req_len)} not."
            help = self.__class__.gen_help(help, self.one_req_help)

        # `req_one_of': list of options of which one or more must be used with this option
        self.req_one_of = kwargs.pop("req_one_of", None) or kwargs.pop("req-one-of", ())
        if self.req_one_of:
            self.req_one_of_len = len(self.req_one_of)
            self.req_one_of_joined = self.__class__.opt_joined(
                name, self.req_one_of, self.req_one_of_len
            )
            self.req_one_of_help = f"requires {self.__class__.is_da_use(self.req_one_of_len)} of {self.__class__.is_option(self.req_one_of_len)} {self.req_one_of_joined} as well."
            help = self.__class__.gen_help(help, self.req_one_of_help)

        # `req_all_of': list of options of which all must be used with this option
        self.req_all_of = kwargs.pop("req_all_of", None) or kwargs.pop("req-all-of", ())
        if self.req_all_of:
            self.req_all_of_len = len(self.req_all_of)
            self.req_all_of_joined = self.__class__.opt_joined(
                name, self.req_all_of, self.req_all_of_len
            )
            self.req_all_of_help = f"requires {self.__class__.is_option(self.req_all_of_len)} {self.req_all_of_joined} as well."
            help = self.__class__.gen_help(help, self.req_all_of_help)

        kwargs.update({"help": help})
        return super().__init__(*args, **kwargs)

    # `self.name in opts' is being used because if absent,
    # the `if' condition would match regardless of whether this option is being used or not;
    # for example, if option `a' is mutually exclusive to option `b', using `xor', and `self.name in opts' wasn't used,
    # `command -a -b' would fail as planned, but so would `command -a' and `command -b',
    # given that the option `xor' is still being parsed by the program.
    def handle_parse_result(self, ctx, opts, args):
        # `xor'
        if self.name in opts and self.xor and any((opt in opts for opt in self.xor)):
            raise click.UsageError(f'Sorry; "{self.name}" {self.xor_help}')

        # `one_req'
        if (
            self.one_req
            and (not self.name in opts)
            and (not any((opt in opts for opt in self.one_req)))
        ):
            raise click.UsageError(f'Sorry; "{self.name}" {self.one_req_help}')

        # `req_one_of'
        if (
            self.name in opts
            and self.req_one_of
            and (not any((opt in opts for opt in self.req_one_of)))
        ):
            raise click.UsageError(f'Sorry; "{self.name}" {self.req_one_of_help}')

        # `req_all_of'
        if (
            self.name in opts
            and self.req_all_of
            and (not all((opt in opts for opt in self.req_all_of)))
        ):
            raise click.UsageError(f'Sorry; "{self.name}" {self.req_all_of_help}')

        return super().handle_parse_result(ctx, opts, args)
