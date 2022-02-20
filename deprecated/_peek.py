# From Imports
from collections import namedtuple
from itertools import chain

class Error(Exception):
	pass


class no_return_value(Error):
	pass


class _peek:
	def peek(self, iterable, return_first=1, return_whole=True):
		"""
			Answer: https://stackoverflow.com/questions/661603/how-do-i-know-if-a-generator-is-empty-from-the-start/664239#664239
			User: https://stackoverflow.com/users/15154/john-fouhy
	
			Modified by me
		"""
		if return_first == 0 and return_whole is None:
			raise no_return_value(
				'Sorry! This function will return nothing with the given values for "return_first" and "return_whole"!'
			)

		return_tuple = namedtuple("return_tuple", "first whole")
		rd = {}

		try:
			if iterable:
				first = next(iterable)
			else:
				first = None
		except StopIteration:
			first = None
	
		if return_first == 0:
			rd["first"] = None
		elif return_first == 1:
			rd["first"] = first
		elif return_first == 2:
			# This states whether first exists or not; this bypasses cases where the boolean value of the
			# first value of an iterable is False, such as 0, "", [], etc.
			rd["first"] = False if first is None else True
		elif return_first == 3:
			# This gives the boolean value of the first value
			rd["first"] = bool(first)
		else:
			raise no_return_value(
				f"Sorry! {return_first} is not accepted! Please choose from between 0 and 3 inclusive!"
			)
	
		if return_whole:
			rd["whole"] = (
				iterable
				if first is None
				else chain([first], iterable)
			)
		else:
			rd["whole"] = None
	
		return return_tuple(first=rd["first"], whole=rd["whole"])