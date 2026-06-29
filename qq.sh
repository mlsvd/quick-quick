#!/usr/bin/env bash

readonly ROOT_DIR=~/qq_bookmarks
BOOKMARKS_DIR="$ROOT_DIR"


is_dialog_installed() {
  command -v dialog >/dev/null 2>&1
}
qq_show_help() {
  echo "Usage: qq [OPTIONS]"
  echo
  echo "An intuitive Bash script to organize, select, and run shell scripts."
  echo
  echo "Options:"
  echo "  --path=PATH, --path PATH  Specify the root bookmarks directory path"
  echo "                            (default: ~/qq_bookmarks)"
  echo "  -h, --help                Display this help message and exit"
  echo
  echo "Features:"
  echo "  - Interactive menu selection (graphical dialog if 'dialog' is installed,"
  echo "    falling back to a text-based numbered terminal menu)"
  echo "  - Folder navigation with automatic back-links"
  echo "  - Safety prompt confirmation before running any shell scripts"
}

qq_main() {
  local dir="$ROOT_DIR"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        qq_show_help
        return 0
        ;;
      --path=*)
        dir="${1#*=}"
        shift
        ;;
      --path)
        if [[ -n "$2" ]]; then
          dir="$2"
          shift 2
        else
          echo "Error: --path requires a directory path."
          return 1
        fi
        ;;
      *)
        echo "Error: Unknown argument '$1'"
        echo "Run with -h or --help to see usage."
        return 1
        ;;
    esac
  done

  # Expand tilde ~ if present
  dir="${dir/#\~/$HOME}"
  BOOKMARKS_DIR="$dir"

  qq_show_main_menu_dialog "$dir"
}

qq_show_main_menu_dialog() {
  local dir=$1

  # Scenario 1: Folder does not exist
  if [ ! -e "$dir" ]; then
    read -p "Directory '$dir' does not exist. Would you like to create it? [y/N]: " choice
    case "$choice" in
      [yY][eE][sS]|[yY])
        if mkdir -p "$dir" 2>/dev/null; then
          echo "Created directory: $dir"
        else
          echo "Error: Failed to create directory '$dir'. Please check parent directory permissions."
          return 1
        fi
        ;;
      *)
        echo "Error: Directory '$dir' does not exist."
        return 1
        ;;
    esac
  fi

  # Check if path exists but is not a directory
  if [ ! -d "$dir" ]; then
    echo "Error: '$dir' exists but is not a directory."
    return 1
  fi

  # Scenario 2: Folder exists but has no access (lack of read/execute permissions)
  if [ ! -r "$dir" ] || [ ! -x "$dir" ]; then
    echo "Error: Permission denied. The directory '$dir' exists, but you lack read/execute permissions."
    echo "To fix this, run: chmod +rx \"$dir\""
    return 1
  fi

  qq_show_menu_dialog "$dir" "$dir"
}

qq_show_menu_dialog() {
  local current_dir=$1
  local parent_dir=$2
  local dialog_options=()
  local choice
  local -A options_map

  clear

  local index=1
  if [ "$current_dir" != "$BOOKMARKS_DIR" ]; then
    index=0
    dialog_options+=("${index})" "<<< return back")
    options_map["${index})"]="$parent_dir"
    index=$((index + 1))
  fi

  local entry_count=0
  shopt -s nullglob
  for entry in "$current_dir"/*; do
    if [ -d "$entry" ]; then
      dialog_options+=("${index})" "$(basename "$entry")")
      options_map["${index})"]="${current_dir}/$(basename "$entry")"
      entry_count=$((entry_count + 1))
    elif [ -f "$entry" ]; then
      dialog_options+=("${index})" "./$(basename "$entry")")
      options_map["${index})"]="${current_dir}/$(basename "$entry")"
      entry_count=$((entry_count + 1))
    fi
    index=$((index + 1))
  done
  shopt -u nullglob

  if [ "$entry_count" -eq 0 ]; then
    if [ "$current_dir" = "$BOOKMARKS_DIR" ]; then
      echo "No entries available in '${current_dir}'."
      echo
      echo "To add a new entry, place scripts or directories inside it:"
      echo "  1. Create a script file:"
      echo "     touch \"${current_dir}/example.sh\""
      echo "  2. Write your commands inside it, e.g.:"
      echo "     echo '#!/usr/bin/env bash' > \"${current_dir}/example.sh\""
      echo "     echo 'echo \"Hello World!\"' >> \"${current_dir}/example.sh\""
      echo "  3. Make it executable (optional but recommended):"
      echo "     chmod +x \"${current_dir}/example.sh\""
      return
    fi
  fi

  if [ ${#dialog_options[@]} -eq 0 ]; then
    echo "No entries available."
    return
  fi

  if is_dialog_installed; then
    choice=$(dialog --menu "Select command to use ${current_dir}" 20 60 15 "${dialog_options[@]}" 3>&1 1>&2 2>&3 3>&-)
  else
    echo "Select command to use ${current_dir}:"
    echo "-------------------------------------"
    for ((i=0; i<${#dialog_options[@]}; i+=2)); do
      key=${dialog_options[i]}
      value=${dialog_options[i+1]}
      echo "$key $value"
    done
    echo "-------------------------------------"
    read -p "Enter your choice: " choice
  fi

  if [ -n "$choice" ]; then
    local sanitized_choice
    sanitized_choice=$(sanitize_user_choice "$choice")
    local selected_value="${options_map[$sanitized_choice]}"
    select_dialog_option "${selected_value}" "${current_dir}"
  else
    echo "No selection made."
  fi
}

sanitize_user_choice() {
  local choice=$1
  local sanitized_choice="${choice//[^0-9]/}"
  # Check if the last character is not ')', then append ')'
  if [[ "$sanitized_choice" != *")" ]]; then
    sanitized_choice="${sanitized_choice})"
  fi
  echo "$sanitized_choice"
}

select_dialog_option() {
  local current_dir=$1
  local parent_dir=$2

  clear

  if [ -d "$current_dir" ]; then
    qq_show_menu_dialog "$current_dir" "$parent_dir"
  elif [ -f "$current_dir" ]; then
    read -e -p "
    Do you wish to run ${current_dir} ? [y/n] (default: y)" YN

    [[ $YN == "y" || $YN == "Y" || $YN == "" ]] && bash "${current_dir}"
  else
    echo "Selected item cannot be processed"
  fi
}

qq_main "$@"
