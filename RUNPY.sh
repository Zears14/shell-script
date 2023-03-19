#!/usr/bin/zsh

# Specify the directory to search for the file
directory="/data/data/com.termux/files/home/.pysc"

while true; do
  # List all the scripts
  echo "Here is a list of all scripts:"
  ls $directory -1v | grep '\.py$' | cat -n

  # Prompt the user to enter the script name
  echo "Enter the script name:"
  read filename

  # Check if filename is empty and restart the script
  if [[ -z $filename ]]; then
    clear
    echo "Error: filename cannot be empty. Please try again."
    continue
  fi

  setopt EXTENDED_GLOB
  matches=($directory/*(#i)${filename}*.py(N))

  if [[ ${#matches[@]} -eq 0 ]]; then
    clear
    echo "Error: file does not exist: $filename"
    continue
  elif [[ ${#matches[@]} -gt 1 ]]; then
    # Prompt the user to choose from multiple matches
    clear
    echo "Multiple matches found. Please choose a file to run:"
    # DEBUG
    # echo "Matches: ${matches[@]}"
    i=0
    for match in "${matches[@]}"; do
      echo "[$((++i))] ${match##*/}"
    done

    echo "Enter your choice [1-${#matches[@]}]: \c"
    read choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#matches[@]} )); then
      clear
      echo "Error: invalid choice. Please try again."
      continue
    fi
    filename="${matches[choice]}"
    echo "File exists: $filename"
  else
    echo "File exists: ${matches[1]##*/}"
    filename=${matches[1]}
  fi
  #DEBUG
  # echo "Chosen file: $filename"

  clear
  python3 "$filename"

  # Prompt the user to run another script or exit
  while true; do
    echo "Run another script? (y/n) "
    read choice
    case $choice in
      [Yy]* ) clear; break;;
      [Nn]* ) exit;;
      * ) echo "\nPlease answer y or n.";;

    esac
    clear
  done
done
