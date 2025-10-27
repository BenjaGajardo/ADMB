import mysql.connector
import os 
from getpass import getpass 

# ==========================================================
# CONFIGURACIÓN DE CONEXIÓN (AJUSTAR ESTOS VALORES)
# ==========================================================
DB_CONFIG = {
    'user': 'root', # Tu usuario de MySQL
    'password': getpass("Ingrese la contraseña de MySQL: "), 
    'host': '127.0.0.1', 
    'database': 'seguridad_plazas'
}

# ==========================================================
# FUNCIONES BASE
# ==========================================================

def limpiar_pantalla():
    """Limpia la consola."""
    os.system('cls' if os.name == 'nt' else 'clear')

def ejecutar_sp(nombre_sp, parametros=None):
    """Ejecuta un procedimiento almacenado y retorna los resultados (si los hay)."""
    conn = None
    cursor = None
    resultados = None
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        if parametros:
            cursor.callproc(nombre_sp, parametros)
        else:
            cursor.callproc(nombre_sp)
        
        for result in cursor.stored_results():
            resultados = result.fetchall()
        
        if resultados is None:
            conn.commit()
            print(f"\n✅ Operación '{nombre_sp}' ejecutada con éxito.")
            return True

        return resultados

    except mysql.connector.Error as err:
        print(f"\n❌ Error de MySQL {err.errno}: {err.msg}")
        return False
    
    finally:
        if cursor: cursor.close()
        if conn and conn.is_connected():
            conn.close()

def listar_datos(titulo, nombre_sp, encabezados):
    """Llama al SP de listado e imprime los resultados en formato tabla."""
    limpiar_pantalla()
    print(f"\n=== {titulo.upper()} ===\n")
    resultados = ejecutar_sp(nombre_sp)
    
    if resultados and resultados is not True:
        # Imprimir encabezados
        # Limitamos los encabezados para que coincidan con los resultados si hay menos de los esperados
        num_cols_devueltas = len(resultados[0]) if resultados else 0
        encabezados_a_usar = encabezados[:num_cols_devueltas]

        print(" | ".join(encabezados_a_usar))
        print("-" * (sum(len(h) for h in encabezados_a_usar) + len(encabezados_a_usar) * 3))

        for fila in resultados:
            print(" | ".join(map(str, fila)))
    elif resultados is False:
         print("No se pudo obtener la lista debido a un error.")
    else:
        print("No hay datos para mostrar.")

    input("\nPresiona Enter para continuar...")


# ==========================================================
# MENÚS ESPECÍFICOS DE LAS TABLAS (ESTRUCTURA UNIFICADA)
# ==========================================================

def menu_tabla_tipo_usuarios():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: TIPO USUARIOS ===")
        print("1. Insertar (sp_tipo_usuarios_insertar)")
        print("2. Listar Activos (sp_tipo_usuarios_listar_activos)")
        print("3. Listar TODO (sp_tipo_usuarios_listar_todo)")
        print("4. Borrado Lógico (sp_tipo_usuarios_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            nombre = input("Nombre: ")
            descripcion = input("Descripción: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_tipo_usuarios_insertar", (nombre, descripcion, created_by))
        elif opcion == '2':
            encabezados = ["ID", "NOMBRE", "DESCRIPCION", "C_BY", "C_AT"]
            listar_datos("TIPOS DE USUARIO ACTIVOS", "sp_tipo_usuarios_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (8 columnas en MySQL: ID, Nombre, Desc, C_BY, C_AT, U_BY, U_AT, DEL)
            encabezados = ["ID", "NOMBRE", "DESCRIP", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODOS LOS TIPOS DE USUARIO", "sp_tipo_usuarios_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID a eliminar (Borrado Lógico): ")
            ejecutar_sp("sp_tipo_usuarios_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_comunas():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: COMUNAS ===")
        print("1. Insertar (sp_comunas_insertar)")
        print("2. Listar Activas (sp_comunas_listar_activos)")
        print("3. Listar TODO (sp_comunas_listar_todo)")
        print("4. Borrado Lógico (sp_comunas_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            nombre = input("Nombre de la Comuna: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_comunas_insertar", (nombre, created_by))
        elif opcion == '2':
            encabezados = ["ID", "NOMBRE", "C_BY", "C_AT"]
            listar_datos("COMUNAS ACTIVAS", "sp_comunas_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (8 columnas)
            encabezados = ["ID", "NOMBRE", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODAS LAS COMUNAS", "sp_comunas_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de comuna a eliminar: ")
            ejecutar_sp("sp_comunas_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_plazas():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: PLAZAS ===")
        print("1. Insertar (sp_plazas_insertar)")
        print("2. Listar Activas (sp_plazas_listar_activos)")
        print("3. Listar TODO (sp_plazas_listar_todo)")
        print("4. Borrado Lógico (sp_plazas_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            nombre = input("Nombre de la Plaza: ")
            direccion = input("Dirección: ")
            id_comuna = input("ID Comuna: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_plazas_insertar", (nombre, direccion, int(id_comuna), created_by))
        elif opcion == '2':
            # sp_plazas_listar_activos devuelve columnas de Plazas + nombre_comuna
            encabezados = ["ID", "NOMBRE", "DIRECCION", "ID_COMUNA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL", "NOM_COMUNA"]
            listar_datos("PLAZAS ACTIVAS", "sp_plazas_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (10 columnas: 5 datos + 5 auditoría)
            encabezados = ["ID", "NOMBRE", "DIRECCION", "ID_COMUNA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL", "COL10"]
            listar_datos("TODAS LAS PLAZAS", "sp_plazas_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de plaza a eliminar: ")
            ejecutar_sp("sp_plazas_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_estado_camara():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: ESTADO CÁMARA ===")
        print("1. Insertar (sp_estado_camara_insertar)")
        print("2. Listar Activos (sp_estado_camara_listar_activos)")
        print("3. Listar TODO (sp_estado_camara_listar_todo)")
        print("4. Borrado Lógico (sp_estado_camara_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            nombre = input("Nombre del Estado (ej: ACTIVA): ")
            descripcion = input("Descripción: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_estado_camara_insertar", (nombre, descripcion, created_by))
        elif opcion == '2':
            encabezados = ["ID", "NOMBRE", "DESCRIPCION", "C_BY", "C_AT"]
            listar_datos("ESTADOS CÁMARA ACTIVOS", "sp_estado_camara_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (8 columnas)
            encabezados = ["ID", "NOMBRE", "DESCRIPCION", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODOS LOS ESTADOS CÁMARA", "sp_estado_camara_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de estado a eliminar: ")
            ejecutar_sp("sp_estado_camara_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_camaras():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: CÁMARAS ===")
        print("1. Insertar (sp_camaras_insertar)")
        print("2. Listar Activas (sp_camaras_listar_activas)")
        print("3. Listar TODO (sp_camaras_listar_todo)")
        print("4. Borrado Lógico (sp_camaras_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            ubicacion = input("Ubicación: ")
            id_estado = input("ID Estado Cámara: ")
            id_plaza = input("ID Plaza: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_camaras_insertar", (ubicacion, int(id_estado), int(id_plaza), created_by))
        elif opcion == '2':
            # sp_camaras_listar_activas devuelve ID, Ubicacion, Estado(Nombre), Plaza(Nombre)
            encabezados = ["ID", "UBICACION", "ESTADO", "PLAZA"]
            listar_datos("CÁMARAS ACTIVAS", "sp_camaras_listar_activas", encabezados)
        elif opcion == '3':
            # Listar TODO (10 columnas: 4 datos + 5 auditoría + ID)
            encabezados = ["ID", "UBICACION", "ID_ESTADO", "ID_PLAZA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL", "COL10"]
            listar_datos("TODAS LAS CÁMARAS", "sp_camaras_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de cámara a eliminar: ")
            ejecutar_sp("sp_camaras_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_personas():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: PERSONAS ===")
        print("1. Insertar (sp_personas_insertar)")
        print("2. Listar Activas (sp_personas_listar_activas)")
        print("3. Listar TODO (sp_personas_listar_todo)")
        print("4. Borrado Lógico (sp_personas_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            rut = input("RUT: ")
            nombre = input("Nombre: ")
            correo = input("Correo: ")
            telefono = input("Teléfono: ")
            direccion = input("Dirección: ")
            id_comuna = input("ID Comuna: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_personas_insertar", (rut, nombre, correo, telefono, direccion, int(id_comuna), created_by))
        elif opcion == '2':
            # sp_personas_listar_activas devuelve 13 columnas (Personas + Comuna.nombre)
            encabezados = ["ID", "RUT", "NOMBRE", "CORREO", "TEL", "DIRECCION", "ID_COMUNA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL", "COMUNA"]
            listar_datos("PERSONAS ACTIVAS", "sp_personas_listar_activas", encabezados)
        elif opcion == '3':
            # Listar TODO (12 columnas: 7 datos + 5 auditoría)
            encabezados = ["ID", "RUT", "NOMBRE", "CORREO", "TEL", "DIRECC", "ID_COMUNA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODAS LAS PERSONAS", "sp_personas_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de persona a eliminar: ")
            ejecutar_sp("sp_personas_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_juntas_vecinos():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: JUNTAS VECINOS ===")
        print("1. Insertar (sp_juntas_vecinos_insertar)")
        print("2. Listar Activas (sp_juntas_vecinos_listar_activas)")
        print("3. Listar TODO (sp_juntas_vecinos_listar_todo)")
        print("4. Borrado Lógico (sp_juntas_vecinos_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            nombre = input("Nombre de la Junta: ")
            id_comuna = input("ID Comuna: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_juntas_vecinos_insertar", (nombre, int(id_comuna), created_by))
        elif opcion == '2':
            # sp_juntas_vecinos_listar_activas devuelve ID, Nombre, Comuna(Nombre)
            encabezados = ["ID", "NOMBRE", "COMUNA"]
            listar_datos("JUNTAS VECINOS ACTIVAS", "sp_juntas_vecinos_listar_activas", encabezados)
        elif opcion == '3':
            # Listar TODO (9 columnas: 3 datos + 5 auditoría + ID)
            encabezados = ["ID", "NOMBRE", "ID_COMUNA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL", "COL9"]
            listar_datos("TODAS LAS JUNTAS VECINOS", "sp_juntas_vecinos_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de junta a eliminar: ")
            ejecutar_sp("sp_juntas_vecinos_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_usuarios():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: USUARIOS ===")
        print("1. Insertar (sp_usuarios_insertar)")
        print("2. Listar Activos (sp_usuarios_listar_activos)")
        print("3. Listar TODO (sp_usuarios_listar_todo)")
        print("4. Borrado Lógico (sp_usuarios_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            id_persona = input("ID Persona: ")
            contrasena = getpass("Contraseña: ")
            id_tipo_usuario = input("ID Tipo Usuario: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_usuarios_insertar", (int(id_persona), contrasena, int(id_tipo_usuario), created_by))
        elif opcion == '2':
            # sp_usuarios_listar_activos devuelve ID, RUT, Nombre Persona, Tipo Usuario
            encabezados = ["ID", "RUT", "NOMBRE_PERSONA", "TIPO_USUARIO"]
            listar_datos("USUARIOS ACTIVOS", "sp_usuarios_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (9 columnas: ID, ID_PERSONA, Contrasena, ID_TIPO_USER + 5 auditoría)
            encabezados = ["ID", "ID_PER", "CONTRSEÑA_HASH", "ID_TIPO", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODOS LOS USUARIOS", "sp_usuarios_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de usuario a eliminar: ")
            ejecutar_sp("sp_usuarios_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_tipo_reporte():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: TIPO REPORTE ===")
        print("1. Insertar (sp_tipo_reporte_insertar)")
        print("2. Listar Activos (sp_tipo_reporte_listar_activos)")
        print("3. Listar TODO (sp_tipo_reporte_listar_todo)")
        print("4. Borrado Lógico (sp_tipo_reporte_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            nombre = input("Nombre: ")
            descripcion = input("Descripción: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_tipo_reporte_insertar", (nombre, descripcion, created_by))
        elif opcion == '2':
            encabezados = ["ID", "NOMBRE", "DESCRIPCION", "C_BY", "C_AT"]
            listar_datos("TIPOS DE REPORTE ACTIVOS", "sp_tipo_reporte_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (8 columnas)
            encabezados = ["ID", "NOMBRE", "DESCRIP", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODOS LOS TIPOS DE REPORTE", "sp_tipo_reporte_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de tipo de reporte a eliminar: ")
            ejecutar_sp("sp_tipo_reporte_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")

def menu_tabla_reportes():
    while True:
        limpiar_pantalla()
        print("\n=== GESTIÓN: REPORTES ===")
        print("1. Insertar (sp_reportes_insertar)")
        print("2. Listar Activos (sp_reportes_listar_activos)")
        print("3. Listar TODO (sp_reportes_listar_todo)")
        print("4. Borrado Lógico (sp_reportes_borrado_logico)")
        print("0. Volver")
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            id_plaza = input("ID Plaza: ")
            id_usuario = input("ID Usuario: ")
            id_tipo_reporte = input("ID Tipo Reporte: ")
            descripcion = input("Descripción del Reporte: ")
            created_by = input("Creado por: ")
            ejecutar_sp("sp_reportes_insertar", (int(id_plaza), int(id_usuario), int(id_tipo_reporte), descripcion, created_by))
        elif opcion == '2':
            # sp_reportes_listar_activos devuelve 8 columnas (ID, Descrip, Fecha, Hora, C_AT, Plaza, Usuario, Tipo_Reporte)
            encabezados = ["ID", "DESCRIPCION", "FECHA", "HORA", "C_AT", "PLAZA", "USUARIO", "TIPO_REPORTE"]
            listar_datos("REPORTES ACTIVOS", "sp_reportes_listar_activos", encabezados)
        elif opcion == '3':
            # Listar TODO (12 columnas: 7 datos + 5 auditoría)
            encabezados = ["ID", "ID_REPORTE", "DESCRIP", "FECHA", "HORA", "ID_USER", "ID_PLAZA", "C_BY", "C_AT", "U_BY", "U_AT", "DEL"]
            listar_datos("TODOS LOS REPORTES", "sp_reportes_listar_todo", encabezados)
        elif opcion == '4':
            id_borrar = input("ID de reporte a eliminar: ")
            ejecutar_sp("sp_reportes_borrado_logico", (int(id_borrar),))
        elif opcion == '0':
            break
        else:
            print("Opción no válida.")


# ==========================================================
# MENÚ PRINCIPAL
# ==========================================================

def menu_principal():
    while True:
        limpiar_pantalla()
        print("\n=== MENÚ PRINCIPAL - SEGURIDAD PLAZAS ===")
        print("1. Tipo de Usuarios")
        print("2. Comunas")
        print("3. Plazas")
        print("4. Estado Cámara")
        print("5. Cámaras")
        print("6. Personas")
        print("7. Juntas de Vecinos")
        print("8. Usuarios")
        print("9. Tipo Reporte")
        print("10. Reportes")
        print("0. Salir")
        
        opcion = input("Seleccione una opción: ")
        
        if opcion == '1':
            menu_tabla_tipo_usuarios()
        elif opcion == '2':
            menu_tabla_comunas()
        elif opcion == '3':
            menu_tabla_plazas()
        elif opcion == '4':
            menu_tabla_estado_camara()
        elif opcion == '5':
            menu_tabla_camaras()
        elif opcion == '6':
            menu_tabla_personas()
        elif opcion == '7':
            menu_tabla_juntas_vecinos()
        elif opcion == '8':
            menu_tabla_usuarios()
        elif opcion == '9':
            menu_tabla_tipo_reporte()
        elif opcion == '10':
            menu_tabla_reportes()
        elif opcion == '0':
            print("Saliendo del sistema. ¡Adiós!")
            break
        else:
            print("Opción no válida. Intente de nuevo.")
            input("Presiona Enter para continuar...")

# ==========================================================
# INICIO DEL PROGRAMA
# ==========================================================
if __name__ == "__main__":
    menu_principal()