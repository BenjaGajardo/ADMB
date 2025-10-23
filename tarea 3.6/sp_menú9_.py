# ==========================================
# sp_menu_tipo_reporte.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Adaptado para tipo_reporte
# Propósito: Insertar, listar, eliminar lógicamente y restaurar tipos de reporte
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
def sp_insertar(nombre: str, descripcion: str, created_by: str) -> int:
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [nombre, descripcion, created_by, 0]  # OUT al final
        args = cur.callproc("sp_insertar_tipo_reporte", args)
        cnx.commit()
        nuevo_id = args[3]
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
        cur.callproc("sp_listar_tipo_reporte_activos")
        print("=== TIPOS DE REPORTE ACTIVOS ===")
        for result in cur.stored_results():
            for (id_, nombre, descripcion, created_by, created_at, updated_by, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_:<3} | Nombre:{nombre:<20} | Descripción:{descripcion:<40} | "
                      f"Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
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
        cur.callproc("sp_listar_tipo_reporte_todos")
        print("=== TIPOS DE REPORTE (TODOS) ===")
        for result in cur.stored_results():
            for (id_, nombre, descripcion, created_by, created_at, updated_by, updated_at, deleted) in result.fetchall():
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_:<3} | Nombre:{nombre:<20} | Descripción:{descripcion:<40} | "
                      f"Estado:{estado:<9} | Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_tipo_reporte: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_tipo_reporte", [id_tipo_reporte])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_tipo_reporte} (si estaba activo).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_tipo_reporte: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_tipo_reporte", [id_tipo_reporte])
        cnx.commit()
        print(f"✅ Restaurado ID {id_tipo_reporte} (si estaba eliminado).")
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
        print("\n===== MENÚ TIPO REPORTE (MySQL + SP) =====")
        print("1) Insertar tipo de reporte")
        print("2) Listar tipos de reporte ACTIVOS")
        print("3) Listar tipos de reporte (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID (opcional)")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre: ").strip()
            descripcion = input("Descripción: ").strip()
            created_by = input("Creado por: ").strip()
            sp_insertar(nombre, descripcion, created_by)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_tipo = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_tipo)

        elif opcion == "5":
            try:
                id_tipo = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_tipo)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu()
