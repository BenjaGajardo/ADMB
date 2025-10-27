# ==========================================
# sp_menu_comunas.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Adaptado para comunas
# Propósito: Insertar, listar, eliminar lógicamente y restaurar comunas
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
def sp_insertar(nombre: str, created_by: str) -> int:
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [nombre, created_by, 0]  # OUT al final
        args = cur.callproc("sp_insertar_comuna", args)
        cnx.commit()
        nuevo_id = args[2]
        print(f"✅ Comuna insertada correctamente. Nuevo ID: {nuevo_id}")
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
        cur.callproc("sp_listar_comunas_activas")
        print("=== COMUNAS ACTIVAS ===")
        for result in cur.stored_results():
            filas = result.fetchall()
            if not filas:
                print("❌ No hay comunas activas disponibles.")
            for fila in filas:
                id_, nombre, created_by, created_at, updated_by, updated_at = fila
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_:<3} | Nombre:{nombre:<25} | Creado por:{created_by} | "
                      f"Creado:{created_at} | Actualizado:{ua}")
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
        cur.callproc("sp_listar_comunas_todos")
        print("=== COMUNAS (TODOS) ===")
        for result in cur.stored_results():
            filas = result.fetchall()
            if not filas:
                print("❌ No hay comunas disponibles.")
            for fila in filas:
                id_, nombre, created_by, created_at, updated_by, updated_at, deleted = fila
                estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_:<3} | Nombre:{nombre:<25} | Estado:{estado:<9} | "
                      f"Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_comuna: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_comuna", [id_comuna])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_comuna} (si estaba activa).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_comuna: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_comuna", [id_comuna])
        cnx.commit()
        print(f"✅ Restaurada comuna ID {id_comuna} (si estaba eliminada).")
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
        print("\n===== MENÚ COMUNAS (MySQL + SP) =====")
        print("1) Insertar comuna")
        print("2) Listar comunas ACTIVAS")
        print("3) Listar comunas (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID (opcional)")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre: ").strip()
            created_by = input("Creado por: ").strip()
            sp_insertar(nombre, created_by)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_com = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_com)

        elif opcion == "5":
            try:
                id_com = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_com)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu()
