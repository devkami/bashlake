# Bashlake Project

## Overview

Bashlake is a project leveraging GNU/Linux bash shell scripts and MySQL databases to create a data lake. It integrates data from various sources and origins, providing a robust and efficient platform for data handling and analytics. The project combines modular scripts for data sourcing, security, logging, system utilities, and MySQL database management, making it a comprehensive toolkit for managing a wide range of data operations.

## Project Structure

Below is the project's script structure, organized as a root directory. Each script name links to its respective README.md file for detailed information:

- [**datasource.sh**](./datasource/README.md): Handles the integration and management of data from different sources.
- [**security.sh**](./security/README.md): Ensures data and access security through encryption and key management.
- [**log_lib.sh**](./log/README.md): Provides logging functionalities for tracking and auditing script executions.
- [**mysql_lib.sh**](./mysql/README.md): Manages MySQL database interactions, including installation, backups, and restoration processes.
- [**utils**](./utils/README.md): A collection of utility scripts including:
  - **constants.sh**: Defines constants and lists for use across various scripts.
  - **menus.sh**: Facilitates input validation and interactive menu selections.
  - **sysadmin_lib.sh**: Offers system administration utilities for script maintenance and system checks.

## Usage

To use Bashlake, clone the repository to your local environment and ensure you have MySQL and Bash available. Source the necessary scripts in your bash environment and follow the instructions provided in each script's README.md file for setup and usage.

## Features

- **Data Integration:** Seamlessly integrates data from multiple sources into a unified data lake.
- **Security:** Robust encryption and key management to secure data access and storage.
- **Logging:** Comprehensive logging for monitoring and auditing script activities.
- **MySQL Database Management:** Efficient management of MySQL databases, including backups and restorations.
- **Utilities:** A suite of utilities for enhancing script functionality and system management.

## Requirements

- GNU/Linux environment with Bash shell.
- MySQL Database Server.
- Necessary packages for each script (as outlined in their respective README.md files).

## Contributing

Contributions to Bashlake are welcome. Please refer to each script's README.md for specific guidelines on contributing to that part of the project.

### Author: [Maicon de Menezes](https://github.com/maicondmenezes)

## License

Bashlake is released under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Notes

Bashlake is designed with modularity and ease of use in mind. It's adaptable to various data sources and can be extended or customized as needed. Ensure all dependencies are installed as per the individual script requirements for optimal performance.
