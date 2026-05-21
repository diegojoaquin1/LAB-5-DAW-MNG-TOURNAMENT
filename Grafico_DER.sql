Table organizadores {
  id int [pk, increment]
  nombre_organizacion varchar
  email varchar
  sitio_web varchar
  fecha_creacion timestamp
}

Table equipos {
  id int [pk, increment]
  nombre_equipo varchar
  logo_url varchar
  fecha_creacion date
}

Table jugadores {
  id int [pk, increment]
  gamertag varchar
  email varchar
  rango varchar
  equipo_id int
  fecha_registro timestamp
}

Table torneos {
  id int [pk, increment]
  organizador_id int
  nombre_juego varchar
  titulo_torneo varchar
  premio_virtual varchar
  max_participantes int
  fecha_evento date
}

Table inscripciones {
  id int [pk, increment]
  jugador_id int
  torneo_id int
  fecha_inscripcion timestamp
  puntaje_obtenido int
  posicion_final int
}

Ref: jugadores.equipo_id > equipos.id
Ref: torneos.organizador_id > organizadores.id
Ref: inscripciones.jugador_id > jugadores.id
Ref: inscripciones.torneo_id > torneos.id