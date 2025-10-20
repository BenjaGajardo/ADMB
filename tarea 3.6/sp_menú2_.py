# ==========================================
# sp_menu_personas.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Dany
# Propósito: Permitir insertar, listar, eliminar lógicamente y restaurar personas
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
def sp_insertar(rut: str, nombre: str, correo: str, telefono: str, direccion: str, id_comuna: int) -> int:
    """Inserta una nueva persona llamando al procedimiento almacenado sp_insertar_persona."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [rut, nombre, correo, telefono, direccion, id_comuna, 0]
        args = cur.callproc("sp_insertar_persona", args)
        cnx.commit()
        nuevo_id = args[6]
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
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_activos():
    """Llama al procedimiento almacenado sp_listar_personas_activas()."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_personas_activas")
        print("=== PERSONAS ACTIVAS ===")
        for result in cur.stored_results():
            for (id_persona, rut, nombre, correo, telefono, direccion, id_comuna, created_at, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_persona:<3} | RUT:{rut:<12} | Nombre:{nombre:<15} | "
                      f"Correo:{correo:<20} | Tel:{telefono:<12} | Dir:{direccion:<20} | "
                      f"Comuna:{id_comuna} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_todos():
    """Llama al procedimiento almacenado sp_listar_personas_todos()."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_personas_todos")
        print("=== PERSONAS (TODOS) ===")
        for result in cur.stored_results():
            for (id_persona, rut, nombre, correo, telefono, direccion, id_comuna, eliminado, created_at, updated_at, deleted_at) in result.fetchall():
                estado = "ACTIVO" if eliminado == 0 else "ELIMINADO"
                ua = updated_at if updated_at is not None else "-"
                da = deleted_at if deleted_at is not None else "-"
                print(f"ID:{id_persona:<3} | RUT:{rut:<12} | Nombre:{nombre:<15} | "
                      f"Correo:{correo:<20} | Tel:{telefono:<12} | Dir:{direccion:<20} | "
                      f"Comuna:{id_comuna} | {estado:<9} | Creado:{created_at} | Actualizado:{ua} | Eliminado:{da}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_persona: int):
    """Marca una persona como eliminada lógicamente llamando a sp_borrado_logico_persona."""
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
            try:
                cnx.rollback()
            except:
                pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_persona: int):
    """Restaura una persona eliminada lógicamente llamando a sp_restaurar_persona."""
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
    """Muestra un menú interactivo para ejecutar las operaciones CRUD."""
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
            correo = input("Correo: ").strip()
            telefono = input("Teléfono: ").strip()
            direccion = input("Dirección: ").strip()
            try:
                id_comuna = int(input("ID Comuna: ").strip())
            except ValueError:
                print("❌ ID Comuna inválido.")
                continue
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

# Punto de entrada
if __name__ == "__main__":
    menu()
