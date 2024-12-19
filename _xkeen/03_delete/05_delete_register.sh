delete_register_xray() {
    # Удаляем соответствующие записи из файла статуса opkg
    sed -i -e '/Package: xray/,/Installed-Time:/d' "/opt/lib/opkg/status"
    
    # Удаляем файлы регистрации, если они существуют
    if [ -f "$register_dir/xray.control" ] || [ -f "$register_dir/xray.list" ]; then
        rm -f "$register_dir/xray.control" "$register_dir/xray.list"
    fi
}

# Удаление регистрации xkeen
delete_register_xkeen() {
    # Удаляем соответствующие записи из файла статуса opkg
    sed -i -e '/Package: xkeen/,/Installed-Time:/d' "/opt/lib/opkg/status"
    
    # Удаляем файлы регистрации, если они существуют
    if [ -f "$register_dir/xkeen.control" ] || [ -f "$register_dir/xkeen.list" ]; then
        rm -f "$register_dir/xkeen.control" "$register_dir/xkeen.list"
    fi
}

fixed_register_packages() {
	awk 'BEGIN {RS=""; ORS="\n\n"} {gsub(/\n\n+/,"\n\n")}1' "$status_file" > tmp_status_file && mv tmp_status_file "$status_file"
}
