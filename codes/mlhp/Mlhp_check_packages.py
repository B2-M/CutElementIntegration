def main():
	out = False

	try:
		import mlhp
		print("mlhp package is installed")
		out = True
	except ImportError as e:
		print("Error -> ", e)
		
	return out

if __name__ == "__main__":
	out = main()