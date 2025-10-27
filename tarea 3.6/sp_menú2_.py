# ==========================================
# sp_menu_personas.py
# CRUD personas usando procedimientos almacenados en MySQL
# ==========================================

import mysql.connector

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "seguridad_plazas"
}

def conectar():
    return mysql.connector.connect(**DB_CONFIG)

def sp_insertar(rut, nombre, correo, telefono, direccion, id_comuna):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [rut, nombre, correo, telefono, direccion, id_comuna, 0]  # OUT al final
        args = cur.callproc("sp_insertar_persona", args)
        cnx.commit()
        nuevo_id = args[6]
        print(f"✅ Persona insertada correctamente. Nuevo ID: {nuevo_id}")
        return nuevo_id
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar:", e)
        return -1
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_activos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_personas_activas")
        print("=== PERSONAS ACTIVAS ===")
        for result in cur.stored_results():
            for fila in result.fetchall():
                id_, rut, nombre, correo, telefono, direccion, id_comuna, created_at, updated_at = fila
                ua = updated_at if updated_at else "-"
                print(f"ID:{id_:<3} | RUT:{rut:<12} | Nombre:{nombre:<20} | Correo:{correo:<20} | Tel:{telefono} | Comuna:{id_comuna} | Creado:{created_at} | Actualizado:{ua}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_todos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_personas_todos")
        print("=== PERSONAS (TODOS) ===")
        for result in cur.stored_results():
            for fila in result.fetchall():
                id_, rut, nombre, correo, telefono, direccion, id_comuna, eliminado, created_at, updated_at, deleted_at = fila
                estado = "ACTIVO" if eliminado == 0 else "ELIMINADO"
                ua = updated_at if updated_at else "-"
                da = deleted_at if deleted_at else "-"
                print(f"ID:{id_:<3} | RUT:{rut:<12} | Nombre:{nombre:<20} | Estado:{estado:<9} | Creado:{created_at} | Actualizado:{ua} | Eliminado:{da}")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_persona):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_persona", [id_persona])
        cnx.commit()
        print(f"✅ Persona borrada lógicamente ID {id_persona}.")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_persona):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_persona", [id_persona])
        cnx.commit()
        print(f"✅ Persona restaurada ID {id_persona}.")
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def menu():
    while True:
        print("\n===== MENÚ PERSONAS (MySQL + SP) =====")
        print("1) Insertar persona")
        print("2) Listar personas ACTIVAS")
        print("3) Listar personas (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            rut = input("RUT: ").strip()
            nombre = input("Nombre: ").strip()
            correo = input("Correo: ").strip()
            telefono = input("Teléfono: ").strip()
            direccion = input("Dirección: ").strip()
            try:
                id_comuna = int(input("ID Comuna (opcional): ").strip() or 0)
            except ValueError:
                id_comuna = 0
            sp_insertar(rut, nombre, correo, telefono, direccion, id_comuna)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_p = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_p)

        elif opcion == "5":
            try:
                id_p = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_p)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu()
