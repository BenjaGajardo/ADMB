# ==========================================
# sp_menu_comunas.py (corregido)
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Dany
# Propósito: Insertar, listar, eliminar lógicamente y restaurar comunas
# utilizando procedimientos almacenados y el conector oficial de MySQL.
# ==========================================

import mysql.connector

# ---------- CONFIGURACIÓN DE CONEXIÓN ----------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "seguridad_plaza"
}

# ---------- FUNCIÓN DE CONEXIÓN ----------
def conectar():
    """Crea y devuelve una conexión a MySQL."""
    return mysql.connector.connect(**DB_CONFIG)

# ---------- FUNCIONES PRINCIPALES ----------
def sp_insertar(nombre: str) -> int:
    """Inserta una nueva comuna llamando al procedimiento almacenado sp_insertar_comuna."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [nombre, 0]  # IN p_nombre, OUT p_nuevo_id
        args = cur.callproc("sp_insertar_comuna", args)
        cnx.commit()
        nuevo_id = args[1]
        print(f"✅ Insertado correctamente. Nuevo ID: {nuevo_id}")
        return nuevo_id
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar:", e)
        if cnx and cnx.is_connected():
            try:
                cnx.rollback()
            except:
                pass
        return -1
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_activos():
    """Llama al procedimiento almacenado sp_listar_comunas_activas()."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_comunas_activas")
        print("=== COMUNAS ACTIVAS ===")
        for result in cur.stored_results():
            for (id_comuna, nombre, created_at, updated_at) in result.fetchall():
                ua = updated_at if updated_at else "-"
                print(f"ID:{id_comuna:<3} | Nombre:{nombre:<20} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_todos():
    """Llama al procedimiento almacenado sp_listar_comunas_todos()."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_comunas_todos")
        print("=== COMUNAS (TODOS) ===")
        for result in cur.stored_results():
            for (id_comuna, nombre, eliminado, created_at, updated_at, deleted_at) in result.fetchall():
                estado = "ACTIVO" if eliminado == 0 else "ELIMINADO"
                ua = updated_at if updated_at else "-"
                da = deleted_at if deleted_at else "-"
                print(f"ID:{id_comuna:<3} | Nombre:{nombre:<20} | {estado:<9} | "
                      f"Creado:{created_at} | Actualizado:{ua} | Eliminado:{da}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_comuna: int):
    """Marca una comuna como eliminada lógicamente llamando a sp_borrado_logico_comuna."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_comuna", [id_comuna])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_comuna} (si estaba activo).")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try:
                cnx.rollback()
            except:
                pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_comuna: int):
    """Restaura una comuna eliminada lógicamente llamando a sp_restaurar_comuna."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_comuna", [id_comuna])
        cnx.commit()
        print(f"✅ Restaurado ID {id_comuna} (si estaba eliminado).")
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
    """Muestra un menú interactivo para ejecutar las operaciones CRUD."""
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
            nombre = input("Nombre de la comuna: ").strip()
            if not nombre:
                print("❌ El nombre no puede estar vacío.")
                continue
            sp_insertar(nombre)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_c = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_c)

        elif opcion == "5":
            try:
                id_c = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_c)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

# Punto de entrada
if __name__ == "__main__":
    menu()
