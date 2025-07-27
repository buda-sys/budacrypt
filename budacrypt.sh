#!/bin/bash

#!/bin/bash
clear
figlet "BUDACRYPT"
echo "Autor: buda-sys"

# seccion 1

FILE_INPUT="$1" # creamos la variable para ingrear el archivo 


if [[ ! -f "$FILE_INPUT" ]]; then # verificamos si el archivo existe 
    echo " [+] Archivo no encontrado"
    exit 1

fi

echo " [+] Procesando $archivo..."

# seccion 2 

# creamos un archivo vacio temporalmente

FILE_ARCH=$(mktemp)

grep -vE '^\s*#' "$FILE_INPUT" | grep -vE '^\s*$' > "$FILE_ARCH"

echo " [+] Comentarios y lineas vacias eliminadas. El archivo fue guardado en $FILE_ARCH"



# seccion 3 


# funcion para generar nombres aleatorios para las variables y funciones

generate_name() {
	
	echo "_$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c6)"
}

# Creamos el archivo ofuscado

OBFUSCADO_ARCH=$(mktemp)

cp "$FILE_ARCH" "$OBFUSCADO_ARCH" # copiamos el archivo limpio a el archivo ofucado

declare -A renames # diccionario de remplazos 

# busfamos las funciones Y variables para que sean remplazadas


while read -r line; do
	if [[ "$line" =~ ^[[:space:]]*def[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
		old_name="${BASH_REMATCH[1]}"
		new_name=$(generate_name)
		renames["$old_name"]="$new_name"
		echo "[+] Funcion: $old_name -> ${renames[$old_name]}"

	fi

	if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[^=]  ]]; then
		old_var="${BASH_REMATCH[1]}"
		if [[ -z "${renames[$old_var]}" ]]; then
			new_name=$(generate_name)
			renames["$old_var"]="$new_name"
			echo "[+] Variable: $old_var -> ${renames[$old_var]}"
		fi

	fi

done < "$FILE_ARCH"


# remplazamos en el archivo todos los nombres detectados


for old in "${!renames[@]}"; do
	new="${renames[$old]}"
	sed -i "s/\b$old\b/$new/g" "$OBFUSCADO_ARCH"
done


# seccion 4


# generamos el archivo final que sera ofuscado a base64

read -p "[+] Ingrese el nombre  a guardar el archivo obfuscado -->  " ARCHIVO_FINAL



# codificamos el archivo a base64

CODIFICADO=$(base64 "$OBFUSCADO_ARCH" | tr -d '\n')

# lo guardamos en un exec 

echo "import base64" > "$ARCHIVO_FINAL"
echo "exec(compile(base64.b64decode('$CODIFICADO'), '<strings>', 'exec'))" >> "$ARCHIVO_FINAL"

rm "$FILE_ARCH" "$OBFUSCADO_ARCH"

echo "[+] El Codigo fue ofuscado correctamente "
echo "[+] Guardado en $ARCHIVO_FINAL"
