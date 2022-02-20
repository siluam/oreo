# Imports
import click

class _command:
	class Command(click.Command):
		"""
			Credits for DefaultHelp: https://stackoverflow.com/questions/50442401/how-to-set-the-default-option-as-h-for-python-click/50491613#50491613
			Answer By: https://stackoverflow.com/users/7311767/stephen-rauch

			Modified by Jeet Ray <titaniumfiles@outlook.com>

		"""

		# Modify to pass in a pass option if any subcommands are passed in
		def __init__(self, *args, **kwargs):
			context_settings = kwargs.setdefault(
				"context_settings", {}
			)
			if "help_option_names" not in context_settings:
				context_settings["help_option_names"] = [
					"-h",
					"--help",
				]
			self.help_flag = context_settings["help_option_names"][0]
			self.no_args_is_help: bool = kwargs.pop(
				"no_args_is_help", False
			)
			super().__init__(*args, **kwargs)

		def parse_args(self, ctx, args):
			if self.no_args_is_help and not any(args):
				args = [self.help_flag]
			return super().parse_args(ctx, args)