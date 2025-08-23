#!/bin/bash

# Получаем текущий активный экран
ACTIVE_OUTPUT=$(niri msg focused-output | awk '/Output/{print $NF}' | sed 's/[(")]//g')

# Получаем информацию о рабочих столах
workspaces_info=$(niri msg workspaces)

# Извлекаем только секцию для активного вывода
output_section=$(echo "$workspaces_info" | sed -n "/Output \"$ACTIVE_OUTPUT\":/,/Output/p" | head -n -1)

# Парсим рабочие столы
text=" |  ${ACTIVE_OUTPUT} "
while IFS= read -r line; do
    if [[ $line =~ \*[[:space:]]+([0-9]+) ]]; then
        text+="● "  # Активный рабочий стол
    elif [[ $line =~ [[:space:]]+([0-9]+) ]]; then
        text+="○ "  # Неактивный рабочий стол
    fi
done <<< "$output_section"

# Убираем последний пробел
text=${text% }

# Формируем JSON
if [ -z "$text" ]; then
    text="○ ○ ○"  # Заглушка, если не найдены рабочие столы
fi

echo "{\"text\": \"$text\", \"tooltip\": \"Активный экран: $ACTIVE_OUTPUT\", \"class\": \"workspaces\"}"
