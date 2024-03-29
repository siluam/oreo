# -*- coding: utf-8 -*-
from setuptools import setup

packages = ["oreo"]

package_data = {"": ["*"]}

install_requires = [
    "addict",
    "autoslot",
    "click",
    "hy>=0.24.0,<0.25.0",
    "hyrule>=0.2,<0.3",
    "more-itertools",
    "nixpkgs",
    "rich",
    "toolz",
]

setup_kwargs = {
    "name": "oreo",
    "version": "1.0.0.0",
    "description": "The Stuffing for Other Functions!",
    "long_description": "None",
    "author": "sylvorg",
    "author_email": "jeet.ray@syvl.org",
    "maintainer": "None",
    "maintainer_email": "None",
    "url": "None",
    "packages": packages,
    "package_data": package_data,
    "install_requires": install_requires,
    "python_requires": ">=3.9,<4.0",
}


setup(**setup_kwargs)
