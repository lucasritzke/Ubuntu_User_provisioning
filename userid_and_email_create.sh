#!/bin/bash

password_db=lritzke
user_db=lritzke
generate_userid() {
  local firstname=$1
  local lastname=$2

  firstname=$(echo "$firstname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
  firstname=${firstname//ç/c}

  lastname=$(echo "$lastname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')
  lastname=${lastname//ç/c}

  # Verifica se o firstname tem menos de três letras e preenche com caracteres aleatórios se necessário
  if [[ ${#firstname} -lt 3 ]]; then
    while [[ ${#firstname} -lt 3 ]]; do
      random_chars=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 1 | head -n 1)
      firstname="${firstname}${random_chars}"
    done
  fi

  # Verifica se o lastname tem menos de uma letra e preenche com um caractere aleatório se necessário
  if [[ ${#lastname} -lt 1 ]]; then
    random_char=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 1 | head -n 1)
    lastname="${lastname}${random_char}"
  fi

  name="${firstname} ${lastname}"

  result_user=$(mysql --user=$user_db --password=$password_db spreadsheet -e "SELECT UserID FROM collaborator_information WHERE name='$firstname $lastname'" 2> /dev/null)

  characters="abcdefghijklmnopqrstuvwxyz"
  number_format="%03d" # Format for the numeric part (e.g., 001, 002, 003, ...)
  number_format_v2="%02d" # Format for the numeric part in the second loop (e.g., 01, 02, 03, ...)

  if [ -n "$result_user" ]; then
    userid="${firstname:0:3}${lastname:0:1}"
    for number in {1..999}; do
      temp_userid="${userid}$(printf "$number_format" $number)"
      temp_result=$(mysql --user=$user_db --password=$password_db spreadsheet -e "SELECT UserID FROM collaborator_information WHERE UserID='$temp_userid'" 2> /dev/null)
      if [ -z "$temp_result" ]; then
        userid="$temp_userid"
        break
      fi
      if [[ $number -eq 999 ]]; then
        break
      fi
    done

    if [[ $number -eq 999 ]]; then
      for first_digit in {0..9}; do
        for second_letter in $(echo $characters | grep -o .); do
          for number_v2 in {1..99}; do
            temp_userid="${userid}${second_letter}$(printf "$number_format_v2" $number_v2)"
            temp_result=$(mysql --user=$user_db --password=$password_db spreadsheet -e "SELECT UserID FROM collaborator_information WHERE UserID='$temp_userid'" 2> /dev/null)
            if [ -z "$temp_result" ]; then
              userid="$temp_userid"
              break
            fi
            if [[ $second_letter == "z" && $number_v2 == 99 ]]; then
              echo "Número máximo de usuários alcançado. Encerrando o programa."
              exit
            fi
          done
          if [ -z "$temp_result" ]; then
            break
          fi
        done
        if [ -z "$temp_result" ]; then
          break
        fi
      done
    fi

  else
    userid="${firstname:0:3}${lastname:0:4}"
  fi

  echo "$userid"
}

generate_email() {
  local firstname=$1
  local lastname=$2
  local userid=$3

  firstname=$(echo "$firstname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
  firstname=${firstname//ç/c}

  lastname=$(echo "$lastname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
  lastname=${lastname//ç/c}

  if [ -n "$result_email" ]; then
    local email="$firstname.$lastname_$userid@company.com"
    echo $email
  else
    local email="$firstname.$lastname@company.com"
    echo $email
  fi
}

generate_user_name() {
  local firstname=$1
  local lastname=$2

  firstname=$(echo "$firstname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
  firstname=${firstname//ç/c}

  lastname=$(echo "$lastname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
  lastname=${lastname//ç/c}
  
  user_name="$firstname $lastname"
  echo $user_name

}

process_spreadsheet() {
  while IFS=',' read -r name lastname office user_type admission_day; do
    if [[ $name == "name"* ]]; then
          continue
    fi
    userid=$(generate_userid $name $lastname)
    email=$(generate_email $name $lastnamei $userid)
    user_name=$(generate_user_name $name $lastname)
    echo "Name: $user_name"
    echo "UserID: $userid"
    echo "Email: $email"
    echo "office: $office"
    echo "user_type: $user_type"
    echo "Admission_Day: $admission_day"
    echo
    if [[ -n $name && -n $lastname && -n $office && -n $user_type && -n $admission_day ]]; then
	mysql --user=$user_db --password=$password_db spreadsheet << EOF 2> /dev/null 
	INSERT INTO collaborator_information (UserID, email, name, office, user_type, admission_day) VALUES ('$userid', '$email', '$user_name', '$office', '$user_type', '$admission_day');
EOF
    else
      echo "Algo errado"
    fi
  done < planilha.csv
}
process_spreadsheet
