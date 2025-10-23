# ==========================================
# sp_menu_estado_camara.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Adaptado para estado_camara
# Propósito: Insertar, listar, eliminar lógicamente y restaurar estados de cámaras
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
        args = cur.callproc("sp_insertar_estado_camara", args)
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
        cur.callproc("sp_listar_estado_camara_activos")
        print("=== ESTADOS DE CÁMARAS ACTIVOS ===")
        for result in cur.stored_results():
            for (id_, nombre, descripcion, created_by, created_at, updated_by, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                desc = descripcion if descripcion is not None else "-"
                ub = updated_by if updated_by is not None else "-"
                print(f"ID:{id_:<3} | Nombre:{nombre:<15} | Descripción:{desc:<30} | "
                      f"Creado por:{created_by} | Creado:{created_at} | Actualizado por:{ub} | Actualizado:{ua}")
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
        cur.callproc("sp_listar_estado_camara_todos")
        print("=== ESTADOS DE CÁMARAS (TODOS) ===")
        for result in cur.stored_results():
            for (id_, nombre, descripcion, created_by, created_at, updated_by, updated_at, deleted) in result.fetchall():
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = updated_at if updated_at is not None else "-"
                desc = descripcion if descripcion is not None else "-"
                ub = updated_by if updated_by is not None else "-"
                print(f"ID:{id_:<3} | Nombre:{nombre:<15} | Descripción:{desc:<30} | "
                      f"Estado:{estado:<9} | Creado por:{created_by} | Creado:{created_at} | Actualizado por:{ub} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_estado: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_estado_camara", [id_estado])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_estado} (si estaba activo).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_estado: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_estado_camara", [id_estado])
        cnx.commit()
        print(f"✅ Restaurado ID {id_estado} (si estaba eliminado).")
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
        print("\n===== MENÚ ESTADOS DE CÁMARAS (MySQL + SP) =====")
        print("1) Insertar estado de cámara")
        print("2) Listar estados activos")
        print("3) Listar todos los estados")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre: ").strip()
            descripcion = input("Descripción (opcional): ").strip()
            created_by = input("Creado por: ").strip()
            sp_insertar(nombre, descripcion, created_by)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_estado = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_estado)

        elif opcion == "5":
            try:
                id_estado = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_estado)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu()

