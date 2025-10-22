import mysql.connector

# Conexión a la base de datos
def conectar():
    return mysql.connector.connect(
        host="localhost",
        user="root",       # cambia si usas otro usuario
        password="1234",       # agrega tu contraseña si la tienes
        database="seguridad_plaza"
    )

# Opción 1: Listar plazas activas
def listar_plazas_activas():
    db = conectar()
    cursor = db.cursor()
    cursor.callproc("sp_listar_plazas_activas")

    print("\n--- LISTA DE PLAZAS ACTIVAS ---")
    for resultado in cursor.stored_results():
        for fila in resultado.fetchall():
            print(f"ID: {fila[0]} | Nombre: {fila[1]} | Dirección: {fila[2]} | Comuna ID: {fila[3]} | Creado: {fila[4]} | Actualizado: {fila[5]}")
    db.close()

# Opción 2: Listar todas las plazas (incluye eliminadas)
def listar_plazas_todas():
    db = conectar()
    cursor = db.cursor()
    cursor.callproc("sp_listar_plazas_todos")

    print("\n--- LISTA DE TODAS LAS PLAZAS ---")
    for resultado in cursor.stored_results():
        for fila in resultado.fetchall():
            print(f"ID: {fila[0]} | Nombre: {fila[1]} | Dirección: {fila[2]} | Comuna ID: {fila[3]} | Eliminado: {fila[4]} | Creado: {fila[5]} | Actualizado: {fila[6]} | Borrado: {fila[7]}")
    db.close()

# Opción 3: Insertar una nueva plaza
def insertar_plaza():
    db = conectar()
    cursor = db.cursor()

    nombre = input("Ingrese nombre de la plaza: ")
    direccion = input("Ingrese dirección: ")
    id_comuna = input("Ingrese ID de la comuna: ")

    cursor.callproc("sp_insertar_plaza", (nombre, direccion, id_comuna, 0))
    db.commit()
    print("\n✅ Plaza agregada exitosamente.")
    db.close()

# Opción 4: Borrado lógico
def borrar_plaza():
    db = conectar()
    cursor = db.cursor()
    p_id = input("Ingrese el ID de la plaza a eliminar: ")

    cursor.callproc("sp_borrado_logico_plaza", (p_id,))
    db.commit()
    print("\n🗑️ Plaza eliminada lógicamente (marcada como eliminada).")
    db.close()

# Opción 5: Restaurar plaza eliminada
def restaurar_plaza():
    db = conectar()
    cursor = db.cursor()
    p_id = input("Ingrese el ID de la plaza a restaurar: ")

    cursor.callproc("sp_restaurar_plaza", (p_id,))
    db.commit()
    print("\n♻️ Plaza restaurada exitosamente.")
    db.close()

# Menú principal
def menu():
    while True:
        print("\n========= MENÚ PLAZAS =========")
        print("1. Listar plazas activas")
        print("2. Listar todas las plazas")
        print("3. Insertar nueva plaza")
        print("4. Eliminar plaza (borrado lógico)")
        print("5. Restaurar plaza")
        print("6. Salir")

        opcion = input("Seleccione una opción: ")

        if opcion == "1":
            listar_plazas_activas()
        elif opcion == "2":
            listar_plazas_todas()
        elif opcion == "3":
            insertar_plaza()
        elif opcion == "4":
            borrar_plaza()
        elif opcion == "5":
            restaurar_plaza()
        elif opcion == "6":
            print("Saliendo del menú...")
            break
        else:
            print("Opción no válida. Intente nuevamente.")

# Ejecutar menú
if __name__ == "__main__":
    menu()
