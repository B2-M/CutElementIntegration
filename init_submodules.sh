#!/bin/bash

# Initialize all submodules
git submodule init

# Function to recursively update submodules
update_submodules() {
  local base_path=$1
  for submodule in $(git config --file .gitmodules --name-only --get-regexp path | sed 's/^submodule\.//;s/\.path$//'); do
    local submodule_path="$base_path$(git config --file .gitmodules --get submodule.$submodule.path)"
    echo -e "Updating $submodule_path..."
    if git submodule update --init --recursive $submodule_path; then
      echo -e "Successfully initiated $submodule_path (with its submodules)\n"
    else
      if git submodule update --init $submodule_path; then
        echo -e "Re-try: successfully initiated $submodule_path (but not its submodules)\n"
        # Check if the submodule has its own .gitmodules file
        if [ -f "$submodule_path/.gitmodules" ]; then
			echo -e "Attempting to update nested submodules in $submodule_path...\n"
			(cd $submodule_path && update_submodules "$submodule_path/")
        fi
      else
      echo -e "Failed to update $submodule_path, skipping...\n"
      fi	
    fi
  done
}

# Start updating from the top level
update_submodules ""

# Initialize all submodules
git submodule update --recursive