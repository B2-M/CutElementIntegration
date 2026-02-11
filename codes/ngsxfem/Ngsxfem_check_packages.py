def main():
	out = True  # Start with True, and set to False if any import fails

	try:
		import netgen  # netgen should be automatically installed when installing ngsolve
		print("netgen package is installed")
	except ImportError as e:
		print("Error -> ", e)
		out = False
		
	try:
		import ngsolve
		print("ngsolve package is installed")
	except ImportError as e:
		print("Error -> ", e)
		out = False

	try:
		import xfem
		print("xfem package is installed")
	except ImportError as e:
		print("Error -> ", e)
		out = False

	try:
		import numpy    # needed for example_torus_1
		print("numpy package is installed")
	except ImportError as e:
		print("Error -> ", e)
		out = False

	return out

if __name__ == "__main__":
	out = main()
