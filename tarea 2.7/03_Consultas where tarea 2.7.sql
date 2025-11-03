-- 1.-  Mostrar todos los usuarios de tipo Cliente
select u.username , u.email, t.nombre_tipo
from usuarios u  -- Seleccion de tablas 
join tipo_usuarios t on u.id_tipo_usuario = t.id_tipo 
where u.id_tipo_usuario = 2;

-- 2.-  Mostrar Personas nacidas despues del año 1990
select p.nombre_completo, p.fecha_nac, u.username
from personas p 
join usuarios u on fecha_nac >= '1990-01-01'
where p.id_usuario = u.id_usuario;

-- 3.- Seleccionar nombres de personas que comiencen con la 
select p.nombre_completo, u.email
from personas p 
join usuarios u on p.nombre_completo LIKE 'A%'
where p.id_usuario = u.id_usuario;

-- 4.- Mostrar usuarios cuyos dominios de correo sean
-- mail.commit LIKE '%mail.com%' y con su respectivo nombre completo
select u.username, u.email, p.nombre_completo
FROM usuarios u 
join personas p on u.id_usuario = p.id_usuario
WHERE email LIKE '%mail.com%';

-- 5.- Mostrar todas las personas que no viven en 
-- Valparaiso y su usuario + ciudad.
select p.nombre_completo, c.region, u.username, c.nombre_ciudad
from personas p
join ciudad c on p.id_ciudad = c.id_ciudad 
join usuarios u on p.id_usuario = u.id_usuario
where c.id_ciudad != 2;

-- 6.- Mostrar usuarios que contengan más de 7 
-- carácteres de longitud.
select u.username, p.nombre_completo
from usuarios u
join personas p on u.id_usuario = p.id_usuario
where CHAR_LENGTH(username) > 7;

-- 7.- Mostrar username de personas nacidas entre
-- 1990 y 1995
select u.username, p.fecha_nac 
from usuarios u 
join personas p on fecha_nac between '1990-01-01' AND '1995-12-31'
where u.id_usuario = p.id_usuario;
