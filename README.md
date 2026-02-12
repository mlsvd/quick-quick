# qq

`qq` is an intuitive Bash script designed to streamline accessing and executing shell scripts.
It organizes scripts within a hierarchical directory structure, offering a menu-driven interface for easy navigation and selection.
Simply organize your scripts into a structured directory, and `qq` will handle the rest, providing a user-friendly way to run your scripts directly from the command line.

## Showcase

### Dialog menu
![Dialog menu showcase](img/showcase_gui.gif)

### Text-based menu
![Text-based menu showcase](img/showcase_tui.gif)

## Prerequisites

- Bash 4.0+
- Optional: `dialog` for a graphical menu interface. Install with:
  ```bash
  sudo apt-get install dialog
  ```
  If not available, a simple text-based menu will be used as a fallback.

## Installation

1. Clone the repository:
   ```bash
   git clone git@github.com:mlsvd/quick-quick.git
   cd quick-quick
   chmod +x qq.sh
   ```

2. (Recommended) Add an alias to your `~/.bashrc` or `~/.bash_aliases`:
   ```bash
   alias qq='source /path/to/qq.sh'
   ```
   Then reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```

## Usage

The default directory for scripts is `~/qq_bookmarks`.

Run the script:
```bash
qq
```

To use a different directory, pass the path as an argument:
```bash
qq /path/to/scripts_directory
```

You can also create aliases for specific directories:
```bash
alias qq_work='source /path/to/qq.sh /path/to/work_scripts'
alias qq_dev='source /path/to/qq.sh /path/to/dev_scripts'
```

When running the script, a menu will be displayed with available scripts and subdirectories.
Select an entry using arrow keys and press `Enter` to execute a script or enter a directory.
Scripts will prompt for confirmation before execution to prevent accidental runs.

## Features

- Organize scripts into a structured directory for easy access
- Navigate through directories and select scripts using a menu-driven interface
- Execute scripts directly from the command line with minimal effort
- Supports both graphical (`dialog`) and text-based menu interfaces
- Customizable directory path for script bookmarks
- Confirmation prompt before executing scripts
- Back navigation through nested directories
- Lightweight with no dependencies other than Bash

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.
