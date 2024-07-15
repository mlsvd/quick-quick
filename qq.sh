#!/usr/bin/env bash

ROOT_DIR=~/qq_dir

is_dialog_installed() {
  command -v dialog >/dev/null 2>&1
}

qq_main() {
  local dir=${1:-$ROOT_DIR}
  qq_show_main_menu_dialog "$dir"
}

qq_show_main_menu_dialog() {
  local dir=$1
  # Check if the directory is readable and accessible
  if [ ! -d "$dir" ] || [ ! -r "$dir" ]; then
    echo "Error: The directory '$dir' is not accessible or readable."
    return 1
  fi

  qq_show_menu_dialog "$dir" "$dir"
}

qq_show_menu_dialog() {
  local current_dir=$1
  local parent_dir=$2
  local dialog_options=()
  local choice
  declare -A options_map

  clear

  local index=1
  if [ "$current_dir" != "$ROOT_DIR" ]; then
    index=0
    dialog_options+=("${index})" "<<< return back")
    options_map["${index})"]="$parent_dir"
    index=$((index + 1))
  fi

  for entry in "$current_dir"/*; do
    if [ -d "$entry" ]; then
      dialog_options+=("${index})" "$(basename "$entry")")
      options_map["${index})"]="${current_dir}/$(basename "$entry")"
    elif [ -f "$entry" ]; then
      dialog_options+=("${index})" "./$(basename "$entry")")
      options_map["${index})"]="${current_dir}/$(basename "$entry")"
    fi
    index=$((index + 1))
  done

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
    local sanitized_choice=$(sanitize_user_choice "$choice")
    selected_value=$(echo "${options_map[$sanitized_choice]}")
    select_dialog_option "${selected_value}" "${parent_dir}"
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
  echo $sanitized_choice
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

    [[ $YN == "y" || $YN == "Y" || $YN == "" ]] && sh ${current_dir}
  else
      echo "Selected item cannot be processed"
  fi
}

qq_main "$@"
