# pgmk: PostgreSQL Database Management Kit

## Overview

`pgmk` is a Bash script designed to manage PostgreSQL databases by automating tasks such as creating directory structures, performing database dumps, synchronizing files between remote and local systems, and handling PostgreSQL operations like creating users, databases, and restoring dumps.

## Features

1. **Directory Structure Creation**: Creates a structured directory hierarchy for storing dumps, logs, and executables.
2. **Database Dumping**: Automates the process of dumping a remote PostgreSQL database and synchronizing it with the local system.
3. **User and Database Management**: Automates the creation and deletion of PostgreSQL users and databases.
4. **Logging**: Maintains logs of operations performed, including dump sizes and timestamps.
5. **Configuration Management**: Sources and writes configuration files to streamline repeated operations.
6. **Verbose and Debug Modes**: Provides options for verbose output and debugging information.

## Script Structure

### Helper Functions

- **say()**: Prints debug information if `debug` mode is enabled.
- **ensure_create()**: Ensures the creation of directories or files.
- **notify()**: Prints verbose information if `print_verbose` mode is enabled.

### Configuration Management

- **source_config_file()**: Sources the configuration file or creates it if it does not exist.
- **write_full_config()**: Writes the full configuration to a file.
- **source_and_write_config()**: Combines sourcing and writing configuration tasks.

### File System Hierarchy Standard (FHS) Creation

- **chmod_file()**: Changes file permissions.
- **fhs()**: Creates the required directory structure and files with appropriate permissions.

### Remote Operations

- **append_dump_log()**: Appends log information to the dump logs file.
- **perform_rsync()**: Synchronizes files between remote and local systems using `rsync`.
- **make_dump()**: Performs the database dump on the remote system and synchronizes the dump file locally.

### PostgreSQL Operations

- **check_func()**: Checks if the local database and user exist.
- **create_db()**: Creates a local PostgreSQL database.
- **drop_db()**: Drops the local PostgreSQL database if it exists.
- **create_user()**: Creates a local PostgreSQL user.
- **set_password_to_user()**: Sets a password for the local PostgreSQL user.
- **drop_user()**: Drops the local PostgreSQL user if it exists.
- **getcore()**: Retrieves the number of CPU cores for parallel operations.
- **load_db_init()**: Loads the initial database dump.
- **load_db_main()**: Cleans the existing database and loads new data from the latest dump.
- **perform_postgres_operations()**: Performs PostgreSQL operations based on the existence of the database and user.

### Main Function

- **main()**: The main function that orchestrates the overall workflow of the script, including sourcing configurations, creating directories, performing dumps, and managing PostgreSQL operations.

## Usage

```bash
pgmk
```

### Options

- **-v, --verbose**: Notifies operations performed.
- **--initialize**: Initializes the whole setup, including creating the database, user, dump files, and logs.
- **--user**: Changes the SSH user (prompts) and continues to execute `pgmk`.
- **--database**: Changes the remote database to dump (prompts) and continues to execute `pgmk`.
- **--dropdbsetup**: Drops the local database user and database, then exits.
- **--viewconfig**: Prints the `pgmk` configuration file and exits.
- **--connecttodb**: Connects to the local machine's `pgmk` database.
- **--debug**: Prints performed operations info and continues to execute `pgmk`.
- **--help**: Prints help information and exits.
- **--version**: Prints version information and exits.

## Example Usage

```bash
# Run pgmk with verbose mode
pgmk --verbose

# Initialize the setup
pgmk --initialize

# Drop the database setup
pgmk --dropdbsetup

# View the configuration file
pgmk --viewconfig

# Connect to the local pgmk database
pgmk --connecttodb
```

## Conclusion

`pgmk` is a powerful tool for managing PostgreSQL databases, providing automation for common tasks and ensuring consistency in database operations. With features like configuration management, logging, and remote synchronization, it simplifies the management of PostgreSQL databases in various environments.
