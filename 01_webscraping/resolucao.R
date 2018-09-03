library(tidyverse)
library(rvest)
library(stringr)
library(fs)

# WebScraping 

# 1. Arrumando a url para fazer a requisição

## Jeito 1: utilizando loops (tambem chamado de controladores de fluxo)
u0 <- "http://www.metacritic.com/browse/movies/release-date/coming-soon/date?page="

link <- c()
for(i in 0:10){
  l <- i + 1
  link[l] <- str_c(u0, as.character(i))
}

## Jeito 2: utilizando a funcao map_chr
link <- map_chr(as.character(0:10), ~str_c(u0, .x))

# 2. Fazendo a requisição

## Para ficar mais tranquilo e não depender da internet, iremos baixar os dados antes
for (i in 1:length(link)){
  link[i] %>% read_html() %>% write_html(str_c("data_raw/", as.character(i), ".html"))
}

# 3. Extraindo informações
files <- dir_ls("data_raw/")

obter_table <- function(files){
  node <- files %>% read_html()
  
  tabelas <- node %>% html_table(fill = T)
  
  tabelas <- bind_rows(tabelas[[1]], tabelas[[2]], tabelas[[3]])  
  
  tabelas
}

obter_table <- possibly(obter_table, otherwise = dplyr::tibble(result = "error"))

metacritic <- map_dfr(files, obter_table)

metacritic %>% as.tibble() %>% select(-result)
