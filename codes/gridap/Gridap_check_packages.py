def main():
	out = True  # Start with True, and set to False if any import fails

	try:
		import julia  # netgen should be automatically installed when installing ngsolve
		print("julia package is installed")
	except ImportError as e:
		print("Error -> ", e)
		out = False
		
	return out

if __name__ == "__main__":
	out = main()
