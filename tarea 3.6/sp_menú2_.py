# ==========================================
# sp_menu_personas.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Adaptado para tabla personas
# Propósito: Insertar, listar, eliminar lógicamente y restaurar personas
# utilizando procedimientos almacenados y el conector oficial de MySQL.
# ==========================================

import mysql.connector

# ---------- CONFIGURACIÓN DE CONEXIÓN ----------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "seguridad_plazas"
}

# ---------- FUNCIÓN DE CONEXIÓN ----------
def conectar():
    return mysql.connector.connect(**DB_CONFIG)

# ---------- FUNCIONES PRINCIPALES ----------
def sp_insertar(rut: str, nombre: str, correo: str, telefono: str, direccion: str, id_comuna: int, created_by: str) -> int:
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [rut, nombre, correo, telefono, direccion, id_comuna, created_by, 0]  # OUT al final
        args = cur.callproc("sp_insertar_persona", args)
        cnx.commit()
        nuevo_id = args[7]
        print(f"✅ Insertado correctamente. Nuevo ID: {nuevo_id}")
        return nuevo_id
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
        return -1
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_activos():
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_personas_activos")
        print("=== PERSONAS ACTIVAS ===")
        for result in cur.stored_results():
            for (id_, rut, nombre, correo, telefono, direccion, id_comuna, created_by, created_at, updated_by, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_:<3} | RUT:{rut:<12} | Nombre:{nombre:<20} | Correo:{correo:<25} | Tel:{telefono:<12} | Dir:{direccion:<20} | Comuna ID:{id_comuna} | Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_activos:", e)
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
            for (id_, rut, nombre, correo, telefono, direccion, id_comuna, created_by, created_at, updated_by, updated_at, deleted) in result.fetchall():
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_:<3} | RUT:{rut:<12} | Nombre:{nombre:<20} | Correo:{correo:<25} | Tel:{telefono:<12} | Dir:{direccion:<20} | Comuna ID:{id_comuna} | Estado:{estado:<9} | Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_persona: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_persona", [id_persona])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_persona} (si estaba activo).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_persona: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_persona", [id_persona])
        cnx.commit()
        print(f"✅ Restaurado ID {id_persona} (si estaba eliminado).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_restaurar:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# ---------------- MENÚ PRINCIPAL ----------------
def menu():
    while True:
        print("\n===== MENÚ PERSONAS (MySQL + SP) =====")
        print("1) Insertar persona")
        print("2) Listar personas ACTIVAS")
        print("3) Listar personas (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID (opcional)")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            rut = input("RUT: ").strip()
            nombre = input("Nombre: ").strip()
            correo = input("Correo (opcional): ").strip()
            telefono = input("Teléfono (opcional): ").strip()
            direccion = input("Dirección (opcional): ").strip()
            try:
                id_comuna = int(input("ID Comuna (usa una comuna existente): ").strip())
            except ValueError:
                print("❌ ID Comuna inválido.")
                continue
            created_by = input("Creado por: ").strip()
            sp_insertar(rut, nombre, correo, telefono, direccion, id_comuna, created_by)

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
