#!/bin/bash

# Colour Codes
RED='\033[91m'
GREEN='\033[92m'
YELLOW='\033[93m'
BLUE='\033[94m'
PURPLE='\033[95m'
CYAN='\033[96m'
# Styles
UNDERLINE='\033[4m'
BOLD='\033[1m'
RESET='\033[0m'

# Script Variables
NewLn="\r\n"
Author="TAKTAK"
ScriptName="${0##*/}"
ExUsage="Usage: Run this script to update template from base values.${NewLn}   Example: ../${ScriptName}"

# Parameters (set them here)
NEW_PROJECT_NAME="NewProject"
NEW_REV="0.2"
NEW_DESCRIPTION="New Description"
NEW_DATE=$(date +%Y-%m-%d)  # Automatically get the current date

# Retrieve Git information
GIT_DESCRIBE=$(git describe --tags --long --dirty 2>/dev/null)
if [[ $? -ne 0 ]]; then
    GIT_DESCRIBE="unknown"
fi
GIT_VERSION=$GIT_DESCRIBE

# Check if the repository is dirty
if [[ -n "$(git status --porcelain)" ]]; then
    GIT_HEALTH="dirty"
else
    GIT_HEALTH="clean"
fi

# --------------

# Functions for Error and Warning Handling
print_header() {
   echo -e "${PURPLE}${BOLD}$1${RESET}"
}

print_fatal_error() {
   echo -e "${RED}${BOLD}Fatal Error: $1${RESET}"
   exit 1
}

print_error() {
   echo -e "${RED}${BOLD}Error: $1${RESET}"
}

print_warning() {
   echo -e "${YELLOW}${BOLD}Warning: $1${RESET}"
}

print_success() {
   echo -e "${GREEN}${BOLD}$1${RESET}"
}

print_info() {
   echo -e "${BLUE}$1${RESET}"
}

print_separator() {
   echo -e "${CYAN}------------------------------------${RESET}"
}

# --------------

# Function to update the contents of a file
update_file_content() {
   local filename=$1
   local key=$2
   local new_value=$3

   if [[ -f "$filename" ]]; then
       sed -i "s|\(\"$key\": \)\"[^\"]*\"|\1\"$new_value\"|g" "$filename"
       print_success "Updated $filename: $key -> $new_value"
   else
       print_error "$filename does not exist."
   fi
}

update_title_block() {
    local filename=$1
    local key=$2
    local new_value=$3

    if [[ -f "$filename" ]]; then
        sed -i "s|(\($key \)\"[^\"]*\")|(\1\"$new_value\")|g" "$filename"
        print_success "Updated $filename: $key -> $new_value"
    else
        print_error "$filename does not exist."
    fi
}

# --------------

# Function to rename project files
rename_project_files() {
   local new_name=$1

   for file in *.kicad_pcb *.kicad_pro *.kicad_sch; do
       if [[ -f "$file" ]]; then
           local extension="${file##*.}"
           local new_file="${new_name}.${extension}"
           mv "$file" "$new_file"
           print_success "Renamed $file to $new_file"
       else
           print_warning "$file does not exist."
       fi
   done
}

# --------------

# Main function
main() {
   # Author and Usage
   print_header "Script by: ${Author}${NewLn}   ${ExUsage}"

   # Rename the project files
   rename_project_files "$NEW_PROJECT_NAME"

   # Update the contents in the project files
   local pro_file="${NEW_PROJECT_NAME}.kicad_pro"
   local sch_file="${NEW_PROJECT_NAME}.kicad_sch"
   local pcb_file="${NEW_PROJECT_NAME}.kicad_pcb"

   update_file_content "$pro_file" "PROJECT_DESCRIPTION" "$NEW_DESCRIPTION"
   update_file_content "$pro_file" "PROJECT_NAME" "$NEW_PROJECT_NAME"
   update_file_content "$pro_file" "GIT_HEALTH" "$GIT_HEALTH"
   update_file_content "$pro_file" "GIT_VERSION" "$GIT_VERSION"

   update_title_block "$sch_file" "title" "$NEW_PROJECT_NAME"
   update_title_block "$sch_file" "date" "$NEW_DATE"
   update_title_block "$sch_file" "rev" "$NEW_REV"

   update_file_content "$pcb_file" "PROJECT_DESCRIPTION" "$NEW_DESCRIPTION"
   update_file_content "$pcb_file" "PROJECT_NAME" "$NEW_PROJECT_NAME"
   update_title_block "$pcb_file" "title" "$NEW_PROJECT_NAME"
   update_title_block "$pcb_file" "date" "$NEW_DATE"
   update_title_block "$pcb_file" "rev" "$NEW_REV"

   print_separator
   print_success "Script reached the end."
}

main "$@"
