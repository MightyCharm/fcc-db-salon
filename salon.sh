#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# user can choose a service
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e $1
  fi

  echo -e "\n~~~~~ Welcome to our salon ~~~~~\n\nWhich service do you want?"
  echo -e "1) cut\n2) wash\n3) trim\n4) exit"
  
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  1) CUSTOMER_DATA "cut" ;;
  2) CUSTOMER_DATA "wash" ;;
  3) CUSTOMER_DATA  "trim" ;;
  4) EXIT ;;
  *) MAIN_MENU "\nCould not find the service. Please enter number (1-4) again."
  esac
}

# get and check data 
CUSTOMER_DATA() {  
  echo -e "Please enter your phone number:"
  read CUSTOMER_PHONE

  # get phone number from database
  CHECK_PHONE=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if CHECK_PHONE is empty, customer is not in the database
  if [[ -z $CHECK_PHONE ]]
  then
    echo -e "\nPlease enter your name:"
    read CUSTOMER_NAME
    # insert data
    INSERT_PHONE_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

  # customer is already in database
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  echo -e "\nWhat time do you want your appointment to be?"
  read SERVICE_TIME

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # create new row in appointments table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  # output formated message for customer
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

EXIT() {
  echo -e "\n~~~~~ Thank you for visiting. Goodbye. ~~~~~~"
}

MAIN_MENU
