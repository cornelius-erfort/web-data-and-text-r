# 04-regex notes


mp_info[1] %>% as.character()

mp_dd <- html_elements(mp_info, "dd, dt")

nrow(members)

length(mp_dd)

html_text2(mp_dd)

html_text2(mp_dd) == "Party"

table(html_text2(mp_dd) == "Party")

which(html_text2(mp_dd) == "Party")