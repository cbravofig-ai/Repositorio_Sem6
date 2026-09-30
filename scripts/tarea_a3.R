# =============================================================================
# A3 — Limpieza de datos reales del INE
#
# Autor: Camila Bravo Figueroa
# Fecha: 29-09-2026
# Descripción: Evalúa la intensidad de la jornada laboral por género, es decir, 
# si existe una brecha significativa entre las horas trabajadas por hombres vs 
# las trabajadas por las mujeres. Para esto, el script limpia y trabaja la base 
# de datos para poder evaluar realmente las jornadas laborales de las personas 
# declaradas como ocupadas. Además, se trabaja con el factor de expansión para 
# proyectar los resultados a la población nacional, permitiendo concluir si existe 
# o no una diferencia en el tiempo efectivamente dedicado al trabajo por género.

# =============================================================================

library(dplyr)
library(tidyr)

# -----------------------------------------------------------------------------
# Paso 1: Pregunta y fuente de datos
# -----------------------------------------------------------------------------

# PREGUNTA DE ANÁLISIS: 
# ¿Existe una brecha significativa en las horas efectivas  de trabajo semanal
# entre hombres y mujeres ocupados en Chile?

# FICHA DE LA FUENTE:
# - Institución: Instituto Nacional de Estadísticas (INE)
# - Encuesta: Encuesta Nacional de Empleo (ENE)
# - Trimestre: Mayo - Julio 2026
# - Enlace de descarga: https://www.ine.gob.cl/estadisticas-por-tema/mercado-laboral/ocupacion-y-desocupacion
# - Fecha de descarga: 29-09-2026
# - Unidad de observación: Persona

# -----------------------------------------------------------------------------
# Paso 2: Apertura y reducción de columnas
# -----------------------------------------------------------------------------

# Se carga el archivo crudo con la función correcta
ene_raw <- read.csv2("data/raw/ene-2026-06-mjj.csv")

# JUSTIFICACIÓN: No se usa read.csv() porque los datos del INE vienen con el 
# separador de columnas de punto y coma (;) y los decimales se separan por coma 
# (,). Si utilizaramos el read.csv R leería los datos como una única columna.

# Se reducen las 222 columnas a las estrictamente necesarias
ene_sub <- ene_raw |>
  select(
    sexo, 
    activ, 
    fact_cal,
    starts_with("efect")
  )

# Se redujo la base a las columnas necesarias para responder la pregunta.Siendo
# estas:
# - sexo: para comparar hombres y mujeres.
# - activ: para filtrar solo a los ocupados.
# - fact_cal: ponderador para expandir a la población nacional.
# - efectivas: para trabajar con las horas efectivamente trabajadas.


# Se comprueba la reducción
dim(ene_sub)

# Efectivamente se redujo el dataframe a un total de 6 columnas, que son las que 
# se necesita para responder mi pregunta.

# -----------------------------------------------------------------------------
# Paso 3: Recodificación a etiquetas legibles
# -----------------------------------------------------------------------------

# JUSTIFICACIÓN: Para responder mi pregunta sobre brechas de género en las 
# horas trabajadas, se necesita agrupar por sexo y ocupados. Para ello, se 
# transforma la etiqueta "1" a "Hombre" y "2" a "Mujer" en la columna sexo, 
# lo mismo con la situación laboral "Ocupado", "Inactivo", etc. De esta manera, 
# será más fácil trabajar con los datos para evitar errores.

ene_clean <- ene_sub |>
  mutate(
    sexo_txt = case_when(
      sexo == 1 ~ "Hombre",
      sexo == 2 ~ "Mujer",
      TRUE      ~ "Error/Desconocido" # Con este TRUE se transforma cualquier 
                                      # valor que no sea 1 o 2, en un error.
    ),
    situacion = case_when(
      activ == 1 ~ "Ocupado",
      activ == 2 ~ "Desocupado",
      activ == 3 ~ "Inactivo",
      TRUE       ~ "Fuera de edad de trabajar" # Con este TRUE, se atrapa a los 
                                               # menores de 15 años que arrojaban 
                                               # error durante el Lab 6.
    )
  )


table(ene_clean$sexo_txt, useNA = "ifany")

table(ene_clean$situacion, useNA = "ifany")

# -----------------------------------------------------------------------------
# Paso 4: Clasificación de faltantes
# -----------------------------------------------------------------------------

# Se cuenta cuántos NAs tiene cada variable que conservamos
colSums(is.na(ene_clean))

# ANALISIS DE FALTANTES:
# - sexo: 0 NA.
# - active: 15.305 NAs, estos son estructurales porque corresponden a los menores 
#           de 15 años que no responden la pregunta.
# - fact_cal: 0 NA.
# - efectivas: 56.096 NAs, también estructurales que son aquellos que son Desocupados,
#              Inactivos y los menores de edad que, como no trabajan, no tienen horas 
#              trabajadas por defecto.


# Se crea una columna falsa reemplazando los NA de "efectivas" con la mediana de 
# horas trabajadas, para ver que ocurre:

prueba_imputacion <- ene_clean |>
  mutate(
    efectivas_falsas = if_else(is.na(efectivas), 
                               median(efectivas, na.rm = TRUE), 
                               efectivas)
  )

table(prueba_imputacion$situacion[is.na(ene_clean$efectivas)])

# La tabla muestra que se le asignaron horas de trabajo a 4.412 "Desocupados2, 15.305 
# "Fuera de la edad de trabajar" y 36.379 "Inactivos". Esto genera un error, puesto que, 
# se les asigna una jornada de trabajo, correspondiente a la mediana de 42 horas, a 
# personas que en realidad no trabajan, inflando la jornada laboral nacional. Por 
# ello, deben excluirse del cálculo en horas efectivamente trabajadas.


# -----------------------------------------------------------------------------
# Paso 5: Caza de códigos centinela en una variable nueva
# -----------------------------------------------------------------------------

# Se filtra sobre 80 horas para ver los datos extremos.
sort(table(ene_clean$efectivas[ene_clean$efectivas > 80]), decreasing = TRUE)

# Se visualizan un total de 103 valores con 888 y 8 valores con 999, que sabemos 
# por el laboratorio que son códigos para respuestas como "No sabe" o "No responde".


# Se aisla solo a los ocupados para ver el impacto real en el promedio.
ocupados_antes <- ene_clean$efectivas[ene_clean$situacion == "Ocupado"]
promedio_antes <- mean(ocupados_antes, na.rm = TRUE)

# Se convierten los centinelas en NA reales.
ene_clean <- ene_clean |>
  mutate(
    efectivas = na_if(efectivas, 999),
    efectivas = na_if(efectivas, 888)
  )

# Promedio después de limpiar
ocupados_despues <- ene_clean$efectivas[ene_clean$situacion == "Ocupado"]
promedio_despues <- mean(ocupados_despues, na.rm = TRUE)


c(Antes = promedio_antes, Despues = promedio_despues)
# El promedio antes de limpiar los centinelas es de 37,7 horas, mientras que luego 
# de limpiar a los centinelas de las horas efectivamente trabajadas, el promedio 
# bajó a 35,5 horas.

# NOTA: A pesar de limpiar los centinelas (888 y 999), se detectó que en la tabla 
# se presentan valores lógicamente poco confiables (140 y 126). Como no son códigos 
# oficiales de la ENE, se deciden no eliminar, pero se declaran para tener en cuenta 
# su efecto sobre los valores finales.

# -----------------------------------------------------------------------------
# Paso 6: Ponderación y cálculo de la brecha de género
# -----------------------------------------------------------------------------

# Se aisla a los ocupados, ya que la pregunta es sobre personas que trabajan
ocupados <- ene_clean |>
  filter(situacion == "Ocupado")

# Cálculo SIN ponderar (asumiendo erróneamente que 1 fila = 1 persona)
resultado_sin_ponderar <- ocupados |>
  group_by(sexo_txt) |>
  summarise(
    filas_muestra = n(),
    promedio_sin_ponderar = mean(efectivas, na.rm = TRUE)
  )

# Cálculo CON ponderador (1 fila = X chilenos representados)
# El promedio ponderado se calcula sumando (horas * fact_cal) y dividiendo 
# por la suma total del factor de expansión.
resultado_ponderado <- ocupados |>
  group_by(sexo_txt) |>
  summarise(
    personas_representadas = sum(fact_cal, na.rm = TRUE),
    promedio_ponderado = sum(efectivas * fact_cal, na.rm = TRUE) / sum(fact_cal, na.rm = TRUE)
  )

resultado_sin_ponderar
resultado_ponderado

# En primer lugar, al utilizar el factor de expansión, las columna "filas_muestra" 
# que corresponde a las observaciones, se transforma al total de personas representadas, 
# lo cual permite evidenciar a cuantas personas corresponden los valores obtenidos.
# Por otro lado, el promedio cambia entre cada resultado, pero no demasiado. Mientras en 
# el resultado sin ponderar los promedios son, para hombres y mujeres respectivamente, 
# 37,7 y 32,7; al ponderar aumentan a 38,5 y 33,5. Un aumento de una hora en cada uno.


# -----------------------------------------------------------------------------
# Paso 7: Respuesta a la pregunta de análisis
# -----------------------------------------------------------------------------
 
# Al calcular el promedio ponderado por el factor de expansión para las horas 
# efectivamente trabajadas por hombres y mujeres en Chile, se obtuvo un promedio 
# de horas efectivamente trabajadas de 38,5 para asociado a los hombres y 33,5 
# asociado a las mujeres, evidenciando una brecha de 5 horas semanales, pudiendo 
# deducirse un total de 1 hora menos al día. 
# Si analizamos esta brecha en un contexto socioeconómico, por lo general, las 
# mujeres están a cargo de cuidar a los hijos, o hacerse cargo del hogar, lo cual
# podría traducirse en una jornada laboral remunerada menor a la del género masculino.

# Una limitación clara en la base de datos es lo declarado en la NOTA en el paso 5,
# puesto que se incluyen jornadas laborales de 140 horas, lo cual significaría trabajar 
# 20 horas diarias toda la semana, misma idea para el total de 126 horas declaradas. 
# Al no ser centinelas de la ENE, se decidió no eliminarlos de la data, sin embargo, 
# pueden estar inflando los promedios de la jornada promedio nacional en hombres y mujeres.


# -----------------------------------------------------------------------------
# Paso 8: Guardado y Bitácora de limpieza
# -----------------------------------------------------------------------------

dir.create("data/processed", showWarnings = FALSE)
write.csv(ene_clean, "data/processed/ene_a3.csv", row.names = FALSE)

# BITÁCORA DE LIMPIEZA

# 1. Lectura: Usé read.csv2() porque el archivo usa separador ";" y coma decimal.
# 2. Variables conservadas: sexo, activ, fact_cal, efectivas.
# 3. Recodificaciones: sexo (a Hombre/Mujer) y activ (Ocupado, Desocupado, etc.) con case_when().
# 4. Faltantes: "activ" y "efectivas" tenían faltantes estructurales. Demostré que imputar la mediana
#    puede ser un error porque asume que niños y desempleados trabajaron.
# 5. Centinelas: Encontré 999 y 888 en "efectivas". Al limpiarlos con na_if(), 
#    el promedio bajó, eliminando la inflación de la jornada.
# 6. Ponderación: Usé fact_cal. El nivel pasó de miles de observaciones en la 
#    muestra a millones de personas, y los promedios subieron ~1 hora para cada sexo.
# 7. Brecha de género en horas efectivamente trabajadas: ~5.
# 8. Filas iniciales: 97.946 -> Filas finales: 97.946.

# =============================================================================
