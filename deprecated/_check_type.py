class Error(Exception):
	pass


class no_type(Error):
    pass


class _check_type:
	def check_type(
		self, lst=False, _type=iter, allowed_type_names=["iter"]
	):
		if lst:
			return allowed_type_names
		else:
			if isinstance(_type, type):
				return _type
			else:
				if _type.__name__ in allowed_type_names:
					return _type
				else:
					raise no_type(
						f'Sorry! Type "{_type}" is not permitted! Choose any type, including: [{" ".join(allowed_type_names)}]'
					)
