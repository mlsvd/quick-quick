# qq

`qq` is an intuitive bash script designed to streamline the process of accessing and executing shell scripts. 
It organizes scripts within a hierarchical directory structure, offering a menu-driven interface for easy navigation and selection. 
This setup allows users to efficiently group and manage shell scripts, enabling quick access and execution with minimal effort. 
Simply organize your scripts into a structured directory, and `qq` will handle the rest, providing a user-friendly way to run your scripts directly from the command line.

## Showcase with dialog menu
![](img/showcase_gui.gif)

## Showcase with text-based menu
![](img/showcase_tui.gif)

## Prerequisites

- Bash
- Optional: `dialog` for graphical menu interface. (If not available, simple text-based menu will be used)

## Installation

1. Clone the repository:
    ```sh
    git@github.com:mlsvd/quick-quick.git
    cd quick-quick
    chmod +x qq.sh
    ```


## Usage

Default folder for bookmarks is: `~/qq_bookmarks` _(or /home/%username%/qq_bookmarks)_

Run the script:
```sh
./qq.sh
```

In order to use another directory with scripts, simply pass the path as an argument:
```sh
./qq.sh /path/to/script_bookmarks_directory
```

It is recommended to add alias to `.bashrc` or `.bash_aliases` file:
```sh
alias qq='/path/to/qq.sh'
```
This will make it easier to run the script from any location.
Using aliases, it is also possible to create shortcuts for specific directories:
```sh
alias qq='/path/to/qq.sh'
alias qq_work='/path/to/qq.sh /path/to/work_scripts'
alias qq_dev='/path/to/qq.sh /path/to/dev_scripts'
```

When running the script, a menu will be displayed with the available scripts. If directory contains subdirectories, they will be displayed as well.
Select the desired script or directory using arrow keys and press `Enter` to execute the script or enter the directory.
Selected scripts will prompt for confirmation before execution in order to not accidentally run the script.

## Features
- Organize scripts into a structured directory for easy access
- Navigate through directories and select scripts using a menu-driven interface
- Execute scripts directly from the command line with minimal effort
- Supports both graphical and text-based menu interfaces
- Customizable directory path for script bookmarks
- Confirmation prompt before executing scripts
- Lightweight and easy to use
- No dependencies other than Bash

## License
This project is licensed under the MIT License. See the [](LICENSE.md) file for details.