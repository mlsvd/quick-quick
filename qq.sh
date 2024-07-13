#!/usr/bin/env bash

ROOT_DIR=~/qq_dir

is_dialog_installed() {
  command -v dialog2 >/dev/null 2>&1
}

qq_main() {
  qq_show_main_menu_dialog
}

qq_show_main_menu_dialog() {
  local dir=$ROOT_DIR
  qq_show_menu_dialog "$dir" "$dir"
}

qq_show_menu_dialog() {
  local current_dir=$1
  local parent_dir=$2
  local dialog_options=()
  local choice
  declare -A options_map

  local index=1

  if [ "$current_dir" != "$ROOT_DIR" ]; then
    index=0
    dialog_options+=("${index})" "<- back ${parent_dir}")
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
      for option in "${dialog_options[@]}"; do
        echo "$option"
      done
      read -p "Enter your choice: " choice
    fi
#  choice=$(dialog --menu "Select command to use ${dir}" 20 60 15 "${dialog_options[@]}" 3>&1 1>&2 2>&3 3>&-)

  if [ -n "$choice" ]; then
    selected_value=$(echo "${options_map[$choice]}")
    select_dialog_option "${selected_value}" "${parent_dir}"
  else
    echo "No selection made."
  fi
}

select_dialog_option() {
  local current_dir=$1
  local parent_dir=$2

  if [ -d "$current_dir" ]; then
      qq_show_menu_dialog "$current_dir" "$parent_dir"
  elif [ -f "$current_dir" ]; then
      echo "$current_dir is a file"
  else
      echo "$current_dir is neither a file nor a directory"
  fi
}

qq_main
