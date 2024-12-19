# Функция для регистрации инициализационного скрипта cron
register_cron_initd() {
    # Проверка наличия пакета cron
    if opkg list-installed | grep -q cron; then
        return
    fi

    # Определение переменных
    local initd_file="${initd_dir}/S05crond"
    local s05crond_filename="${current_datetime}_S05crond"
    local required_script_version="0.4"

    # Проверка наличия файла S05crond
    if [ -e "${initd_file}" ]; then
        # Получение текущей версии скрипта
        local script_version=$(grep 'version=' "${initd_file}" | grep -o '[0-9.]\+')

        # Проверка версии скрипта
        if [ "${script_version}" != "${required_script_version}" ]; then
            # Определение пути для резервной копии
            local backup_path="${backups_dir}/${s05crond_filename}"

            # Перемещение файла в каталог резервных копий с новым именем
            mv "${initd_file}" "${backup_path}"
            echo -e "  Ваш файл «${green}S05crond${reset}» перемещен в каталог резервных копий «${yellow}${backup_path}${reset}»"
        fi
    fi

    # Содержимое скрипта
    local script_content='#!/bin/sh
### Начало информации о службе
# Краткое описание: Запуск / Остановка Cron
# version="0.4"  # Версия скрипта
### Конец информации о службе

green="\033[32m"
red="\033[31m"
yellow="\033[33m"
reset="\033[0m" 

cron_initd="/opt/sbin/crond"

# Функция для проверки статуса cron
cron_status() {
    if ps | grep -v grep | grep -q "$cron_initd"; then
        return 0 # Процесс существует и работает
    else
        return 1 # Процесс не существует
    fi
}

# Функция для запуска cron
start() {
    if cron_status; then
        echo -e "  Cron ${yellow}уже запущен${reset}"
    else
        $cron_initd -L /dev/null
        echo -e "  Cron ${green}запущен${reset}"
    fi
}

# Функция для остановки cron
stop() {
    if cron_status; then
        killall -9 "crond"
        echo -e "  Cron ${yellow}остановлен${reset}"
    else
        echo -e "  Cron ${red}не запущен${reset}"
    fi
}

# Функция для перезапуска cron
restart() {
    stop > /dev/null 2>&1
    start > /dev/null 2>&1
    echo -e "  Cron ${green}перезапущен${reset}"
}

# Обработка аргументов командной строки
case "$1" in
    start)
        start;;
    stop)
        stop;;
    restart)
        restart;;
    status)
        if cron_status; then
            echo -e "  Cron ${green}запущен${reset}"
        else
            echo -e "  Cron ${red}не запущен${reset}"
        fi;;
    *)
        echo -e "  Команды: ${green}start${reset} | ${red}stop${reset} | ${yellow}restart${reset} | status";;
esac

exit 0'
    
    # Создание или замена файла, если версия скрипта не соответствует требуемой версии 
    if [ "${script_version}" != "${required_script_version}" ]; then 
        echo -e "${script_content}" > "${initd_file}" 
        chmod +x "${initd_file}" 
    fi 
}