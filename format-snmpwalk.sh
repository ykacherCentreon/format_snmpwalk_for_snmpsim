#!/bin/bash

format_snmpwalk(){
        file="$1"
        file_name=$(basename -- "$file")

        result_file="$file.formated"

        number_of_lines_in_file=$(wc -l < $file)
        current_line=1

        line_starting_pattern=".1."
        new_line=""

        echo -e "Result file created : $result_file"
        touch $result_file

        while [ $current_line -le $number_of_lines_in_file ]
        do
        progress=$(((100 * $current_line) / $number_of_lines_in_file))
        next_line=$(( current_line + 1))
        line_content=$(awk -v line="$current_line" 'NR==line{print; exit}' $file)
        next_line_content=$(awk -v line="$next_line" 'NR==line{print; exit}' $file)
        first_chars=${line_content:0:3}
        next_first_chars=${next_line_content:0:3}

        if [[ $first_chars == $line_starting_pattern ]]
        then
                new_line=$line_content
        else
                new_line+=" $line_content"
        fi

        if [[ $next_first_chars == $line_starting_pattern || $current_line == $number_of_lines_in_file ]]
        then
                echo $new_line >> $result_file # Debut d'une nouvelle ligne ou fin du fichier, donc on ecrit la precedente
        fi

        echo -ne "Formating from $file ($progress%) \r"

        ((current_line++))
done


sed -i -e '$a\' $result_file
sed -i '/^[0-9ABCDEF]/d' $result_file
sed -i 's/ instances\| failures\| notifications//g' $result_file
echo -e "\nDone !"
}

help(){
        echo -e "\nUsage : format-snmpwalk.sh path_to_snmpwalk_file\n"
}


if [ -r "$1" ]; then
    format_snmpwalk $1
else
   echo -e ""
   echo  '/!\ File missing from arguments or file does not exist or is not readable /!\'
   help
fi