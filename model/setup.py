from distutils.core import setup, Extension
from Cython.Build import cythonize
import numpy as np
import os
import platform

from Cython.Compiler import Options

Options.buffer_max_dims = 10

if (os.environ.get('CC',None)=="gcc-9") or (platform.system()=="Linux"):
	compileArgs = ['-fopenmp']
else:
	compileArgs = []


extensions = [
				Extension("model.PolicyIterator",["model/PolicyIterator.pyx"],
							include_dirs=[np.get_include(), "model"],
							extra_compile_args=compileArgs,
        					extra_link_args=compileArgs,),

				Extension("model.ModelObjects",["model/ModelObjects.pyx"],
							include_dirs=[np.get_include(), "model"],
							extra_compile_args=compileArgs,
        					extra_link_args=compileArgs,),


				Extension("model.Simulator",["model/Simulator.pyx"],
							include_dirs=[np.get_include(), "model"],
							extra_compile_args=compileArgs,
        					extra_link_args=compileArgs,),

				Extension("misc.cfunctions",["misc/cfunctions.pyx"],
							include_dirs=[np.get_include(), "misc"],
							extra_compile_args=compileArgs,
        					extra_link_args=compileArgs,),

				Extension("misc.Interpolant",["misc/Interpolant.pyx"],
							include_dirs=[np.get_include(), "misc"],
							extra_compile_args=compileArgs,
        					extra_link_args=compileArgs,),
			]

setup(	name="StockOwnership",
		ext_modules=cythonize(extensions),
		packages=["model", "misc"])