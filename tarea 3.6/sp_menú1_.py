# ==========================================
# sp_menu_usuarios.py
# CRUD usuarios usando procedimientos almacenados en MySQL
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
def sp_insertar(id_persona: int, contrasena: str, id_tipo_usuario: int, created_by: str) -> int:
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [id_persona, contrasena, id_tipo_usuario, created_by, 0]  # OUT al final
        args = cur.callproc("sp_insertar_usuario", args)
        cnx.commit()
        nuevo_id = args[4]
        print(f"✅ Usuario insertado correctamente. Nuevo ID: {nuevo_id}")
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
        cur.callproc("sp_listar_usuarios_activos")
        print("=== USUARIOS ACTIVOS ===")
        for result in cur.stored_results():
            for fila in result.fetchall():
                id_, id_persona, contrasena, id_tipo_usuario, created_by, created_at, updated_by, updated_at = fila
                ua = updated_at if updated_at else "-"
                print(f"ID:{id_:<3} | Persona:{id_persona} | Contraseña:{contrasena:<15} | "
                      f"Tipo Usuario:{id_tipo_usuario} | Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
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
        cur.callproc("sp_listar_usuarios_todos")
        print("=== USUARIOS (TODOS) ===")
        for result in cur.stored_results():
            for fila in result.fetchall():
                id_, id_persona, contrasena, id_tipo_usuario, created_by, created_at, updated_by, updated_at, deleted = fila
                estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
                ua = updated_at if updated_at else "-"
                print(f"ID:{id_:<3} | Persona:{id_persona} | Contraseña:{contrasena:<15} | "
                      f"Tipo Usuario:{id_tipo_usuario} | Estado:{estado:<9} | Creado por:{created_by} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_usuario: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_usuario", [id_usuario])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_usuario}.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx and cnx.is_connected():
            try: cnx.rollback()
            except: pass
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_usuario: int):
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_usuario", [id_usuario])
        cnx.commit()
        print(f"✅ Usuario restaurado ID {id_usuario}.")
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
        print("\n===== MENÚ USUARIOS (MySQL + SP) =====")
        print("1) Insertar usuario")
        print("2) Listar usuarios ACTIVOS")
        print("3) Listar usuarios (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID")
        print("0) Salir")

        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            try:
                id_persona = int(input("ID Persona (debe existir): ").strip())
                id_tipo_usuario = int(input("ID Tipo Usuario (debe existir): ").strip())
            except ValueError:
                print("❌ ID inválido.")
                continue
            contrasena = input("Contraseña: ").strip()
            created_by = input("Creado por: ").strip()
            sp_insertar(id_persona, contrasena, id_tipo_usuario, created_by)

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

if __name__ == "__main__":
    menu()

