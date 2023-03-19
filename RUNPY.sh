#!/usr/bin/zsh

# Specify the directory to search for the file
directory="/data/data/com.termux/files/home/.pysc"
log_directory="/data/data/com.termux/files/home/.shlog"
current_time=$(date +"%Y-%m-%d_%H-%M-%S")
log_file="$log_directory/RUNPY_$current_time.log"

# Create log directory if it doesn't exist
mkdir -p $log_directory

DOUGHNUT_FLAG="--doughnut"

# Function to log messages
log() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    message="$1"
    type="$2"
    code="$3"
    echo "[$timestamp][$type][$code] $message" >> $log_file
}

# Check for the hamburger flag and execute the hamburger script if present
if [[ "$1" == "$DOUGHNUT_FLAG" ]]; then
  log "INFO" "100" "RUNPY script started"
  $HOME/.egg/donut
  log "INFO" "300" "RUNPY script ended"
  exit 0
fi

# Log script start
log "RUNPY script started" "INFO" "100"

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
    echo "Filename is empty. Please try again"
    log "Filename is empty. Please try again." "ERROR" "101"
    continue
  fi

  setopt EXTENDED_GLOB
  matches=($directory/*(#i)${filename}*.py(N))

  if [[ ${#matches[@]} -eq 0 ]]; then
    clear
    echo "File does not exit: $filename"
    log "File does not exist: $filename" "ERROR" "102"
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
      echo "Invalid Choice. Please try again"
      log "Invalid choice. Please try again." "ERROR" "103"
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

  # Run the chosen script and log the result
  clear
  python3 "$filename"
  exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    log "Script successfully executed: $filename" "INFO" "200"
  else
    log "Script failed with exit code $exit_code: $filename" "ERROR" "201"
  fi

  # Prompt the user to run another script or exit
  while true; do
    echo "Run another script? (y/n) "
    read choice
    case $choice in
      [Yy]* ) clear; break;;
      [Nn]* ) log "RUNPY script ended" "INFO" "300"; exit;;
      * ) echo "\nPlease answer y or n.";;

    esac
    clear
  done
done

