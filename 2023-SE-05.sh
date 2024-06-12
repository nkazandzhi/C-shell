#!/bin/bash
#НЕ Е ТЕСТВАНА!!
# Настройка на прага на паметта (в KB) и интервала между проверките (в секунди)
THRESHOLD=65536
INTERVAL=1

# Временни файлове за съхранение на данните
command_file=$(mktemp)
high_memory_file=$(mktemp)
touch $command_file
touch $high_memory_file

counter=0

# Основен цикъл за проверка на процесите
while :; do
    all_below_threshold=true

    # Нулиране на временния файл за командите
    > $command_file

    # Събиране на информация за текущите процеси и запис във временния файл
    ps -eo pid,comm,rss --no-headers | while read -r pid comm rss; do
        # Ако командата вече съществува във файла, актуализирай заетата памет
        if grep -q "^$comm " $command_file; then
            current_rss=$(grep "^$comm " $command_file | cut -d ' ' -f 2)
            new_rss=$((current_rss + rss))
            sed -i "s/^$comm .*/$comm $new_rss/" $command_file
        else
            echo "$comm $rss" >> $command_file
        fi
    done

    # Проверка дали някоя команда надвишава прага
    while read -r comm memory; do
        if [ "$memory" -gt $THRESHOLD ]; then
            echo "$comm" >> $high_memory_file
            all_below_threshold=false
        fi
    done < $command_file

    counter=$(( counter + 1 ))

    # Ако няма команди над прага, прекъсваме цикъла
    if $all_below_threshold; then
        break
    fi

    sleep $INTERVAL
done

# Проверка и извеждане на резултатите
if [ $counter -eq 0 ]; then
    echo "No processes exceeding $THRESHOLD KB found."
else
    half_counter=$(( counter / 2 ))

    # Изчисляване на броя на високопаметните проверки за всяка команда
    sort $high_memory_file | uniq -c | while read -r count comm; do
        if [ $count -ge $half_counter ]; then
            echo "Command '$comm' exceeded $THRESHOLD KB in $count out of $counter checks."
        fi
    done
fi

# Почистване на временните файлове
rm -f $command_file $high_memory_file
