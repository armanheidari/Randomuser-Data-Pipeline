
# Randomuser Data Pipeline

<img src="logo.png" style="display: block; margin: auto; height: 500px; width: 500px;">

## About the Project

This project is a robust and scalable data pipeline built using Python, Kafka, NocoDB, and PostgreSQL. It is designed to fetch, process, and store data in a streamlined and efficient manner. The entire system is containerized using Docker, ensuring easy setup and deployment.
The data pipeline operates by downloading data from randomuser.me, a free and open-source API for generating random user data. This data is then processed through a series of Kafka consumers, each adding additional information and transformations.

- - -
## Repository Structure

The repository is organized into four main directories, each serving a specific purpose in the project:

1. **Administrator_scripts**: This directory contains scripts that manage the flow of the application. These scripts coordinate the various components of the system and ensure smooth operation.

2. **Python_Files**: This directory houses the Python scripts that form the core of the data pipeline. It includes four main `.py` files as well as additional scripts for adding data to NoCoDB and a logger for monitoring the system's operation.
	- **0-Get_Data.py**: This script fetches data from randomuser.me and sends it to the first Kafka consumer.
	- **1-Add_Timestamp**: This consumer adds a timestamp column to the data, providing a chronological record of when the data was fetched.
	- **2-Add_Label**: This consumer enriches the data by adding a random company name to each record, generated using the Faker library.
	- **3-Add_Database**: This consumer saves the enriched data into two databases: PostgreSQL and NocoDB.

3. **Database**: This directory is dedicated to database management. It includes the `Backup.sh` script for creating data backups, NoCoDB settings, and a `Data` subdirectory where the actual data is stored.

4. **Database-Init**: This directory contains the SQL file used to initialize the database. This setup script ensures that the database is properly configured before the data pipeline begins operation.

Each of these directories contributes to the overall functionality of the data pipeline, ensuring efficient data fetching, processing, and storage.

- The `0-Get_Data.py` script is executed once per minute via crontab, allowing the database to grow incrementally over time.
- To ensure data integrity and availability, the system incorporates a robust backup mechanism. A script named `Backup.sh` is executed every 5 minutes via crontab, creating regular backups of the data. In addition to this, Write-Ahead Logging (WAL) archiving is activated, providing a reliable method for data recovery and minimizing data loss.

- - -
## Usage

Follow these steps to set up and run the project:

1. **Build the Project**: Run the `Project_Initialize.sh` script. This script builds the project and prepares all the necessary components. To run the script, open a terminal in the project's root directory and execute the following command:

```bash
./Project_Initialize.sh
```

- Make sure the script is executable. If not, you can make it executable by running `chmod +x Project_Initialize.sh`.

2. **Start the Services**: After the project has been built, you can start the services by running the `Project_Start.sh` script. Again, open a terminal in the project's root directory and execute the following command:

```bash
./Project_Start.sh
```

That's it! Your data pipeline should now be up and running. 😁

- - -
## Installation

- All the required libraries will be installed automatically, just enjoy! 😜

- - -
## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

- - -
## License

BSD 3-Clause "New" or "Revised" License
