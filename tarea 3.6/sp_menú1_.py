# ==========================================
# sp_menu_usuarios.py
# CRUD básico con Procedimientos Almacenados (MySQL) desde Python
# Autor: Dany
# Propósito: Permitir insertar, listar, eliminar lógicamente y restaurar usuarios
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
def sp_insertar(id_persona: int, contrasena: str, id_tipo_usuario: int) -> int:
    """Inserta un nuevo usuario llamando al procedimiento almacenado sp_insertar_usuario."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [id_persona, contrasena, id_tipo_usuario, 0]
        args = cur.callproc("sp_insertar_usuario", args)
        cnx.commit()
        nuevo_id = args[3]
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
    """Llama al procedimiento almacenado sp_listar_usuarios_activos()."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_usuarios_activos")
        print("=== USUARIOS ACTIVOS ===")
        for result in cur.stored_results():
            for (id_usuario, id_persona, contrasena, id_tipo_usuario, created_at, updated_at) in result.fetchall():
                ua = updated_at if updated_at is not None else "-"
                print(f"ID:{id_usuario:<3} | Persona:{id_persona:<3} | "
                      f"Contraseña:{contrasena:<12} | Tipo Usuario:{id_tipo_usuario:<3} | "
                      f"Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_todos():
    """Llama al procedimiento almacenado sp_listar_usuarios_todos()."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_usuarios_todos")
        print("=== USUARIOS (TODOS) ===")
        for result in cur.stored_results():
            for (id_usuario, id_persona, contrasena, id_tipo_usuario, eliminado, created_at, updated_at, deleted_at) in result.fetchall():
                estado = "ACTIVO" if eliminado == 0 else "ELIMINADO"
                ua = updated_at if updated_at is not None else "-"
                da = deleted_at if deleted_at is not None else "-"
                print(f"ID:{id_usuario:<3} | Persona:{id_persona:<3} | "
                      f"Contraseña:{contrasena:<12} | Tipo:{id_tipo_usuario:<3} | "
                      f"{estado:<9} | Creado:{created_at} | Actualizado:{ua} | Eliminado:{da}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_usuario: int):
    """Marca un usuario como eliminado lógicamente llamando a sp_borrado_logico_usuario."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_usuario", [id_usuario])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_usuario} (si estaba activo).")
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

def sp_restaurar(id_usuario: int):
    """Restaura un usuario eliminado lógicamente llamando a sp_restaurar_usuario."""
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_usuario", [id_usuario])
        cnx.commit()
        print(f"✅ Restaurado ID {id_usuario} (si estaba eliminado).")
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
        print("\n===== MENÚ USUARIOS (MySQL + SP) =====")
        print("1) Insertar usuario")
        print("2) Listar usuarios ACTIVOS")
        print("3) Listar usuarios (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID (opcional)")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            try:
                id_persona = int(input("ID Persona: ").strip())
                contrasena = input("Contraseña: ").strip()
                id_tipo_usuario = int(input("ID Tipo Usuario: ").strip())
            except ValueError:
                print("❌ Datos inválidos.")
                continue
            sp_insertar(id_persona, contrasena, id_tipo_usuario)

        elif opcion == "2":
            sp_listar_activos()

        elif opcion == "3":
            sp_listar_todos()

        elif opcion == "4":
            try:
                id_u = int(input("ID a eliminar lógicamente: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_borrado_logico(id_u)

        elif opcion == "5":
            try:
                id_u = int(input("ID a restaurar: ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            sp_restaurar(id_u)

        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break

        else:
            print("❌ Opción no válida. Intenta nuevamente.")

# Punto de entrada
if __name__ == "__main__":
    menu()
