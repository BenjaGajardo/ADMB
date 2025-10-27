# ==========================================
# sp_seguridad_plazas_menu.py
# CRUD y visualización de Procedimientos Almacenados (MySQL) desde Python
# Base de Datos: seguridad_plazas
# Autor: Dany (adaptado por ChatGPT)
# ==========================================

# Requisitos:
# 1) Instalar el conector oficial de MySQL para Python:
#    pip install mysql-connector-python
# 2) Ajustar las credenciales en DB_CONFIG según tu entorno.

# ---------- IMPORTS ----------
import mysql.connector
from datetime import datetime

# ---------- CONFIGURACIÓN DE CONEXIÓN ----------
DB_CONFIG = {
    "host": "localhost",      # Servidor MySQL (ej: localhost)
    "user": "root",           # Usuario con permisos adecuados
    "password": "1234",       # Contraseña del usuario (reemplazar)
    "database": "seguridad_plazas", # Base de datos objetivo
    # "port": 3306,             # (Opcional) Puerto si no es el por defecto
}

# ---------- FUNCIÓN DE CONEXIÓN ----------

def conectar():
    """
    Crea y devuelve una conexión a MySQL usando los parámetros definidos en DB_CONFIG.
    """
    return mysql.connector.connect(**DB_CONFIG)


# ---------- FUNCIONES GENERALES DE AYUDA (MANTENIDAS) ----------

def _call_proc_no_results(proc_name: str, args: list = None) -> bool:
    """
    Llama a un procedimiento almacenado que NO devuelve result sets (INSERT, UPDATE, DELETE lógico).
    Devuelve True si la operación se completó correctamente, False en caso de error.
    """
    cnx = cur = None
    try:
        cnx = conectar()
        cur = cnx.cursor()
        if args is None:
            cur.callproc(proc_name)
        else:
            cur.callproc(proc_name, args)
        cnx.commit()
        return True
    except mysql.connector.Error as e:
        print(f"❌ Error ejecutando {proc_name}:", e)
        if cnx and cnx.is_connected():
            try:
                cnx.rollback()
            except Exception:
                pass
        return False
    finally:
        if cur:
            cur.close()
        if cnx and cnx.is_connected():
            cnx.close()


def _call_proc_with_results(proc_name: str, args: list = None):
    """
    Llama a un procedimiento almacenado que devuelve resultados (SELECT).
    Retorna una lista de tuplas (filas).
    """
    cnx = cur = None
    results = []
    try:
        cnx = conectar()
        cur = cnx.cursor()
        if args is None:
            cur.callproc(proc_name)
        else:
            cur.callproc(proc_name, args)

        for stored in cur.stored_results():
            rows = stored.fetchall()
            results.extend(rows)

        return results

    except mysql.connector.Error as e:
        print(f"❌ Error leyendo resultados de {proc_name}:", e)
        return []
    finally:
        if cur:
            cur.close()
        if cnx and cnx.is_connected():
            cnx.close()


# ------------------------------------------------------------------
# ---------- FUNCIONES ADAPTADAS PARA 'seguridad_plazas' ----------
# ------------------------------------------------------------------

## ➡️ Tabla: tipo_usuarios (Reemplaza a 'roles')

def tipo_usuarios_insertar(nombre: str, descripcion: str, created_by: str = "script") -> bool:
    """ Llama a sp_tipo_usuarios_insertar. """
    args = [nombre, descripcion, created_by]
    return _call_proc_no_results("sp_tipo_usuarios_insertar", args)

def tipo_usuarios_borrado_logico(id_tipo_usuario: int, updated_by: str = "script") -> bool:
    """ Llama a sp_tipo_usuarios_borrado_logico. """
    args = [id_tipo_usuario, updated_by]
    return _call_proc_no_results("sp_tipo_usuarios_borrado_logico", args)

def tipo_usuarios_listar_activos():
    """ Llama a sp_tipo_usuarios_listar_activos. """
    rows = _call_proc_with_results("sp_tipo_usuarios_listar_activos")
    print("\n=== TIPOS DE USUARIO ACTIVOS ===")
    for row in rows:
        id_tipo_usuario, nombre, descripcion, created_at, created_by = row
        print(f"ID:{id_tipo_usuario:<3} | {nombre:<20} | {descripcion:<30} | Creado:{created_at} | By:{created_by}")

def tipo_usuarios_listar_todo():
    """ Llama a sp_tipo_usuarios_listar_todo. """
    rows = _call_proc_with_results("sp_tipo_usuarios_listar_todo")
    print("\n=== TODOS LOS TIPOS DE USUARIO ===")
    for row in rows:
        id_tipo_usuario, nombre, descripcion, created_at, created_by, deleted = row
        estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
        print(f"ID:{id_tipo_usuario:<3} | {nombre:<20} | {descripcion:<30} | {estado}")

## ➡️ Tabla: comunas (Nuevo)

def comunas_insertar(nombre: str, created_by: str = "script") -> bool:
    """ Llama a sp_comunas_insertar. """
    args = [nombre, created_by]
    return _call_proc_no_results("sp_comunas_insertar", args)

def comunas_borrado_logico(id_comuna: int, updated_by: str = "script") -> bool:
    """ Llama a sp_comunas_borrado_logico. """
    args = [id_comuna, updated_by]
    return _call_proc_no_results("sp_comunas_borrado_logico", args)

def comunas_listar_activos():
    """ Llama a sp_comunas_listar_activos. """
    rows = _call_proc_with_results("sp_comunas_listar_activos")
    print("\n=== COMUNAS ACTIVAS ===")
    for row in rows:
        id_comuna, nombre, created_at = row
        print(f"ID:{id_comuna:<3} | Nombre:{nombre:<30} | Creado:{created_at}")

def comunas_listar_todo():
    """ Llama a sp_comunas_listar_todo. """
    rows = _call_proc_with_results("sp_comunas_listar_todo")
    print("\n=== TODAS LAS COMUNAS ===")
    for row in rows:
        id_comuna, nombre, deleted = row
        estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
        print(f"ID:{id_comuna:<3} | Nombre:{nombre:<30} | {estado}")


## ➡️ Tabla: plazas (Reemplaza a 'basureros' en estructura)

def plazas_insertar(nombre: str, direccion: str, id_comuna: int, created_by: str = "script") -> bool:
    """ Llama a sp_plazas_insertar. """
    args = [nombre, direccion, id_comuna, created_by]
    return _call_proc_no_results("sp_plazas_insertar", args)

def plazas_borrado_logico(id_plaza: int, updated_by: str = "script") -> bool:
    """ Llama a sp_plazas_borrado_logico. """
    args = [id_plaza, updated_by]
    return _call_proc_no_results("sp_plazas_borrado_logico", args)

def plazas_listar_activos():
    """ Llama a sp_plazas_listar_activos (Muestra nombre comuna). """
    rows = _call_proc_with_results("sp_plazas_listar_activos")
    print("\n=== PLAZAS ACTIVAS ===")
    # Asumimos que el SP devuelve id_plaza, nombre_plaza, direccion, nombre_comuna, created_at
    for row in rows:
        id_plaza, nombre, direccion, comuna_nombre, created_at = row
        print(f"ID:{id_plaza:<3} | {nombre:<30} | Dir:{direccion:<30} | Comuna:{comuna_nombre}")

def plazas_listar_todo():
    """ Llama a sp_plazas_listar_todo. """
    rows = _call_proc_with_results("sp_plazas_listar_todo")
    print("\n=== TODAS LAS PLAZAS ===")
    # Asumimos que el SP devuelve id_plaza, nombre_plaza, direccion, nombre_comuna, deleted
    for row in rows:
        id_plaza, nombre, direccion, comuna_nombre, deleted = row
        estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
        print(f"ID:{id_plaza:<3} | {nombre:<30} | Comuna:{comuna_nombre} | {estado}")

## ➡️ Tabla: estado_camara (Reemplaza a 'materiales' en estructura)

def estado_camara_insertar(nombre: str, descripcion: str, created_by: str = "script") -> bool:
    """ Llama a sp_estado_camara_insertar. """
    args = [nombre, descripcion, created_by]
    return _call_proc_no_results("sp_estado_camara_insertar", args)

def estado_camara_borrado_logico(id_estado_camara: int, updated_by: str = "script") -> bool:
    """ Llama a sp_estado_camara_borrado_logico. """
    args = [id_estado_camara, updated_by]
    return _call_proc_no_results("sp_estado_camara_borrado_logico", args)

def estado_camara_listar_activos():
    """ Llama a sp_estado_camara_listar_activos. """
    rows = _call_proc_with_results("sp_estado_camara_listar_activos")
    print("\n=== ESTADOS DE CÁMARA ACTIVOS ===")
    for row in rows:
        id_estado_camara, nombre, descripcion, created_at = row
        print(f"ID:{id_estado_camara:<3} | {nombre:<20} | Descripcion:{descripcion}")

def estado_camara_listar_todo():
    """ Llama a sp_estado_camara_listar_todo. """
    rows = _call_proc_with_results("sp_estado_camara_listar_todo")
    print("\n=== TODOS LOS ESTADOS DE CÁMARA ===")
    for row in rows:
        id_estado_camara, nombre, descripcion, deleted = row
        estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
        print(f"ID:{id_estado_camara:<3} | {nombre:<20} | {estado}")

## ➡️ Tabla: camaras (Reemplaza a 'objetos' en estructura)

def camaras_insertar(ubicacion: str, id_estado_camara: int, id_plaza: int, created_by: str = "script") -> bool:
    """ Llama a sp_camaras_insertar. """
    args = [ubicacion, id_estado_camara, id_plaza, created_by]
    return _call_proc_no_results("sp_camaras_insertar", args)

def camaras_borrado_logico(id_camara: int, updated_by: str = "script") -> bool:
    """ Llama a sp_camaras_borrado_logico. """
    args = [id_camara, updated_by]
    return _call_proc_no_results("sp_camaras_borrado_logico", args)

def camaras_listar_activos():
    """ Llama a sp_camaras_listar_activos (Muestra estado y plaza). """
    rows = _call_proc_with_results("sp_camaras_listar_activos")
    print("\n=== CÁMARAS ACTIVAS ===")
    # Asumimos que el SP devuelve id_camara, ubicacion, estado_nombre, plaza_nombre, created_at
    for row in rows:
        id_camara, ubicacion, estado_nombre, plaza_nombre, created_at = row
        print(f"ID:{id_camara:<3} | Ubicacion:{ubicacion:<30} | Estado:{estado_nombre:<10} | Plaza:{plaza_nombre}")

def camaras_listar_todo():
    """ Llama a sp_camaras_listar_todo. """
    rows = _call_proc_with_results("sp_camaras_listar_todo")
    print("\n=== TODAS LAS CÁMARAS ===")
    # Asumimos que el SP devuelve id_camara, ubicacion, estado_nombre, plaza_nombre, deleted
    for row in rows:
        id_camara, ubicacion, estado_nombre, plaza_nombre, deleted = row
        estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
        print(f"ID:{id_camara:<3} | Ubicacion:{ubicacion:<30} | Plaza:{plaza_nombre} | {estado}")

## ➡️ Tabla: juntas_vecinos (Nuevo, sin equivalente en el original)

def juntas_vecinos_insertar(nombre: str, id_comuna: int, created_by: str = "script") -> bool:
    """ Llama a sp_juntas_vecinos_insertar. """
    args = [nombre, id_comuna, created_by]
    return _call_proc_no_results("sp_juntas_vecinos_insertar", args)

def juntas_vecinos_borrado_logico(id_junta: int, updated_by: str = "script") -> bool:
    """ Llama a sp_juntas_vecinos_borrado_logico. """
    args = [id_junta, updated_by]
    return _call_proc_no_results("sp_juntas_vecinos_borrado_logico", args)

def juntas_vecinos_listar_activos():
    """ Llama a sp_juntas_vecinos_listar_activos (Muestra nombre comuna). """
    rows = _call_proc_with_results("sp_juntas_vecinos_listar_activos")
    print("\n=== JUNTAS DE VECINOS ACTIVAS ===")
    # Asumimos que el SP devuelve id_junta, nombre_junta, nombre_comuna, created_at
    for row in rows:
        id_junta, nombre, comuna_nombre, created_at = row
        print(f"ID:{id_junta:<3} | Junta:{nombre:<30} | Comuna:{comuna_nombre}")

def juntas_vecinos_listar_todo():
    """ Llama a sp_juntas_vecinos_listar_todo. """
    rows = _call_proc_with_results("sp_juntas_vecinos_listar_todo")
    print("\n=== TODAS LAS JUNTAS DE VECINOS ===")
    # Asumimos que el SP devuelve id_junta, nombre_junta, nombre_comuna, deleted
    for row in rows:
        id_junta, nombre, comuna_nombre, deleted = row
        estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
        print(f"ID:{id_junta:<3} | Junta:{nombre:<30} | {estado}")

## ➡️ Tabla: personas (Nuevo)

def personas_insertar(rut: str, nombre: str, correo: str, telefono: str, direccion: str, id_comuna: int, created_by: str = "script") -> bool:
    """ Llama a sp_personas_insertar. """
    args = [rut, nombre, correo, telefono, direccion, id_comuna, created_by]
    return _call_proc_no_results("sp_personas_insertar", args)

def personas_borrado_logico(id_persona: int, updated_by: str = "script") -> bool:
    """ Llama a sp_personas_borrado_logico. """
    args = [id_persona, updated_by]
    return _call_proc_no_results("sp_personas_borrado_logico", args)

def personas_listar_activos():
    """ Llama a sp_personas_listar_activos (Muestra nombre comuna). """
    rows = _call_proc_with_results("sp_personas_listar_activos")
    print("\n=== PERSONAS ACTIVAS ===")
    # Asumimos que el SP devuelve id_persona, rut, nombre, telefono, comuna_nombre, created_at
    for row in rows:
        id_persona, rut, nombre, telefono, comuna_nombre, created_at = row
        print(f"ID:{id_persona:<3} | RUT:{rut:<12} | Nombre:{nombre:<30} | Tel:{telefono:<10} | Comuna:{comuna_nombre}")

def personas_listar_todo():
    """ Llama a sp_personas_listar_todo. """
    rows = _call_proc_with_results("sp_personas_listar_todo")
    print("\n=== TODAS LAS PERSONAS ===")
    # Asumimos que el SP devuelve id_persona, rut, nombre, comuna_nombre, deleted
    for row in rows:
        id_persona, rut, nombre, comuna_nombre, deleted = row
        estado = "ACTIVA" if deleted == 0 else "ELIMINADA"
        print(f"ID:{id_persona:<3} | RUT:{rut:<12} | Nombre:{nombre:<30} | {estado}")

## ➡️ Tabla: usuarios (Reemplaza a 'usuarios' en estructura)

def usuarios_insertar(id_persona: int, contrasena: str, id_tipo_usuario: int, created_by: str = "script") -> bool:
    """ Llama a sp_usuarios_insertar. """
    args = [id_persona, contrasena, id_tipo_usuario, created_by]
    return _call_proc_no_results("sp_usuarios_insertar", args)

def usuarios_borrado_logico(id_usuario: int, updated_by: str = "script") -> bool:
    """ Llama a sp_usuarios_borrado_logico. """
    args = [id_usuario, updated_by]
    return _call_proc_no_results("sp_usuarios_borrado_logico", args)

def usuarios_listar_activos():
    """ Llama a sp_usuarios_listar_activos (Muestra persona y tipo_usuario). """
    rows = _call_proc_with_results("sp_usuarios_listar_activos")
    print("\n=== USUARIOS DEL SISTEMA ACTIVOS ===")
    # Asumimos que el SP devuelve id_usuario, persona_nombre, tipo_usuario_nombre, created_at
    for row in rows:
        id_usuario, persona_nombre, tipo_usuario_nombre, created_at = row
        print(f"ID:{id_usuario:<3} | Persona:{persona_nombre:<30} | Tipo:{tipo_usuario_nombre:<15} | Creado:{created_at}")

def usuarios_listar_todo():
    """ Llama a sp_usuarios_listar_todo. """
    rows = _call_proc_with_results("sp_usuarios_listar_todo")
    print("\n=== TODOS LOS USUARIOS DEL SISTEMA ===")
    # Asumimos que el SP devuelve id_usuario, persona_nombre, tipo_usuario_nombre, deleted
    for row in rows:
        id_usuario, persona_nombre, tipo_usuario_nombre, deleted = row
        estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
        print(f"ID:{id_usuario:<3} | Persona:{persona_nombre:<30} | Tipo:{tipo_usuario_nombre:<15} | {estado}")

## ➡️ Tabla: tipo_reporte (Reemplaza a 'metodos_pago' en estructura)

def tipo_reporte_insertar(nombre: str, descripcion: str, created_by: str = "script") -> bool:
    """ Llama a sp_tipo_reporte_insertar. """
    args = [nombre, descripcion, created_by]
    return _call_proc_no_results("sp_tipo_reporte_insertar", args)

def tipo_reporte_borrado_logico(id_tipo_reporte: int, updated_by: str = "script") -> bool:
    """ Llama a sp_tipo_reporte_borrado_logico. """
    args = [id_tipo_reporte, updated_by]
    return _call_proc_no_results("sp_tipo_reporte_borrado_logico", args)

def tipo_reporte_listar_activos():
    """ Llama a sp_tipo_reporte_listar_activos. """
    rows = _call_proc_with_results("sp_tipo_reporte_listar_activos")
    print("\n=== TIPOS DE REPORTE ACTIVOS ===")
    for row in rows:
        id_tipo, nombre, descripcion, created_at = row
        print(f"ID:{id_tipo:<3} | {nombre:<30} | {descripcion}")

def tipo_reporte_listar_todo():
    """ Llama a sp_tipo_reporte_listar_todo. """
    rows = _call_proc_with_results("sp_tipo_reporte_listar_todo")
    print("\n=== TODOS LOS TIPOS DE REPORTE ===")
    for row in rows:
        id_tipo, nombre, descripcion, deleted = row
        estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
        print(f"ID:{id_tipo:<3} | {nombre:<30} | {estado}")

## ➡️ Tabla: reportes (Reemplaza a 'pagos' en estructura)

def reportes_insertar(id_tipo_reporte: int, descripcion: str, fecha: datetime, hora: datetime, id_usuario: int, id_plaza: int, created_by: str = "script") -> bool:
    """ Llama a sp_reportes_insertar. """
    # Convertir fecha y hora a formatos compatibles con MySQL
    fecha_str = fecha.strftime('%Y-%m-%d') if isinstance(fecha, datetime) else fecha
    hora_str = hora.strftime('%H:%M:%S') if isinstance(hora, datetime) else hora
    args = [id_tipo_reporte, descripcion, fecha_str, hora_str, id_usuario, id_plaza, created_by]
    return _call_proc_no_results("sp_reportes_insertar", args)

def reportes_borrado_logico(id_reporte: int, updated_by: str = "script") -> bool:
    """ Llama a sp_reportes_borrado_logico. """
    args = [id_reporte, updated_by]
    return _call_proc_no_results("sp_reportes_borrado_logico", args)

def reportes_listar_activos():
    """ Llama a sp_reportes_listar_activos. """
    rows = _call_proc_with_results("sp_reportes_listar_activos")
    print("\n=== REPORTES ACTIVOS ===")
    # Asumimos que el SP devuelve id_reporte, tipo_reporte_nombre, fecha, hora, usuario_nombre, plaza_nombre
    for row in rows:
        id_reporte, tipo_reporte_nombre, fecha, hora, usuario_nombre, plaza_nombre = row
        print(f"ID:{id_reporte:<3} | Tipo:{tipo_reporte_nombre:<20} | Fecha/Hora:{fecha} {hora} | Usu:{usuario_nombre} | Pza:{plaza_nombre}")

def reportes_listar_todo():
    """ Llama a sp_reportes_listar_todo. """
    rows = _call_proc_with_results("sp_reportes_listar_todo")
    print("\n=== TODOS LOS REPORTES ===")
    # Asumimos que el SP devuelve id_reporte, tipo_reporte_nombre, fecha, hora, usuario_nombre, plaza_nombre, deleted
    for row in rows:
        id_reporte, tipo_reporte_nombre, fecha, hora, usuario_nombre, plaza_nombre, deleted = row
        estado = "ACTIVO" if deleted == 0 else "ELIMINADO"
        print(f"ID:{id_reporte:<3} | Tipo:{tipo_reporte_nombre:<20} | Fecha/Hora:{fecha} {hora} | {estado}")


# --------------------------------------------------------
# 🎯 MENÚ PRINCIPAL Y SUB-MENÚS ADAPTADOS
# --------------------------------------------------------

def menu_tabla_tipo_usuarios():
    """ Menú para la tabla tipo_usuarios. """
    while True:
        print("\n--- MENÚ TIPOS DE USUARIO ---")
        print("1) Insertar tipo de usuario")
        print("2) Listar tipos ACTIVOS")
        print("3) Listar tipos (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input("Nombre tipo: ").strip()
            descripcion = input("Descripcion: ").strip()
            created_by = input("Creado por (user): ").strip() or "script"
            ok = tipo_usuarios_insertar(nombre, descripcion, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            tipo_usuarios_listar_activos()
        elif op == "3":
            tipo_usuarios_listar_todo()
        elif op == "4":
            try:
                idr = int(input("ID tipo a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = tipo_usuarios_borrado_logico(idr, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")

def menu_tabla_comunas():
    """ Menú para la tabla comunas. """
    while True:
        print("\n--- MENÚ COMUNAS ---")
        print("1) Insertar comuna")
        print("2) Listar comunas ACTIVAS")
        print("3) Listar comunas (TODAS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input("Nombre comuna: ").strip()
            created_by = input("Creado por (user): ").strip() or "script"
            ok = comunas_insertar(nombre, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            comunas_listar_activos()
        elif op == "3":
            comunas_listar_todo()
        elif op == "4":
            try:
                idr = int(input("ID comuna a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = comunas_borrado_logico(idr, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")

def menu_tabla_plazas():
    """ Menú para la tabla plazas. """
    while True:
        print("\n--- MENÚ PLAZAS ---")
        print("1) Insertar plaza")
        print("2) Listar plazas ACTIVAS")
        print("3) Listar plazas (TODAS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input("Nombre plaza: ").strip()
            direccion = input("Dirección: ").strip()
            try:
                id_comuna = int(input("ID Comuna: ").strip())
            except ValueError:
                print("ID Comuna inválido")
                continue
            created_by = input("Creado por: ").strip() or "script"
            ok = plazas_insertar(nombre, direccion, id_comuna, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            plazas_listar_activos()
        elif op == "3":
            plazas_listar_todo()
        elif op == "4":
            try:
                idb = int(input("ID plaza a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = plazas_borrado_logico(idb, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_estado_camara():
    """ Menú para la tabla estado_camara. """
    while True:
        print("\n--- MENÚ ESTADOS DE CÁMARA ---")
        print("1) Insertar estado")
        print("2) Listar estados ACTIVOS")
        print("3) Listar estados (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input("Nombre estado (ACTIVA/INACTIVA): ").strip()
            descripcion = input("Descripcion: ").strip()
            created_by = input("Creado por: ").strip() or "script"
            ok = estado_camara_insertar(nombre, descripcion, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            estado_camara_listar_activos()
        elif op == "3":
            estado_camara_listar_todo()
        elif op == "4":
            try:
                idm = int(input("ID estado a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = estado_camara_borrado_logico(idm, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_camaras():
    """ Menú para la tabla camaras. """
    while True:
        print("\n--- MENÚ CÁMARAS ---")
        print("1) Insertar cámara")
        print("2) Listar cámaras ACTIVAS")
        print("3) Listar cámaras (TODAS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            ubicacion = input("Ubicación dentro de la plaza: ").strip()
            try:
                id_estado = int(input("ID Estado Cámara: ").strip())
                id_plaza = int(input("ID Plaza: ").strip())
            except ValueError:
                print("IDs inválidos")
                continue
            created_by = input("Creado por: ").strip() or "script"
            ok = camaras_insertar(ubicacion, id_estado, id_plaza, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            camaras_listar_activos()
        elif op == "3":
            camaras_listar_todo()
        elif op == "4":
            try:
                ido = int(input("ID cámara a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = camaras_borrado_logico(ido, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_juntas_vecinos():
    """ Menú para la tabla juntas_vecinos. """
    while True:
        print("\n--- MENÚ JUNTAS DE VECINOS ---")
        print("1) Insertar junta de vecinos")
        print("2) Listar juntas ACTIVAS")
        print("3) Listar juntas (TODAS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input("Nombre junta: ").strip()
            try:
                id_comuna = int(input("ID Comuna: ").strip())
            except ValueError:
                print("ID Comuna inválido")
                continue
            created_by = input("Creado por: ").strip() or "script"
            ok = juntas_vecinos_insertar(nombre, id_comuna, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            juntas_vecinos_listar_activos()
        elif op == "3":
            juntas_vecinos_listar_todo()
        elif op == "4":
            try:
                idm = int(input("ID junta a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = juntas_vecinos_borrado_logico(idm, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_personas():
    """ Menú para la tabla personas. """
    while True:
        print("\n--- MENÚ PERSONAS (VECINOS/PERSONAL) ---")
        print("1) Insertar persona")
        print("2) Listar personas ACTIVAS")
        print("3) Listar personas (TODAS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            rut = input("RUT: ").strip()
            nombre = input("Nombre: ").strip()
            correo = input("Correo (opcional): ").strip() or None
            telefono = input("Teléfono (opcional): ").strip() or None
            direccion = input("Dirección (opcional): ").strip() or None
            try:
                id_comuna = int(input("ID Comuna: ").strip())
            except ValueError:
                print("ID Comuna inválido")
                continue
            created_by = input("Creado por: ").strip() or "script"
            ok = personas_insertar(rut, nombre, correo, telefono, direccion, id_comuna, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            personas_listar_activos()
        elif op == "3":
            personas_listar_todo()
        elif op == "4":
            try:
                idp = int(input("ID persona a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = personas_borrado_logico(idp, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_usuarios_sistema():
    """ Menú para la tabla usuarios (del sistema). """
    while True:
        print("\n--- MENÚ USUARIOS DEL SISTEMA ---")
        print("1) Insertar usuario")
        print("2) Listar usuarios ACTIVOS")
        print("3) Listar usuarios (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            try:
                id_persona = int(input("ID Persona (ya registrada): ").strip())
            except ValueError:
                print("ID Persona inválido")
                continue
            contrasena = input("Contraseña: ").strip()
            try:
                id_tipo_usuario = int(input("ID Tipo Usuario: ").strip())
            except ValueError:
                print("ID Tipo Usuario inválido")
                continue
            created_by = input("Creado por: ").strip() or "script"
            ok = usuarios_insertar(id_persona, contrasena, id_tipo_usuario, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            usuarios_listar_activos()
        elif op == "3":
            usuarios_listar_todo()
        elif op == "4":
            try:
                idu = int(input("ID usuario a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = usuarios_borrado_logico(idu, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_tipo_reporte():
    """ Menú para la tabla tipo_reporte. """
    while True:
        print("\n--- MENÚ TIPOS DE REPORTE ---")
        print("1) Insertar tipo de reporte")
        print("2) Listar tipos ACTIVOS")
        print("3) Listar tipos (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            nombre = input("Nombre tipo: ").strip()
            descripcion = input("Descripcion: ").strip()
            created_by = input("Creado por: ").strip() or "script"
            ok = tipo_reporte_insertar(nombre, descripcion, created_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "2":
            tipo_reporte_listar_activos()
        elif op == "3":
            tipo_reporte_listar_todo()
        elif op == "4":
            try:
                idm = int(input("ID tipo reporte a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = tipo_reporte_borrado_logico(idm, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


def menu_tabla_reportes():
    """ Menú para la tabla reportes. """
    while True:
        print("\n--- MENÚ REPORTES ---")
        print("1) Insertar reporte")
        print("2) Listar reportes ACTIVOS")
        print("3) Listar reportes (TODOS)")
        print("4) Borrado lógico por ID")
        print("0) Volver")
        op = input("Opción: ").strip()
        if op == "1":
            try:
                id_tipo = int(input("ID Tipo Reporte: ").strip())
            except ValueError:
                print("ID Tipo Reporte inválido")
                continue
            descripcion = input("Descripción (opcional): ").strip() or None
            
            # Pide fecha y hora
            fecha_input = input("Fecha reporte (YYYY-MM-DD) o vacío para HOY: ").strip()
            hora_input = input("Hora reporte (HH:MM:SS) o vacío para AHORA: ").strip()

            fecha = datetime.now().date() if fecha_input == "" else fecha_input
            hora = datetime.now().time() if hora_input == "" else hora_input
            
            try:
                id_usuario = int(input("ID Usuario: ").strip())
                id_plaza = int(input("ID Plaza: ").strip())
            except ValueError:
                print("IDs Usuario/Plaza inválidos")
                continue
            
            created_by = input("Creado por: ").strip() or "script"
            
            # Nota: usamos 'datetime.combine' para asegurar un objeto datetime si se usó NOW
            if fecha_input == "" or hora_input == "":
                # Si se usó NOW para alguno, usamos datetime.now() para la llamada al SP
                ok = reportes_insertar(id_tipo, descripcion, datetime.now(), datetime.now(), id_usuario, id_plaza, created_by)
            else:
                # Si se ingresaron manualmente, podemos enviar los strings
                ok = reportes_insertar(id_tipo, descripcion, fecha, hora, id_usuario, id_plaza, created_by)
            
            print("✅ OK" if ok else "❌ Error")

        elif op == "2":
            reportes_listar_activos()
        elif op == "3":
            reportes_listar_todo()
        elif op == "4":
            try:
                idp = int(input("ID reporte a borrar lógicamente: ").strip())
            except ValueError:
                print("ID inválido")
                continue
            updated_by = input("Actualizado por: ").strip() or "script"
            ok = reportes_borrado_logico(idp, updated_by)
            print("✅ OK" if ok else "❌ Error")
        elif op == "0":
            break
        else:
            print("Opción no válida")


# ---------- MENÚ PRINCIPAL ADAPTADO ----------

def menu_principal():
    """
    Menú principal para la base de datos 'seguridad_plazas'.
    """
    while True:
        print("\n===== MENÚ PRINCIPAL (seguridad_plazas - SP) =====")
        print("1) Tipos de Usuario")
        print("2) Comunas")
        print("3) Plazas")
        print("4) Estados de Cámara")
        print("5) Cámaras")
        print("6) Juntas de Vecinos")
        print("7) Personas")
        print("8) Usuarios del Sistema")
        print("9) Tipos de Reporte")
        print("10) Reportes")
        print("0) Salir")
        
        opcion = input("Selecciona una opción: ").strip()
        
        if opcion == "1":
            menu_tabla_tipo_usuarios()
        elif opcion == "2":
            menu_tabla_comunas()
        elif opcion == "3":
            menu_tabla_plazas()
        elif opcion == "4":
            menu_tabla_estado_camara()
        elif opcion == "5":
            menu_tabla_camaras()
        elif opcion == "6":
            menu_tabla_juntas_vecinos()
        elif opcion == "7":
            menu_tabla_personas()
        elif opcion == "8":
            menu_tabla_usuarios_sistema()
        elif opcion == "9":
            menu_tabla_tipo_reporte()
        elif opcion == "10":
            menu_tabla_reportes()
        elif opcion == "0":
            print("Saliendo...")
            break
        else:
            print("Opción no válida. Intenta nuevamente.")


# Punto de entrada del script
if __name__ == "__main__":
    print("Iniciando interfaz de procedimientos almacenados para 'seguridad_plazas'.")
    print("Asegúrate de tener los procedimientos creados en la base de datos y ajustar DB_CONFIG.")
    menu_principal()