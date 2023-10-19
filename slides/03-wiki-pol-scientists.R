library(httr)
library(tidyverse)
library(rvest)
library(pbapply)
library(xml2)

# Download Wikipedia page
myhtml <- read_html("https://en.wikipedia.org/wiki/List_of_political_scientists")

# Select the relevant nodes
myelements <- html_elements(myhtml, "h2+ ul li > a:nth-child(1)")

# Remove last element "Political theorist"
myelements <- myelements[-length(myelements)]

# Remove links that do not point to wikipedia.org
myelements <- myelements[str_detect(html_attr(myelements, "href"), "^\\/wiki")]

# Remove duplicates
myelements <- myelements[!duplicated(html_attr(myelements, "href"))]

# Make dataframe
scientists <- data.frame(link = str_c("https://en.wikipedia.org", html_attr(myelements, "href")),
                         name = html_text(myelements)
                         )

scientists$filename <- str_c("wikipedia/", basename(scientists$link) %>% str_remove_all("\\%"))

# Make folder
dir.create("wikipedia")

# Download individual pages
pbsapply(scientists$link, function (x) if(!file.exists(str_c("wikipedia/", basename(x)  %>% str_remove_all("\\%")))) GET(x) %>% content %>% write_html(file = str_c("wikipedia/", basename(x) %>% str_remove_all("\\%"))))

# Check whether I downloaded all HTMLs
dim(scientists) # Dimensions of my dataframe
list.files("wikipedia") %>% length # Number of downloaded files

# Go through all HTML pages and get a list of links
read_html(scientists$filename[1]) %>% html_nodes("#mw-content-text a") %>% html_attr("href") %>% str_subset("^\\/wiki") %>% str_c("https://en.wikipedia.org", .) %>% list

# Count the number of links to other political scientists on each page
scientists$mentions <- pbsapply(scientists$filename, FUN = function (x) {
  all_links <- read_html(x) %>% html_nodes("p a") %>% html_attr("href") %>% str_subset("^\\/wiki") %>% str_c("https://en.wikipedia.org", .) %>% list
  all_links <- all_links[[1]]
  all_links[all_links %in% scientists$link] %>% length
  })


table(scientists$mentions)





############## NETWORK

# install.packages(c("visNetwork", "geomnet", "igraph"))
library(visNetwork)
library(geomnet)
library(igraph)

install.packages("geomnet")

# Subset only to pages with many mentions
scientists$mentions[scientists$mentions > 2] %>% length
famous_scientists <- filter(scientists, mentions > 2)
famous_scientists$id <- 1:nrow(famous_scientists) # Add id var


# Edges
edges <- data.frame(from = famous_scientists$id)
edges$to <- pbsapply(edges$from, FUN = function (x) {
  all_links <- (read_html(famous_scientists$link[famous_scientists$id == x]) %>% html_nodes("#mw-content-text a") %>% html_attr("href") %>% str_subset("^\\/wiki") %>% str_c("https://en.wikipedia.org", .) %>% list)[[1]]
  famous_scientists$id[famous_scientists$link %in% all_links]
}) 
edges <- edges %>% unnest(cols = c("to")) %>% as.data.frame()
edges$width <- 1

#Create graph for Louvain
graph <- graph_from_data_frame(edges, directed = FALSE)

#Louvain Comunity Detection
cluster <- cluster_louvain(graph)

cluster_df <- data.frame(as.list(membership(cluster)))
cluster_df <- as.data.frame(t(cluster_df))
cluster_df$label <- rownames(cluster_df) %>% str_remove("X") %>% as.numeric

#Create group column
nodes <- select(famous_scientists, c("link", "name", "id"))
nodes$label <- nodes$id # %>% str_replace_all("/", "\\.")
nodes <- left_join(nodes, cluster_df, by = "label")
colnames(nodes)[5] <- "group"

# Add name as label
nodes$label <- nodes$name

# Show graph
visNetwork(nodes, edges)

