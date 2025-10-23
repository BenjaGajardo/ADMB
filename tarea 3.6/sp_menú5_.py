# ==========================================
# sp_menu_camaras.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Adaptado para camaras
# Propósito: Insertar, listar, eliminar lógicamente y restaurar cámaras
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
def sp_insertar(ubicacion: str, id_estado_camara: int, id_plaza: int, created_by: str) -> int:
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [ubicacion, id_estado_camara, id_plaza, created_by, 0]  # OUT al final
        args = cur.callproc("sp_insertar_camara", args)
        cnx.commit()
        nuevo_id = args[4]
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
        cur.callproc("sp_listar_camaras_activas")
        print("=== CÁMARAS ACTIVAS ===")
        for result in cur.stored_results():
            for (id_, ubicacion, id_estado, id_plaza, created_by, created_at, updated_by, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                ub = updated_by if updated_by is not None else "-"
                print(f"ID:{id_:<3} | Ubicación:{ubicacion:<20} | Estado ID:{id_estado:<3} | Plaza ID:{id_plaza:<3} | "
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
        cur.callproc("sp_listar_camaras_todas")
        print("=== CÁMARAS (TODAS) ===")
        for result in cur.stored_results():
            for (id_, ubicacion, id_estado, id_plaza, created_by, created_at, updated_by, updated_at, deleted) in result.fetchall():
                estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
                ua = updated_at if updated_at is not None else "-"
                ub = updated_by if updated_by is not None else "-"
                print(f"ID:{id_:<3} | Ubicación:{ubicacion:<20} | Estado ID:{id_estado:<3} | Plaza ID:{id_plaza:<3} | "
                      f"Estado:{estado:<9} | Creado por:{created_by} | Creado:{created_at} | Actualizado por:{ub} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_camara: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_camara", [id_camara])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_camara} (si estaba activa).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_camara: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_camara", [id_camara])
        cnx.commit()
        print(f"✅ Restaurado ID {id_camara} (si estaba eliminada).")
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
        print("\n===== MENÚ CÁMARAS (MySQL + SP) =====")
        print("1) Insertar cámara")
        print("2) Listar cámaras activas")
        print("3) Listar todas las cámaras")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            ubicacion = input("Ubicación: ").strip()
            try:
                id_estado = int(input("ID estado cámara: ").strip())
                id_plaza = int(input("ID plaza: ").strip())
            except ValueError:
                print("❌ IDs inválidos.")
                continue
            created_by = input("Creado por: ").strip()
            sp_insertar(ubicacion, id_estado, id_plaza, created_by)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_cam = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_cam)

        elif opcion == "5":
            try:
                id_cam = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_cam)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu()

