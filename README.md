# 🎮 MNG Tournament - eSports Platform Core Architecture Documentation

Este repositorio contiene el diseño, la implementación física y los mecanismos de validación para la capa de persistencia y la interfaz de programación de aplicaciones (API) de **MNG Tournament**, un ecosistema de software orientado a la gestión y automatización de torneos competitivos de eSports. 

La solución adopta un enfoque arquitectónico moderno de **Backend-as-a-Service (BaaS)**, delegando la infraestructura cloud a servicios administrados y exponiendo de manera síncrona una API REST robusta que interactúa directamente con un motor relacional normalizado. El objetivo de este componente es asegurar que cualquier cliente de software externo (interfaces web o aplicaciones móviles) pueda consultar y modificar el estado del negocio de manera segura, óptima y concurrente.

---

## 🛠️ Fundamentos y Justificación de la Arquitectura Tecnológica

La elección de la pila tecnológica se fundamenta en los principios de ingeniería de software: desacoplamiento, alta disponibilidad, consistencia de datos y eficiencia en el ciclo de desarrollo. A continuación, se presenta un desglose exhaustivo de los tres pilares de esta infraestructura.

### 1. Capa de Almacenamiento y Persistencia: PostgreSQL
PostgreSQL es un sistema de gestión de bases de datos relacionales (RDBMS) de código abierto y objeto-relacional. Dentro de este sistema, funge como el núcleo de persistencia definitivo, encargado de estructurar y asegurar cada fragmento de información del negocio.

* **Mecanismo de Operación Detallado:** La información de los torneos, jugadores y organizadores se modela a través de entidades físicas bidimensionales (tablas). PostgreSQL hace uso estricto del Lenguaje de Definición de Datos (DDL) para compilar esquemas relacionales gobernados por restricciones lógicas (*constraints*). Estas incluyen llaves primarias (`PRIMARY KEY`) para la identificación inequívoca, llaves foráneas (`FOREIGN KEY`) acopladas a reglas referenciales (`ON DELETE CASCADE`, `ON UPDATE CASCADE`), y restricciones de unicidad (`UNIQUE`) a nivel de atributos individuales o compuestos.
* **Justificación de Ingeniería:** El sistema garantiza el cumplimiento riguroso de las propiedades **ACID** (Atomicidad, Consistencia, Aislamiento y Durabilidad). En un entorno competitivo de eSports, la concurrencia es crítica; PostgreSQL evita estados de carrera (*race conditions*) y fenómenos de corrupción de datos. Por ejemplo, mediante el aislamiento de transacciones, impide que un jugador se inscriba simultáneamente en un torneo que ya alcanzó su capacidad máxima (`max_participants`), y rechaza de manera nativa cualquier registro huérfano (vía restricciones de llave foránea), asegurando que un torneo esté ligado obligatoriamente a un organizador real y vigente.

### 2. Infraestructura Cloud y Capa Intermedia: Supabase (BaaS)
Supabase es una plataforma Backend-as-a-Service (BaaS) diseñada para acelerar la construcción de aplicaciones cloud sin sacrificar el poder de las bases de datos relacionales, operando como un entorno completamente administrado en la nube.

* **Mecanismo de Operación Detallado:** Supabase no actúa como una abstracción ni reemplaza al RDBMS; en su lugar, aprovisiona un contenedor dedicado que ejecuta una instancia nativa y completa de PostgreSQL. La innovación clave de su arquitectura radica en la integración de **PostgREST**, un servidor web especializado que se comunica directamente con el catálogo de PostgreSQL. PostgREST inspecciona de forma dinámica el esquema de nuestras tablas físicas y, de manera automática, mapea la base de datos a una API REST estructurada, segura y escalable, exponiendo de inmediato rutas de acceso de red (endpoints) para realizar operaciones CRUD sobre los recursos.
* **Justificación de Ingeniería:** Adopta el paradigma de desarrollo ágil al suprimir la necesidad de construir, probar y desplegar un software de backend o capa intermedia manual utilizando lenguajes tradicionales (como Node.js, Express, Java o Python) cuyo único propósito sea actuar como puente de datos. Además de la API instantánea, Supabase proporciona capacidades críticas de infraestructura: un editor SQL avanzado basado en web, utilidades de diagnóstico, abstracciones para el manejo de almacenamiento de objetos binarios (logos de equipos), y un panel centralizado para gestionar políticas de control de accesos a nivel de red y bases de datos.

### 3. Entorno de Diagnóstico y API Testing: Postman
Postman es una plataforma colaborativa y un entorno de software especializado en el diseño, simulación, testeo y consumo de interfaces de programación de aplicaciones (APIs). Actúa de manera aislada como el cliente HTTP de caja negra para auditar la infraestructura en la nube.

* **Mecanismo de Operación Detallado:** Proporciona una interfaz gráfica estructurada que permite a los ingenieros de software construir paquetes de peticiones de red emulando con exactitud el comportamiento de un cliente en producción. Postman gestiona la especificación de los métodos del protocolo HTTP (verbos como `GET` para la extracción de colecciones, o `POST` para la transferencia e inserción de entidades), la parametrización de variables globales y de entorno (ej. `{{base_url}}`), y la configuración explícita de metadatos en las cabeceras de red (*Headers*), necesarios para superar las capas de seguridad perimetral de la nube.
* **Justificación de Ingeniería:** Facilita la validación funcional de los endpoints antes de iniciar la codificación de la interfaz de usuario. Al despachar una solicitud de red hacia Supabase a través del cliente, Postman intercepta el flujo de respuesta del servidor cloud y renderiza los metadatos de conectividad. Esto permite auditar la latencia de red, verificar el tamaño de los paquetes transmitidos, inspeccionar las cargas útiles (*payloads*) devueltas en formato de intercambio JSON, y validar la semántica de los códigos de estado estándar de la W3C (como `200 OK` para consultas exitosas o `201 Created` para persistencias conformes), garantizando la viabilidad de la arquitectura de extremo a extremo.

---

## 💻 Guía de Despliegue y Ciclo de Pruebas

Para replicar, auditar o levantar este componente de infraestructura desde cero, siga de forma ordenada los procedimientos técnicos descritos a continuación:

### Paso 1: Inicialización Estructural en la Nube (DDL)
1. Acceda a la consola de administración de su proyecto en **Supabase**.
2. Diríjase a la sección **SQL Editor** desde el menú lateral izquierdo.
3. Cree una nueva hoja de trabajo (**New Query**).
4. Copie la estructura lógica de sus tablas (`schema.sql`) y ejecútela presionando el botón **Run**. Esto creará físicamente las entidades, restricciones relacionales e índices B-Tree optimizados en el motor PostgreSQL remoto.

### Paso 2: Configuración de Políticas de Acceso Temporales (RLS)
Por defecto, Supabase activa políticas de seguridad basadas en filas (Row-Level Security) que bloquean la escritura externa para proteger la base de datos. Para entornos de desarrollo y pruebas de laboratorio, se debe desactivar este bloqueo de forma explícita ejecutando las siguientes sentencias en el editor SQL:
```sql
ALTER TABLE organizers DISABLE ROW LEVEL SECURITY;
ALTER TABLE teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE players DISABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments DISABLE ROW LEVEL SECURITY;
ALTER TABLE players_tournaments DISABLE ROW LEVEL SECURITY;
```

### Paso 3: Poblado de Datos de Negocio (DML)

Con las tablas estructuradas y los controles RLS desactivados, proceda a abrir una nueva pestaña en el **SQL Editor** de Supabase. Copie y ejecute el siguiente script para poblar la base de datos con registros iniciales coherentes. Este comando limpia de forma segura cualquier residuo previo y resetea los contadores secuenciales (`SERIAL`) a `1` para garantizar la integridad referencial de las llaves foráneas.

```sql
-- Limpieza en cascada para asegurar consistencia e inicialización coordinada
TRUNCATE TABLE players_tournaments, tournaments, players, teams, organizers RESTART IDENTITY CASCADE;

-- 1. Inserción en tabla maestra: organizers
INSERT INTO organizers (organization_name, email, website, created_id, modified_id) VALUES
('MNG Esports Peru', 'contacto@mng.pe', '[https://mng.pe](https://mng.pe)', 1, 1),
('Arequipa Gaming League', 'contacto@agl.com', '[https://agl.com](https://agl.com)', 1, 1),
('Inca Gaming Tournament', 'info@incagaming.org', '[https://incagaming.org](https://incagaming.org)', 1, 1);

-- 2. Inserción en tabla maestra independiente: teams
INSERT INTO teams (team_name, logo_url, created_id, modified_id) VALUES
('Viper Gaming', '[https://supabase.co/storage/v1/object/public/logos/viper.png](https://supabase.co/storage/v1/object/public/logos/viper.png)', 1, 1),
('Bloodshot Team', '[https://supabase.co/storage/v1/object/public/logos/bloodshot.png](https://supabase.co/storage/v1/object/public/logos/bloodshot.png)', 1, 1),
('Stone Orcs', '[https://supabase.co/storage/v1/object/public/logos/orcs.png](https://supabase.co/storage/v1/object/public/logos/orcs.png)', 1, 1);

-- 3. Inserción en tabla dependiente: players (Llave foránea hacia teams)
INSERT INTO players (gamertag, email, rank, teams_id, created_id, modified_id) VALUES
('Djins_MNG', 'djins@unsa.edu.pe', 'Inmortal', 1, 1, 1),
('XtremePlayer', 'xtreme@gmail.com', 'Diamante', 1, 1, 1),
('ShadowHunter', 'shadow@outlook.com', 'Platino', 2, 1, 1),
('PhoenixRider', 'phoenix@gmail.com', 'Oro', 2, 1, 1),
('GamerPro_99', 'pro99@unsa.edu.pe', 'Bronce', 3, 1, 1);

-- 4. Inserción en tabla dependiente: tournaments (Llave foránea hacia organizers)
INSERT INTO tournaments (organizers_id, game_name, tournament_title, virtual_prize, max_participants, event_date, created_id, modified_id) VALUES
(1, 'Dota 2', 'MNG Copa Inmortal 2026', 'S/. 500 + Trofeo de Oro', 16, '2026-06-15', 1, 1),
(1, 'Valorant', 'MNG Spike Strike', 'Tarjeta Regalo $50', 8, '2026-06-20', 1, 1),
(2, 'League of Legends', 'Arequipa Clausura eSports', '10000 RP + Medalla', 32, '2026-07-05', 1, 1);

-- 5. Inserción en tabla asociativa de quiebre N:M: players_tournaments
INSERT INTO players_tournaments (players_id, tournaments_id, score, final_position, created_id, modified_id) VALUES
(1, 1, 150, 1, 1, 1), 
(2, 1, 120, 2, 1, 1), 
(3, 1, 90, 3, 1, 1),  
(1, 2, 45, NULL, 1, 1),
(4, 2, 80, 1, 1, 1),  
(5, 3, 0, NULL, 1, 1);

```
## 🔗 Enlaces del Proyecto y Recursos de Referencia

Para el seguimiento, revisión del código fuente y auditoría del despliegue cloud, se disponen los accesos principales al ecosistema del proyecto:

* **Repositorio Oficial de GitHub:** [LAB-5-DAW-MNG-TOURNAMENT](https://github.com/diegojoaquin1/LAB-5-DAW-MNG-TOURNAMENT/blob/main/README.md) – Repositorio con el control de versiones, documentación y scripts estructurales del sistema.
* **Consola de Administración Remota:** [Supabase Dashboard - Proyecto MNG](https://supabase.com/dashboard/project/pgyzeobkmefpaljhjnja/editor/17596?schema=public) – Entorno en la nube donde se aloja el esquema físico relacional de PostgreSQL.
* **Video de Demostración Funcional:** [Ver Video Explicativo en YouTube](https://youtu.be/yep8EkI0F2M) – Video con la sustentación del flujo operativo del laboratorio y validaciones con Postman.

---
**Ingeniería de Sistemas - Universidad Nacional de San Agustín (UNSA) © 2026**
