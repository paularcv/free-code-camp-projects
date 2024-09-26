#! /bin/bash

# Function to display services
display_services() {
  echo "Here are the services we offer:"
  echo "$services" | while IFS='|' read -r service_id name; do
    echo "$service_id) $name"
  done
}

# Function to fetch and display services
fetch_services() {
  services=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id, name FROM services ORDER BY service_id;")
}

# Function to fetch customer_id by phone number
fetch_customer_id() {
  customer_id=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
}

# Function to add a new customer
add_customer() {
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
}

# Function to add an appointment
add_appointment() {
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
}

# Fetch services initially
fetch_services

# Welcome message
echo "Welcome to the Salon!"

# Loop to prompt for a valid service_id
while true; do
  display_services
  echo "Please enter a service_id:"
  read SERVICE_ID_SELECTED

  # Check if the entered service_id exists
  service_exists=$(echo "$services" | grep -w "$SERVICE_ID_SELECTED")

  if [[ -n "$service_exists" ]]; then
    echo "You selected service ID $SERVICE_ID_SELECTED"
    break
  else
    echo "Invalid service ID. Please try again."
  fi
done

# Prompt for phone number
echo "Please enter your phone number:"
read CUSTOMER_PHONE

# Fetch customer_id based on the provided phone number
fetch_customer_id

# Check if the customer exists
if [[ -z "$customer_id" ]]; then
  # Customer does not exist; prompt for name
  echo "You are not a registered customer. Please enter your name:"
  read CUSTOMER_NAME

  # Add the new customer to the database
  add_customer

  # Fetch the customer_id again after adding
  fetch_customer_id
else
  # Customer exists; fetch their name
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE customer_id = $customer_id;")
fi

# Prompt for service time
echo "Please enter the appointment time:"
read SERVICE_TIME

# Add the appointment
add_appointment

# Output confirmation message
echo "I have put you down for a $(echo "$service_exists" | cut -d '|' -f2) at $SERVICE_TIME, $CUSTOMER_NAME."