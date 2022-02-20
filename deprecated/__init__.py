# Warnings Import
"""
	Answer: https://stackoverflow.com/questions/14463277/how-to-disable-python-warnings/14463362#14463362
	User: https://stackoverflow.com/users/1348709/mike
"""
import warnings
with warnings.catch_warnings():
	warnings.simplefilter("ignore")
	import imp as impidimp

# Imports
import inspect
import os
import pathlib

# From Imports
from functools import partial
from typing import MutableSequence as MS, Any, Generator, List


class Error(Exception):
	pass


class no_file_dir(Error):
	pass


class current_dir_error(Error):
	pass


def __getattr__(name):
	"""
		Answer 1: https://stackoverflow.com/questions/56786604/import-modules-that-dont-exist-yet/56786875#56786875
		User 1:   https://stackoverflow.com/users/1016216/l3viathan

		Answer 2: https://stackoverflow.com/questions/56786604/import-modules-that-dont-exist-yet/56795585#56795585
		User 2:   https://stackoverflow.com/users/3830997/matthias-fripp

		Modified by me
	"""
	if name == "__path__":
		raise AttributeError

	return getattr(nanite(), name)


class _fullpath:
	def fullpath(
		self,
		*args: List[str],
		current_dir: int = 0,
		check: bool = False,
		remote: bool = False,
		# Caller Function's File Path; "empath" is a wordplay on "module path"
		f_back: int = 0,
		debug: bool = False,
	) -> str:
		"""
			Credits: https://stackoverflow.com/questions/43333640/python-os-path-realpath-for-symlink-in-windows/48416561#48416561
			Answer By: https://stackoverflow.com/users/1847677/%c3%89tienne

			Modified by Jeet Ray <titaniumfiles@outlook.com>
		"""

		self.__check = check

		if f_back:
			_path: str = os.path.expandvars(os.path.expanduser(os.path.join(
				os.path.dirname(inspect.getfile(
					eval(f"inspect.currentframe(){'.f_back' * f_back}"))),
				*args
			)))
		else:
			_path: str = os.path.expandvars(
				os.path.expanduser(os.path.join(*args))
			)

		if not 0 <= current_dir <= 2:
			raise current_dir_error(
				f"Sorry! Invalid value {current_dir}; current directory parameter must be between 0 and 2!"
			)
		elif current_dir == 0:
			pass
		elif current_dir == 1:
			if os.name != "nt":
				_path = f"/{_path}"
		elif current_dir == 2:
			if os.name != "nt":
				_path = f"./{_path}"

		if os.name == "nt":
			__car = self.__check_and_return(
				_path
				if not os.path.islink(_path)
				else os.readlink(_path)
			)
			if debug:
				print(__car)
			return __car
		else:
			__car = self.__check_and_return(_path)
			if debug:
				print(__car)
			return __car

	def __check_and_return(self, _):
		if self.__check:
			if os.path.exists(_):
				return _
			else:
				raise no_file_dir(
					f'Sorry! "{_}" does not appear to be a file or a directory!'
				)
		else:
			if os.path.exists(_):
				return os.path.realpath(_)
			else:
				# Returns a remote path unmodified;
				# "realpath()" modifies the string with the current working directory
				return _


class _module_installed:
	def module_installed(self, module: str):
		"""
			Answer 1: https://stackoverflow.com/questions/3167154/how-to-split-a-dos-path-into-its-components-in-python/38741379#38741379
			User 1: https://stackoverflow.com/users/1529178/freidrichen

			Answer 2: https://stackoverflow.com/questions/15012228/splitting-on-last-delimiter-in-python-string/15012237#15012237
			User 2: https://stackoverflow.com/users/100297/martijn-pieters

			Modified by me
		"""
		# module_name, partition, module_extension = pathlib.Path(
		#     module_path := _fullpath().fullpath(module)).parts[-1].rpartition(".")
		module_path = _fullpath().fullpath(module)
		module_name, partition, module_extension = pathlib.Path(module_path).parts[-1].rpartition(".")

		"""
			Answer: https://stackoverflow.com/questions/1828127/how-to-reference-python-package-when-filename-contains-a-period/1828249#1828249
			User: https://stackoverflow.com/users/16102/cat-plus-plus

			Modified by me
		"""
		try:
			with open((module_path), "rb") as module_file:
				return impidimp.load_module(
					module_name,
					module_file,
					module_path,
					(module_extension, "rb", impidimp.PY_SOURCE)
				)
		except (FileNotFoundError, IsADirectoryError):
			try:
				return __import__(module)
			except Exception:
				return False


def mixinport(mixin_list: MS[Any]):
	def _(mixin):
		"""
			Answer: https://stackoverflow.com/questions/31890341/clean-way-to-get-the-true-stem-of-a-path-object/31890400#31890400
			User: https://stackoverflow.com/users/464744/blender
			
			Modified by me
		"""
		return getattr(
			_module_installed().module_installed(mixin),
			os.path.basename(pathlib.Path(mixin).stem.partition(".")[0])
		)
	for mixin in mixin_list:
		yield _(mixin)


mixins: Generator[str, None, None] = (_fullpath().fullpath(f"{mixin}.py", f_back = 1) for mixin in (
	"_command",
	"_option",
	"_colorize",
	"_peek",
	"_trim",
	"_check_type",
))


class nanite(_fullpath, _module_installed, *(mixinport(mixins))):
	def sui(self, module: str, attr: str):
		"""
				Single Use Import
		"""
		return getattr(self.module_installed(module), attr)
