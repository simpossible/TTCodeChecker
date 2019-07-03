from setuptools import setup
from web import __version__

setup(name='run',
      version=__version__,
      description='oc 代码合法性检查',
      author='simpossible',
      author_email='https://github.com/simpossible',
      maintainer='simpossible',
      maintainer_email='963571744@qq.com',
      url=' http://webpy.org/',
      packages=['run'],
      long_description="Think about the ideal way to write a web app. Write the code to make it happen.",
      license="Public domain",
      platforms=["any"],
      )