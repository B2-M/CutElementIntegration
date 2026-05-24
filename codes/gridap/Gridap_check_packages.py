def main():
	out = True  # Start with True, and set to False if any check fails

	try:
		import julia  # Python julia bridge package
		print("julia package is installed")
	except ImportError as e:
		print("Error -> ", e)
		out = False
		return out

	# Verify that Gridap.jl is installed in the active Julia environment
	try:
		import os
		separator = ';' if os.name == 'nt' else ':'
		depot_env = os.environ.get('JULIA_DEPOT_PATH', '')
		if depot_env:
			julia_depot = depot_env.split(separator)[0]
		else:
			julia_depot = os.path.join(os.path.expanduser("~"), ".julia")

		env_dir = os.path.join(julia_depot, "environments")
		gridap_found = False

		if os.path.exists(env_dir):
			for version_dir in sorted(os.listdir(env_dir), reverse=True):
				manifest_path = os.path.join(env_dir, version_dir, "Manifest.toml")
				if os.path.exists(manifest_path):
					with open(manifest_path, 'r') as f:
						content = f.read()
					if '[[deps.Gridap]]' in content:
						gridap_found = True
						break

		if gridap_found:
			print("Gridap Julia package is installed")
		else:
			print("Error -> Gridap Julia package is not installed. "
				  "Run in Julia: import Pkg; Pkg.add(\"Gridap\")")
			out = False

	except Exception as e:
		print("Error -> Could not verify Gridap Julia package: ", e)
		out = False

	return out

if __name__ == "__main__":
	out = main()
