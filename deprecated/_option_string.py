# class nanite_opString(click.Option):
#     """
# 		Credits for MutuallyExclusiveOption: https://gist.github.com/jacobtolar/fb80d5552a9a9dfc32b12a829fa21c0c
#
# 		Credits for GroupedOptions: https://stackoverflow.com/questions/55874075/use-several-options-together-or-not-at-all/55881912#55881912
# 		Answer By: https://stackoverflow.com/users/7311767/stephen-rauch
#
# 		Modified by Jeet Ray <titaniumfiles@outlook.com>
#
# 		# Update for the one_of and requires usage
# 		Usage:
# 		@click.option(
# 			"-t-1",
# 			"--test-1",
# 			is_flag=True,
# 			help="Test 1 Flag",
# 			cls=nanite_op,
# 			xor=["t_2", "t_4"],
# 			group="odd",
# 		)
# 		@click.option(
# 			"-t-3",
# 			"--test-3",
# 			is_flag=True,
# 			help="Test 3 Flag",
# 			cls=nanite_op,
# 			xor=["t_2", "t_4"],
# 			group="odd",
# 		)
# 		@click.option(
# 			"-t-2",
# 			"--test-2",
# 			is_flag=True,
# 			help="Test 2 Flag",
# 			cls=nanite_op,
# 			xor=["t_1", "t_3"],
# 			group="even",
# 		)
# 		@click.option(
# 			"-t-4",
# 			"--test-4",
# 			is_flag=True,
# 			help="Test 4 Flag",
# 			cls=nanite_op,
# 			xor=["t_1", "t_3"],
# 			group="even",
# 		)
#
#         "requires" should be used when one option requires one or more options together, but not vice-versa.
#         "req_one_of" should be used when one option requires one or more options optionally, but not vice-versa.
#         "one_of" should be used when one or more options in the group are required.
#         "group" should be used when all options are required.
# 	"""
#
#     def __init__(self, *args, **kwargs):
#         # self.xor: str = kwargs.pop("xor", "")
#         self.group: str = kwargs.pop("group", "")
#         self.one_req: str = kwargs.pop("one_req", "")
#         # self.req_one_of: str = kwargs.pop("req_one_of", "")
#         # self.req_all_of: str = kwargs.pop("req_all_of", "")
#         super(nanite_opString, self).__init__(*args, **kwargs)
#
#     def handle_parse_result(self, ctx, opts, args):
#         """
#
# 			Note to self: "self.name in opts" is being used because if it isn't,
# 			the if condition would match regardless of whether this option is being used or not;
# 			so for example, if option "a" is mutually exclusive to option "b", and
# 			"self.name in opts" wasn't used, "command -a -b" would match the condition, but so would
# 			"command -a" and "command -b", given that the option is still being parsed by
# 			the program.
# 		"""
#         if self.name in opts and self.group:
#             opts_in_group = [
#                 param.name
#                 for param in ctx.command.params
#                 if isinstance(param, nanite_opString)
#                 and param.group == self.group
#             ]
#
#             missing_specified = any(
#                 option
#                 for option in opts_in_group
#                 if option not in opts
#             )
#
#             if missing_specified:
#                 opts_in_group_joined = '", "'.join(
#                     option
#                     for option in opts_in_group
#                     if option != self.name
#                 )
# 				  logger.error(
# 				  	  colorize(
# 						  "red",
# 						  'Sorry, something happened!\n\n',
# 					  )
# 				  )
#                 raise illegal_usage(f'Illegal Usage: "{self.name}" must be used with {"option" if len(opts_in_group) == 1 else "options"}:\n\n["{opts_in_group_joined}"]')
#
#         if self.name in opts and self.one_req:
#             pass
#         elif self.name not in opts and self.one_req:
#             one_req_group: List[str] = [
#                 param.name
#                 for param in ctx.command.params
#                 if isinstance(param, nanite_opString)
#                 and param.one_req == self.one_req
#             ]
#
#             """
#                 Note to self; Understand as:
#
#                 lst = []
#                 for option in one_req_group:
#                     if option in opts:
#                         lst.append(option)
#                 one_exists = any(lst)
#
#                 OR:
#
#                 lst = []
#                 for option in one_req_group:
#                     lst.append(option in opts)
#                 one_exists = any(lst)
#             """
#             one_exists = any(
#                 option in opts for option in one_req_group
#             )
#
#             if not one_exists:
#                 one_req_group_joined = '", "'.join(one_req_group)
# 				  logger.error(
# 				  	  colorize(
# 						  "red",
# 						  'Sorry, something happened!\n\n',
# 					  )
# 				  )
#                 raise illegal_usage(f'Illegal Usage; you must use one or more of options:\n\n["{one_req_group_joined}"]')
#
#         return super(nanite_opString, self).handle_parse_result(
#             ctx, opts, args
#         )