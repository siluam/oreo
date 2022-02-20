class Error(Exception):
	pass


class no_iterable(Error):
	pass


class _trim:
	def trim(
		self,
		iterable=None,
		ordinal="first",
		number=1,
		_type=iter,
		ignore_check=False,
		allowed_type_names=["iter"],
	):
		
		self.__type = _type
		self.__iterable = iterable

		if number is None:
			return self.__iterable
	
		if self.__iterable is None:
			raise no_iterable(
				"Sorry! You have to pass in an iterable!"
			)
	
		if not ignore_check:
			self.__type = check_type(
				_type=self.__type, allowed_type_names=allowed_type_names
			)
	
		if ordinal == "first":
			return self.__type(
				value
				for index, value in zip(range(number), self.__iterable)
			)
		elif ordinal == "last":
			return self.__return_original_type(
				list(self.__iterable)[int(f"-{number}") :]
			)

	def __yield_from_iterable(self):
		yield from self.__iterable
	
	def __return_original_type(self):
		if self.__type.__name__ == "iter":
			return self.__yield_from_iterable()
		else:
			return self.__type(self.__iterable)