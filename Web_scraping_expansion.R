

# Tutorial de ayuda
# # https://www.youtube.com/watch?v=GnpJujF9dBw


rm(list=ls())

library(tidyverse)
library(RSelenium)
library(rvest)
library(netstat) # sirve para la funcion free_port
library(data.table)
library(wdman)

# google chrome: - estructura para correr
remote_driver <- rsDriver(browser = "chrome",
                          chromever = "114.0.5735.90",   # revisar la version de chrome y actualizar la paqeteria
                          verbose = F,
                          port = free_port())

# client make it an object
remDr <- remote_driver$client

remDr$open()  # open the page


# 2014 --------------------------------------------------------------------


# Navegar en la pagina
remDr$navigate("https://web.archive.org/web/20160401010326/http://expansion.mx/rankings/2016/03/11/las-500-empresas-mas-importantes-de-mexico-2014")

# Ubicamos la tabla:
data_table <- remDr$findElement(using = 'xpath', '//*[@class="table-area"]')


# Put the information in a data table format:
data_table_html <- data_table$getPageSource()   # Complete html code from the data table
page <- read_html(data_table_html %>% unlist())
df1 <- html_table(page)                         # Veo cuantas tablas existen
df <- html_table(page)[[7]]                     # elijo la que necesito como data-frame

# DATAFRAME COMPLETO:
df



# 2015 --------------------------------------------------------------------

# Navegar en la pagina
remDr$navigate("https://expansion.mx/rankings/2018/07/12/las-500-empresas-mas-importantes-de-mexico-de-expansion-2015")


# Ubicamos la tabla con su id
data_table <- remDr$findElement(using = 'id', 'dyntable')


# LOOP CON BREAK ------------------------------------------------

# eL BOTON NEXT NO MARCA ERROR, POR LO TANTO, SOLUCIONO CON DUPLICIDAD:
# Verificar la duplicación:
# Si la última página es la misma que la página anterior 
# (es decir, los datos no cambian después de hacer clic en "Next"), 
# puedes romper el bucle. Por ejemplo, puedes verificar si el df actual es 
# idéntico al df anterior.

all_data <- data.frame()      # empty dataset
cond <- TRUE
prev_df <- data.frame()  # Almacenará el df de la iteración anterior

while (cond == TRUE) {
  # Extraer la info de la pagina
  data_table_html <- data_table$getPageSource()   # Complete html code from the data table
  page <- read_html(data_table_html %>% unlist())
  df <- html_table(page)[[1]]
  
  # Convertir todas las columnas a caracteres para asegurar la compatibilidad
  df[] <- lapply(df, as.character)
  
  # Si el df actual es igual al df anterior, romper el bucle
  if (identical(df, prev_df)) {
    print("script complete")          # Avisa que termino el loop
    break
  }
  
  all_data <- bind_rows(all_data, df)
  
  # Guardar el df actual como prev_df para la siguiente iteración
  prev_df <- df
  
  # No abrumar el servidor al cambiar de página
  Sys.sleep(.2)
  
  # Pruebas de error por botón de next
  tryCatch(
    {
      # Ubicacion y seleccion del boton next
      next_button <- remDr$findElement(using = 'xpath', '//a[@aria-label="Next"]')
      
      next_button$clickElement()
    },
    # En caso de error:
    error = function(e) {
      print("script complete due to an error")
      cond <<- FALSE
    }
  )
}

# DATAFRAME COMPLETO:
all_data


# 2018 --------------------------------------------------------------------

# Navegar en la pagina
remDr$navigate("https://expansion.mx/empresas/2018/08/03/ranking-2018-las-empresas-mas-importantes-de-mexico")


# Ubicamos la tabla con su id
data_table <- remDr$findElement(using = 'id', 'dyntable')


# LOOP:
all_data_1 <- data.frame()      # empty dataset
cond <- TRUE
prev_df <- data.frame()  # Almacenará el df de la iteración anterior

while (cond == TRUE) {
  # Extraer la info de la pagina
  data_table_html <- data_table$getPageSource()   # Complete html code from the data table
  page <- read_html(data_table_html %>% unlist())
  df <- html_table(page)[[1]]
  
  # Convertir todas las columnas a caracteres para asegurar la compatibilidad
  df[] <- lapply(df, as.character)
  
  # Si el df actual es igual al df anterior, romper el bucle
  if (identical(df, prev_df)) {
    print("script complete")
    break
  }
  
  all_data_1 <- bind_rows(all_data_1, df) # acumulando todos los datos de todas las páginas en el dataframe all_data_1.
  
  # Guardar el df actual como prev_df para la siguiente iteración
  prev_df <- df
  
  # No abrumar el servidor al cambiar de página
  Sys.sleep(.2)
  
  # Pruebas de error por botón de next
  tryCatch(
    {
      # Botón
      next_button <- remDr$findElement(using = 'xpath', '//a[@aria-label="Next"]')
      
      next_button$clickElement()
    },
    # En caso de error:
    error = function(e) {
      print("script complete due to an error")
      cond <<- FALSE
    }
  )
}

# DATAFRAME COMPLETO:
all_data_1


