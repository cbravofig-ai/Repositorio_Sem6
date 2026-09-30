# A3 - Limpieza de datos reales del INE y Análisis de Brecha de género

Actividad formativa n°3 de la Semana 6, enfocada en la limpieza y procesamiento de 
datos crudos. Toma el archivo original de la Encuesta Nacional de Empleo (ENE), 
identifica faltantes estructurales, limpia códigos centinela y utiliza factores 
de expansión para responder una pregunta de análisis sobre el mercado laboral chileno.

**Pregunta:** ¿Existe una brecha significativa en las horas efectivas de trabajo 
semanal entre hombres y mujeres ocupados en Chile?

**Respuesta:** Sí, existe una brecha en el promedio de horas efectivamente trabajadas 
entre hombres y mujeres. Mientras a los hombres se les asocia un promedio de 38,5 
horas trabajadas, las mujereses tienen asociado un promedio de 33,5 horas trabajadas 
semanalmente, lo cual podría estar asociado a las responsabilidades atribuídas
socialmente a las mujeres.

## Datos

Los datos principales utilizados corresponden a la Encuesta Nacional de Empleo del 
INE (trimestre mayo-julio 2026), junto con su manual de códigos, almacenados en:

`data/raw/ene-2026-06-mjj.csv`

El archivo de la ENE contiene 97.946 observaciones iniciales y 222 variables, 
el cual es reducido y limpiado en el script principal para quedarse únicamente 
con la condición de actividad, sexo, horas efectivamente trabajadas y el factor 
de expansión.

## Cómo correrlo

1. Abrir `Repositorio_Sem6.Rproj`.
2. Abrir el script `scripts/tarea_a3.R`.
3. Ejecutar el script completo desde el inicio.

## Estructura

```text
Repositorio_Sem6/
├── data/
│   ├── processed/
│   │   └── ene_a3.csv
│   └── raw/
│       ├── codigos-ene-2020.pdf
│       ├── ene-2026-06-mjj.csv
│       └── ingresos_wide.csv
├── outputs/
├── scripts/
│   ├── semana6_lab_ene_esqueleto.R
│   ├── semana6_sesion1_guion.R
│   ├── semana6_sesion2_guion.R
│   └── tarea_a3.R
├── .gitattributes
├── .gitignore
├── README.md
└── Repositorio_Sem6.Rproj

```

**Nota**:  El desarrollo de la A3 se encuentra en el script `scripts/tarea_a3.R`.
Cualquier otro archivo dentro de `scripts/` corresponde a material de apoyo utilizado 
durante las sesiones de clase, al igual que los datos procesados en la carpeta 
`data/processed`.

## Autor

Camila Bravo Figueroa — septiembre 2026

## Declaración de autoría y uso de IA
- Herramienta utilizada: Gemini Pro
- Para qué la usé: Para la revisión de la líneas de códigos y para que me ayudara
                   a asociar los códigos del laboratorio con mi pregunta de análisis 
                   para la tarea A3.
- Qué hice yo: Escribí los códigos y sus respectivos comentarios para entender, 
               durante el proceso, a qué parte del análisis tributaba cada línea. 
               Además, cualquier comentario, respuesta, justificación y texto en 
               general, fueron escritos en su totalidad por mí y son de mi autoría.
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.

