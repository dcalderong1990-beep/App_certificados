# AGENTS.md

## Contexto del proyecto
Somos Academia Horizonte, un centro de formación que imparte
programas técnicos a empresas. Al cerrar cada cohorte emitimos
certificados por estudiante. Hoy el proceso es manual en Excel
y Word; vamos a automatizarlo como una APLICACIÓN WEB.

## Arquitectura (3 piezas)
- Bodega (datos): los Excel en `insumos/`. NO se modifican.
- Cocina (backend): Python con Flask, en `app.py`.
  Toda la lógica va aquí, NUNCA en la interfaz.
- Salón (frontend): páginas web HTML servidas por Flask.
  Solo muestra información; no calcula ni decide.

## Archivos de entrada
- `insumos/Maestro_Estudiantes.xlsx`: lista oficial de estudiantes
  (Identificacion, Nombre_Completo, Correo, Programa, Cohorte).
  Hoja real: `Estudiantes 1` (24 estudiantes).
- `insumos/Registro_Evaluaciones (1).xlsx` (el archivo real lleva
  sufijo `(1)`): notas (0-100) y asistencia por módulo
  (Identificacion, Programa, Modulo, Nota, Asistencia_Pct, Fecha_Cierre).
  Hoja real: `Evaluaciones 1` (88 registros).

## Reglas de negocio
IMPORTANTE: Promedio = suma de Notas / cantidad de módulos cursados.
Asistencia = promedio de Asistencia_Pct.
IMPORTANTE: Se agrupa por Identificacion + Programa. Un certificado
por estudiante y programa.
IMPORTANTE: Aprobación si Promedio >= 70 y Asistencia >= 80.
Participación si Promedio < 70 y Asistencia >= 80.
Sin certificado si Asistencia < 80. Los límites INCLUYEN el valor.

## Estilo de trabajo
- Código simple y comentado en español, señalando dónde están
  los ladrillos: variables, tipos, condicionales, bucles y funciones.
- Diseño web en azul marino y dorado.
- Explícame en español sencillo lo que vayas haciendo.

## Repository state
- App web implementada en `app.py` (Flask) con templates en `templates/` y estilos en `static/css/styles.css`.
- Dependencias en `requirements.txt` (`Flask`, `openpyxl`, `waitress`); arranque con `iniciar_app.bat` o `python app.py`.
- Los insumos siguen en `insumos/` en modo solo lectura; salida futura en `certificados/`.
- No hay pruebas automatizadas todavía.

## Tooling / environment
- Python 3.14 + Flask/openpyxl/waitress instalados; no `node`, `npm` ni `git`.
- Desarrollo: `python app.py` o doble clic en `iniciar_app.bat`; abrir `http://localhost:5000/`. Detener con Ctrl+C en la consola.
- Produccion: Waitress (configurar despues si se despliega).
- No hay suite automatizada todavia; verificar manualmente contadores y tabla.
- The Excel files were generated with openpyxl and store text as inline strings (`t="inlineStr"`); do not assume shared-string tables when parsing.
- Parse `.xlsx` with the standard library (`zipfile` + `xml.etree.ElementTree`) if needed; quote paths because of spaces/parentheses.

## Decisiones técnicas
- Backend: Python 3.14 + Flask; toda la lógica en `app.py`.
- Lectura oficial de Excel: openpyxl; codificación UTF-8.
- Servidor de producción recomendado: Waitress (Windows). Desarrollo con servidor de Flask.
- No usar pandas en la primera versión; lógica sobre estructuras Python simples.
- No usar JavaScript para cálculos ni decisiones; solo presentación.
- Plantillas HTML servidas por Flask con Jinja2.
- Insumos en `insumos/` son read-only. Salidas en `certificados/`.
- Validación de cruces antes de certificar: maestro vs evaluaciones por `Identificacion + Programa`.
- Reglas de negocio: promedio por módulos cursados; asistencia promedio; umbrales inclusivos (`>= 70`, `>= 80`); Aprobación/Participación/Sin certificado.
- Interfaz: azul marino y dorado.
- Plan de implementación detallado en `PLAN.md`.