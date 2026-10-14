# Deploy Agent Project

## Overview
This project provides a shell script (`deploy_agent.sh`) that automates the deployment, execution, and archiving of an attendance tracking application. It manages class rosters, tracks attendance, logs results, and safely archives logs with timestamps. Signal handling ensures graceful recovery if the process is interrupted.

## Features
- **Deploy Application**
  - Creates a new project folder (`attendance_tracker_<projectname>`).
  - Copies unmodified source files (`attendance_checker.py`, `assets.csv`, `config.json`) from the `templates/` directory.
  - Sets up roster (copy from template or generate fresh).
  - Allows updating attendance thresholds (warning/failure).
  - Runs the Python application to verify deployment.

- **Run Application**
  - Executes `attendance_checker.py` interactively.
  - Prompts user to mark students present/absent.
  - Logs results in `reports/attendance.log` and `reports/absent.log`.

- **Archive Logs**
  - Copies log files into `archives/attendance/` and `archives/absent/`.
  - Adds timestamps to filenames for versioned storage.

- **Signal Handling**
  - Detects interruptions (Ctrl+C, Ctrl+Z).
  - Archives partial project into a zip file.
  - Exits cleanly without leaving broken directories.

## Project Structure
deploy_agent_pacifiquem-dev/
├── deploy_agent.sh
├── templates/
│   ├── attendance_checker.py
│   ├── assets.csv
│   └── config.json
└── attendance_tracker_<projectname>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
├── reports/
│   ├── attendance.log
│   └── absent.log
└── archives/
├── attendance/
│   └── attendance_YYYYMMDD_HHMMSS.log
└── absent/
└── absent_YYYYMMDD_HHMMSS.log

## How to Run the Script and Select a Feature
1. Navigate to the project root:
  
  cd deploy_agent_pacifiquem-dev
2. Make the script executable:

 chmod +x deploy_agent.sh 
3. Run the script:
 ./deploy_agent.sh
4. Choose a feature from the menu:

1 for  Deploy Application

2 for  Run Application

3 for  Archive Logs
## How Threshold Update Works
During deployment, the script asks if you want to update thresholds.

If you choose yes, you enter new values for:

Warning threshold (default 75)

Failure threshold (default 50)

The script uses "sed" to edit these values directly in Helpers/config.json.
## How Log Archiving Works
Selecting Feature 3 (Archive Logs) moves logs into timestamped archive directories:

reports/attendance.log → archives/attendance/attendance_YYYYMMDD_HHMMSS.log

reports/absent.log → archives/absent/absent_YYYYMMDD_HHMMSS.log
## How to Test Ctrl+C / Ctrl+Z Path
Run Feature 1 (Deploy Application).

While deployment is in progress, press Ctrl+C or Ctrl+Z.

The script detects the interruption and:

Prints a warning message.

Archives the partial project into a .zip file.
## How the Deployed Application Structure Was Tested
After deployment, the directory tree was verified with "ls -R"
Permissions were confirmed:

attendance_checker.py is executable (chmod +x).

Helpers/config.json is restricted to owner read/write only (chmod 600).

Running the application (Feature 2) successfully logged attendance and generated alerts, proving the structure works.
