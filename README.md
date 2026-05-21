# 🎮 MNG Tournament - eSports Platform Relational Database Architecture

Este repositorio contiene la arquitectura de persistencia de datos, el diseño relacional normalizado y los mecanismos de prueba de API para **MNG Tournament**, un sistema empresarial orientado a la gestión automatizada de torneos competitivos de eSports. 

La solución está diseñada bajo un enfoque moderno de Backend-as-a-Service (BaaS), exponiendo una API REST síncrona para que clientes de software externos puedan interactuar con el estado del sistema de manera segura y eficiente.

---

## 🛠️ Justificación de la Arquitectura Tecnológica

Para el desarrollo de este componente de infraestructura, se seleccionó un ecosistema tecnológico basado en la interoperabilidad, la escalabilidad y la optimización de recursos:

### 1. Motor de Base de Datos: PostgreSQL
Se optó por PostgreSQL debido a su robustez académica e industrial como motor relacional (RDBMS). Ofrece soporte nativo para restricciones complejas de integridad, transacciones ACID estrictas, indexación avanzada (B-Tree) y un manejo eficiente de tipos de datos estructurados. Esto garantiza que la lógica de torneos (inscripciones únicas, llaves foráneas en cascada) no sufra de corrupción de datos ante altas tasas de concurrencia.

### 2. Plataforma Cloud: Supabase (BaaS)
Supabase actúa como nuestra capa de infraestructura en la nube. Al estar construido directamente sobre PostgreSQL, elimina la fricción de gestionar servidores, aprovisionar hardware o configurar manualmente un middleware de backend. 
* **PostgREST integrado:** Supabase lee de forma instantánea el esquema de nuestras tablas y genera automáticamente una API REST segura con endpoints listos para consumir, reduciendo el tiempo de desarrollo del backend a cero.

### 3. Herramienta de Testing: Postman
Postman se utiliza como el entorno de desarrollo y validación de las APIs (API Testing Client). Permite simular el comportamiento de una aplicación móvil o web, permitiendo al equipo de ingeniería estructurar peticiones HTTP (`GET`, `POST`, `PUT`, `DELETE`), gestionar cabeceras de seguridad dinámicas (`Bearer Tokens`) y auditar las respuestas del servidor remoto en formatos estandarizados como JSON sin necesidad de escribir código de interfaz pre-temprana.

---

## 📊 Arquitectura Relacional del Sistema

El esquema se encuentra normalizado en Tercera Forma Normal (3FN), mitigando redundancias y garantizando la integridad referencial a través de 5 entidades clave:
