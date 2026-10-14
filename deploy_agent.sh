#!/bin/bash
# deploy_agent.sh
# Automates deployment, execution, and log archiving
# for the student attendance tracker project.
# --- Signal Handling (Ctrl+C / Ctrl+Z) ---
trap 'handle_interrupt' SIGINT SIGTSTP

handle_interrupt() {
    echo " Deployment interrupted. Archiving partial project..."
    if [ -d "$PROJECT_DIR" ]; then
        zip -r "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR"
        echo " Archived incomplete project as ${PROJECT_DIR}_archive.zip"
    fi
    exit 1
}

# --- Menu / Feature Selection ---
echo "Select a feature:"
echo "1) Deploy Application"
echo "2) Run Application"
echo "3) Archive Logs"
read -p "Enter choice [1-3]: " choice

# --- Feature 1: Deploy Application ---
deploy_app() {
    # Pre-flight checks
    command -v python3 >/dev/null 2>&1 || { echo "Oops!  python3 not installed"; exit 1; }
    command -v zip >/dev/null 2>&1 || { echo "Oh oh!  zip not installed"; exit 1; }

    # Ask for project name
    read -p "Enter project name (e.g., myclass): " pname
    PROJECT_DIR="attendance_tracker_${pname}"

    # Check if directory exists
    if [ -d "$PROJECT_DIR" ]; then
        read -p "Directory exists. Overwrite? (y/n): " overwrite
        [ "$overwrite" != "y" ] && exit 1
        rm -rf "$PROJECT_DIR"
    fi

    # Create structure
    mkdir -p "$PROJECT_DIR/reports" "$PROJECT_DIR/Helpers" "$PROJECT_DIR/templates"

    # Copy templates
    cp templates/attendance_checker.py "$PROJECT_DIR/"
    cp templates/config.json "$PROJECT_DIR/Helpers/"

    # Roster setup
    echo "Roster setup:"
    echo "A) Copy from template"
    echo "B) Generate fresh roster"
    read -p "Choose option [A/B]: " roster_choice

    if [ "$roster_choice" == "A" ]; then
        read -p "How many students to copy? " num
        head -n $((num+1)) templates/assets.csv > "$PROJECT_DIR/Helpers/assets.csv"
        sed -i 's/"total_sessions":.*/"total_sessions": 5/' "$PROJECT_DIR/Helpers/config.json"
    else
        read -p "How many students to generate? " num
        echo "Email,Names,Attendance Count,Absence Count" > "$PROJECT_DIR/Helpers/assets.csv"
        for i in $(seq 1 $num); do
            echo "student${i}@example.com,Student ${i},0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
        done
        sed -i 's/"total_sessions":.*/"total_sessions": 1/' "$PROJECT_DIR/Helpers/config.json"
    fi

    # Permissions
    chmod +x "$PROJECT_DIR/attendance_checker.py"
    chmod 600 "$PROJECT_DIR/Helpers/config.json"
    echo "Permissions set: attendance_checker.py executable, config.json restricted to owner read/write only."

    # Threshold update
    read -p "Update thresholds? (y/n): " update
    if [ "$update" == "y" ]; then
        read -p "Enter warning threshold: " warn
        read -p "Enter failure threshold: " fail
        sed -i "s/\"warning\": [0-9]\+/\"warning\": $warn/" "$PROJECT_DIR/Helpers/config.json"
        sed -i "s/\"failure\": [0-9]\+/\"failure\": $fail/" "$PROJECT_DIR/Helpers/config.json"
    fi

    echo " Deployment complete. Running application..."
    run_app "$PROJECT_DIR"
}

# --- Feature 2: Run Application ---
run_app() {
    cd "$1" || exit 1
    python3 attendance_checker.py
}

# --- Feature 3: Archive Logs ---
archive_logs() {
    read -p "Enter project name: " pname
    PROJECT_DIR="attendance_tracker_${pname}"

    mkdir -p "$PROJECT_DIR/archives/attendance" "$PROJECT_DIR/archives/absent"

    timestamp=$(date +"%Y%m%d_%H%M%S")

    if [ -f "$PROJECT_DIR/reports/attendance.log" ]; then
        cp "$PROJECT_DIR/reports/attendance.log" \
           "$PROJECT_DIR/archives/attendance/attendance_${timestamp}.log"
        echo " Archived attendance.log"
    else
        echo " No attendance.log found"
    fi

    if [ -f "$PROJECT_DIR/reports/absent.log" ]; then
        cp "$PROJECT_DIR/reports/absent.log" \
           "$PROJECT_DIR/archives/absent/absent_${timestamp}.log"
        echo " Archived absent.log"
    else
        echo " No absent.log found"
    fi
}

# --- Dispatch based on choice ---
case $choice in
    1) deploy_app ;;
    2) read -p "Enter project name: " pname; run_app "attendance_tracker_${pname}" ;;
    3) archive_logs ;;
    *) echo "Invalid choice"; exit 1 ;;
esac
