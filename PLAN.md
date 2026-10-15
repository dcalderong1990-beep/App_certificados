# Plan de implementación - App Certificados

Modo Plan: este documento guía el trabajo; no implementa código todavía.

## Etapa 0 - Preparación
**Objetivo:** dejar un entorno reproducible sin tocar los insumos.

**Acciones:**
- Crear `requirements.txt` con Flask, openpyxl y Waitress.
- Definir estructura base de carpetas (`templates/`, `static/css/`, `certificados/`).
- Confirmar que `insumos/` se trata como solo lectura.
- Establecer convención UTF-8 para código, plantillas y salidas.

**Validación:**
- Los insumos siguen intactos (comparar nombres/rutas/tamaños).
- Se puede instalar dependencias en un entorno aislado sin errores.
- No existe código de negocio todavía.

## Etapa 1 - Validación de cruce de datos (primero)
**Objetivo:** detectar anomalías antes de construir la app.

**Acciones:**
- Crear un script de validación separado/imperativo (no forma parte de Flask).
- Leer `Maestro_Estudiantes.xlsx` y `Registro_Evaluaciones (1).xlsx` con openpyxl.
- Validar encabezados exactos, tipos, rangos y celdas vacías.
- Comparar claves `Identificacion + Programa` entre maestro y evaluaciones.
- Reportar:
  - estudiantes del maestro sin evaluaciones;
  - identificaciones de evaluación no presentes en el maestro;
  - diferencias de programa para una misma identificación;
  - cantidad de módulos por estudiante/programa (3 vs 4);
  - promedio de nota y asistencia por grupo;
  - clasificación Aprobación / Participación / Sin certificado.
- Exportar reporte legible en consola o archivo JSON temporal.

**Validación:**
- El script termina sin errores y reporta exactamente las anomalías ya conocidas.
- Conteos esperados: 24 grupos, 20 Aprobación, 3 Participación, 1 Sin certificado.
- Decidir antes de seguir si las identificaciones no registradas en el maestro generan certificado (recomendación: no).
- Ningún archivo en `insumos/` cambia.

## Etapa 2 - Backend Flask en `app.py`
**Objetivo:** centralizar toda la lógica en la cocina (backend).

**Acciones:**
- Crear `app.py` con:
  - lectura controlada de ambos Excel;
  - función central `construir_resultados()` que devuelve la lista de estudiantes/programas con promedios, clasificación y anomalías;
  - rutas iniciales: `/`, `/validacion`, `/estudiante/<identificacion>`, `/api/resultados`;
  - manejo seguro de identificaciones no encontradas o sin evaluaciones;
  - promedios calculados por módulos realmente cursados, no fijo por 4.
- Mantener plantillas consumiendo datos ya calculados; sin cálculos en frontend.
- Agregar pruebas unitarias mínimas para la lógica central.

**Validación:**
- `python -m py_compile app.py` sin errores.
- Servidor inicia y responde 200 en rutas principales.
- `/api/resultados` devuelve los mismos conteos validados en Etapa 1.
- Casos borde muestran mensajes claros sin romper la app.

## Etapa 3 - Generación de certificados
**Objetivo:** automatizar el producto final.

**Acciones:**
- Definir formato de certificado (HTML a PDF, o DOCX/HTML según decisión posterior).
- Generar archivo por `Identificacion + Programa`.
- Guardar salida en `certificados/`, nunca en `insumos/`.
- Incluir datos oficiales del maestro: nombre, correo, programa, cohorte, promedio, asistencia, fecha de cierre.
- Nombrar archivos de forma segura con acentos/espacios.

**Validación:**
- Generar al menos un certificado de Aprobación y uno de Participación.
- Abrir el archivo resultante y verificar datos, fecha, formato y codificación.
- Confirmar que no se modifiquen los Excel originales.

## Etapa 4 - Interfaz web (Salón)
**Objetivo:** mostrar información, no calcular ni decidir.

**Acciones:**
- Crear plantillas Jinja2 con diseño azul marino y dorado.
- Páginas: resumen general, validación/cruces, detalle por estudiante, certificado.
- Tablas, badges de estado y filtros/links basados en datos del backend.
- CSS en `static/css/styles.css`; evitar lógica en JavaScript.

**Validación:**
- Revisar en navegador que toda la información provenga del backend.
- Verificar accents, nombres con espacios/paréntesis y tildes.
- Probar en desktop y móvil (responsive básico).
- Confirmar que no hay cálculos duplicados en frontend.

## Etapa 5 - Pruebas y endurecimiento
**Objetivo:** evitar regresiones con datos reales y nuevos casos.

**Acciones:**
- Pruebas para:
  - lectura robusta de Excel;
  - promedios por módulos cursados;
  - umbrales inclusivos (`>= 70`, `>= 80`);
  - estudiante sin evaluaciones;
  - identificación no registrada;
  - programa con 3 vs 4 módulos;
  - reglas de clasificación.
- Pruebas de rutas Flask y códigos HTTP.
- Checklist manual de certificados generados.

**Validación:**
- Todas las pruebas pasan.
- La app no falla ante los casos borde detectados.
- Los insumos permanecen inmutables.

## Etapa 6 - Ejecución y documentación de uso
**Objetivo:** dejar la app lista para uso por Academia Horizonte.

**Acciones:**
- Actualizar `README`/`AGENTS.md` con comando de ejecución (`python app.py` para desarrollo, Waitress para producción).
- Documentar ubicación de insumos, salida de certificados y reporte de anomalías.
- Probar desde carpeta limpia con las dependencias instaladas.
- Definir rutina de respaldo de `insumos/` antes de procesar nuevas cohortes.

**Validación final (smoke test):**
1. Instalar dependencias.
2. Ejecutar la app.
3. Abrir la página principal.
4. Ver conteos esperados.
5. Generar un certificado de Aprobación y uno de Participación.
6. Verificar que `insumos/` no cambió.

## Regla de desbloqueo
No pasar a la etapa siguiente hasta que la etapa actual cumpla todas sus validaciones. Si aparece un nuevo caso borde, actualizar primero la validación (Etapa 1) antes de tocar backend o interfaz.

---

## Decisiones técnicas para `AGENTS.md`
- Backend en Python 3.14 con Flask.
- Lectura oficial de Excel con openpyxl.
- Servidor de producción recomendado: Waitress (especialmente en Windows).
- No usar pandas en la primera versión; la lógica opera sobre estructuras Python simples.
- No usar JavaScript para cálculos/decisiones; solo presentación.
- Insumos en `insumos/` son read-only.
- Toda la lógica reside en backend, especialmente `app.py`.
- HTML servido por Flask con Jinja2.
- Estilo visual: azul marino y dorado.
- Codificación UTF-8 obligatoria.
- Salida generada en `certificados/`.
- Validación de cruces antes de emitir certificados.
- Reglas de negocio:
  - promedio = suma de notas / módulos cursados;
  - asistencia = promedio de asistencia;
  - agrupación por `Identificacion + Programa`;
  - Aprobación si `Promedio >= 70` y `Asistencia >= 80`;
  - Participación si `Promedio < 70` y `Asistencia >= 80`;
  - sin certificado si `Asistencia < 80`;
  - umbrales inclusivos.