#!/bin/bash

create_user() {
    local firstname=$1
    local lastname=$2

    firstname=$(echo "$firstname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
    firstname=${firstname//ç/c}

    lastname=$(echo "$lastname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
    lastname=${lastname//ç/c}

    result_user_id=$(mysql --user="$user_db" --password="$password_db" spreadsheet -e "SELECT UserID FROM collaborator_information WHERE name='$firstname $lastname'" 2> /dev/null)

    if [ -n "$result_user_id" ]; then
        while IFS= read -r userid; do
            if [[ $userid == "UserID" ]]; then
                continue
            fi

            username="$userid"
            password="$userid"

            if id "$username" >/dev/null 2>&1; then
                echo "Usuário $username já existe."
            else
                useradd -m -s /bin/bash "$username"
                echo "$username:$password" | chpasswd
                echo "Usuário $username criado com senha $password."

                # Definir prompt personalizado para o usuário
                echo 'export PS1="\u@\h:\w\$ "' >> "/home/$username/.bashrc"
            fi
        done <<< "$result_user_id"
    else
        echo "Nenhum resultado encontrado."
    fi
}

set_user_access() {
    local firstname=$1
    local lastname=$2

    firstname=$(echo "$firstname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
    firstname=${firstname//ç/c}

    lastname=$(echo "$lastname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
    lastname=${lastname//ç/c}

    result_user_type=$(mysql --user="$user_db" --password="$password_db" spreadsheet -e "SELECT user_type FROM collaborator_information WHERE name='$firstname $lastname'" 2> /dev/null)

    if [ -n "$result_user_type" ]; then
        while IFS= read -r usertype; do
            if [[ $usertype == "user_type" ]]; then
                continue
            fi

            usertype=$(echo "$usertype" | tr -d ' ') 

            case "$usertype" in
                "root")
                    # Adicionar permissões de root ao usuário
                    echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers >/dev/null
                    sudo usermod -aG sudo "$username"  # Adicionar usuário ao grupo sudo
                    echo "Usuário $username tem acesso de root na máquina."
                    ;;
                "sudo")
                    # Adicionar permissões de sudo ao usuário
                    echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers >/dev/null
                    echo "Usuário $username tem acesso de sudo na máquina."
                    ;;
                "readandexecute")
                    # Verificar se o usuário existe antes de atribuir permissões
                    if id "$username" >/dev/null 2>&1; then
                        sudo chmod +rx "/home/$username"
                        echo "Usuário $username tem acesso de leitura e execução na máquina."
                    else
                        echo "Usuário $username não existe."
                    fi
                    ;;
                *)
                    echo "Tipo de usuário inválido: $usertype"
                    ;;
            esac
        done <<< "$result_user_type"
    else
        echo "Nenhum resultado encontrado."
    fi
}

grant_user_access() {
    local firstname=$1
    local lastname=$2

    firstname=$(echo "$firstname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
    firstname=${firstname//ç/c}

    lastname=$(echo "$lastname" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]')
    lastname=${lastname//ç/c}

    result_user_id=$(mysql --user="$user_db" --password="$password_db" -e "USE spreadsheet; SELECT UserID FROM collaborator_information WHERE name='$firstname $lastname'" 2> /dev/null)
    result_user_id2=$(echo "$result_user_id" | tail -n +2 | tr -d '[:space:]')
    
    result_user_type=$(mysql --user="$user_db" --password="$password_db" -e "USE spreadsheet; SELECT user_type FROM collaborator_information WHERE name='$firstname $lastname'" 2> /dev/null)

    if [ -n "$result_user_type" ]; then
        while IFS= read -r usertype; do
            if [[ $usertype == "user_type" ]]; then
                continue
            fi
            if [ ${#result_user_id2} -gt 7 ]; then
                exit
            fi
            usertype=$(echo "$usertype" | tr -d ' ')

            case "$usertype" in
                "sudo")
                    mysql --user="$user_db" --password="$password_db" -e "CREATE USER '$result_user_id2'@'localhost' IDENTIFIED BY '$result_user_id2';"  2> /dev/null
                    mysql --user="$user_db" --password="$password_db" -e "USE spreadsheet; GRANT ALL PRIVILEGES ON *.* TO '$result_user_id2'@'localhost' WITH GRANT OPTION;; FLUSH PRIVILEGES;"  2> /dev/null
                    echo "Usuário $result_user_id2 tem acesso máximo ao banco de dados."
                    ;;
                "root")
                    mysql --user="$user_db" --password="$password_db" -e "CREATE USER '$result_user_id2'@'localhost' IDENTIFIED BY '$result_user_id2';" 2> /dev/null
                    mysql --user="$user_db" --password="$password_db" -e "USE spreadsheet; GRANT SELECT ON collaborator_information TO '$result_user_id2'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"  2> /dev/null
                    echo "Usuário $result_user_id2 tem permissão somente para SELECT no banco de dados."
                    ;;
                "readandexecute")
                    mysql --user="$user_db" --password="$password_db" -e "CREATE USER '$result_user_id2'@'localhost' IDENTIFIED BY '$result_user_id2';" 2> /dev/null
                    mysql --user="$user_db" --password="$password_db" -e "USE spreadsheet; GRANT SELECT ON collaborator_information TO '$result_user_id2'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2> /dev/null 
                    echo "Usuário $result_user_id2 tem permissão somente para SELECT no banco de dados."
                    ;;
                *)
                    echo "Tipo de usuário inválido: $usertype"
                    ;;
            esac
        done <<< "$result_user_type"
    else
        echo "Nenhum resultado encontrado."
    fi
}

process_spreadsheet() {
    while IFS=',' read -r name lastname office user_type admission_day; do
        if [[ $name == "name"* ]]; then
            continue
        fi
        create_user "$name" "$lastname"
        set_user_access "$name" "$lastname"
	grant_user_access "$name" "$lastname"
    done < planilha.csv
}

# Parâmetros do banco de dados
user_db="lritzke"
password_db="lritzke"

process_spreadsheet

