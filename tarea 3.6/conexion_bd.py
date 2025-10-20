# ==========================================
# Ejemplo básico: Mostrar información de una base de datos MySQL
# Autor: Dany
# ==========================================

import mysql.connector

# Configuración de la conexión
conexion = mysql.connector.connect(
    host="localhost",          # Servidor (puede ser "127.0.0.1")
    user="root",               # Usuario de MySQL
    password="1234",  # Cambia por tu contraseña real
    database="empresa"         # Nombre de la base de datos
)

# Crear un cursor para ejecutar consultas
cursor = conexion.cursor()

# Consulta básica
consulta = "SELECT id, nombre, cargo, sueldo FROM empleados"

# Ejecutar la consulta
cursor.execute(consulta)

# Obtener los resultados
empleados = cursor.fetchall()

# Mostrar la información en consola
print("=== LISTADO DE EMPLEADOS ===")
for emp in empleados:
    print(f"ID: {emp[0]} | Nombre: {emp[1]} | Cargo: {emp[2]} | Sueldo: ${emp[3]:,.0f}")

# Cerrar conexión
cursor.close()
conexion.close()

print("\nConexión cerrada correctamente.")
