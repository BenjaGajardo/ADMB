# ==========================================
# sp_menu_reportes.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Adaptado para reportes
# Propósito: Insertar, listar, eliminar lógicamente y restaurar reportes
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
def sp_insertar(id_tipo_reporte: int, descripcion: str, fecha: str, hora: str,
                id_usuario: int, id_plaza: int, created_by: str) -> int:
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by, 0]  # OUT al final
        args = cur.callproc("sp_insertar_reporte", args)
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
        cur.callproc("sp_listar_reportes_activos")
        print("=== REPORTES ACTIVOS ===")
        for result in cur.stored_results():
            for (id_reporte, id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza,
                 created_by, created_at, updated_by, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_reporte:<3} | Tipo:{id_tipo_reporte:<3} | Descripción:{descripcion:<30} | "
                      f"Fecha:{fecha} | Hora:{hora} | Usuario:{id_usuario} | Plaza:{id_plaza} | "
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
        cur.callproc("sp_listar_reportes_todos")
        print("=== REPORTES (TODOS) ===")
        for result in cur.stored_results():
            for (id_reporte, id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza,
                 created_by, created_at, updated_by, updated_at, deleted) in result.fetchall():
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_reporte:<3} | Tipo:{id_tipo_reporte:<3} | Descripción:{descripcion:<30} | "
                      f"Estado:{estado:<9} | Fecha:{fecha} | Hora:{hora} | Usuario:{id_usuario} | Plaza:{id_plaza} | "
                      f"Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_reporte: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_reporte", [id_reporte])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_reporte} (si estaba activo).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_reporte: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_reporte", [id_reporte])
        cnx.commit()
        print(f"✅ Restaurado ID {id_reporte} (si estaba eliminado).")
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
        print("\n===== MENÚ REPORTES (MySQL + SP) =====")
        print("1) Insertar reporte")
        print("2) Listar reportes ACTIVOS")
        print("3) Listar reportes (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            try:
                id_tipo_reporte = int(input("ID Tipo de Reporte: ").strip())
                descripcion = input("Descripción: ").strip()
                fecha = input("Fecha (YYYY-MM-DD): ").strip()
                hora = input("Hora (HH:MM:SS): ").strip()
                id_usuario = int(input("ID Usuario: ").strip())
                id_plaza = int(input("ID Plaza: ").strip())
                created_by = input("Creado por: ").strip()
                sp_insertar(id_tipo_reporte, descripcion, fecha, hora, id_usuario, id_plaza, created_by)
            except ValueError:
                print("❌ Error: valores inválidos.")

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_reporte = int(input("ID a eliminar lógicamente: ").strip())
                sp_borrado_logico(id_reporte)
            except ValueError:
                print("❌ ID inválido.")

        elif opcion == "5":
            try:
                id_reporte = int(input("ID a restaurar: ").strip())
                sp_restaurar(id_reporte)
            except ValueError:
                print("❌ ID inválido.")

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

if __name__ == "__main__":
    menu()
