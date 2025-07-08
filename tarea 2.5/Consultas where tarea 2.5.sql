-- 1.-  Mostrar todos los usuarios de tipo Cliente
select u.username , u.email, t.nombre_tipo
from usuarios u, tipo_usuarios t
where u.id_tipo_usuario = 2
and u.id_tipo_usuario = t.id_tipo;

-- 2.-  Mostrar Personas nacidas despues del año 1990
select p.nombre_completo, p.fecha_nac, u.username
from personas p, usuarios u
where p.id_usuario = u.id_usuario
and fecha_nac >= '1990-01-01';

-- 3.- Seleccionar nombres de personas que comiencen con la 
select p.nombre_completo, u.email
from personas p, usuarios u
where p.id_usuario = u.id_usuario
and p.nombre_completo LIKE 'A%';

-- 4.- Mostrar usuarios cuyos dominios de correo sean
-- mail.commit LIKE '%mail.com%'
select username, email
FROM usuarios
WHERE email LIKE '%mail.com%';

-- 5.- Mostrar todas las personas que no viven en 
-- Valparaiso y su usuario + ciudad.
select p.nombre_completo, c.region, u.username, c.nombre_ciudad
from personas p, ciudad c, usuarios u
where p.id_ciudad = c.id_ciudad 
and p.id_usuario = u.id_usuario
and c.id_ciudad != 2;

-- 6.- Mostrar usuarios que contengan más de 7 
-- carácteres de longitud.
SELECT username
FROM usuarios
WHERE CHAR_LENGTH(username) > 7;

-- 7.- Mostrar username de personas nacidas entre
-- 1990 y 1995
select u.username, p.fecha_nac 
from usuarios u, personas p
where fecha_nac between '1990-01-01' AND '1995-12-31'
and u.id_usuario = p.id_usuario;