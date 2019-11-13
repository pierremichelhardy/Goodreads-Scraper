# load packages
library(rvest)
library(tidyverse)
library(readxl)
library(RSelenium)
library(xlsx)

# load datasets
books <- read_excel("Books Work Table.xlsx", sheet=2)
y <- 2:5
i <- 1

# set up 
rD <- rsDriver(browser=c("chrome"), chromever="77.0.3865.40")
driver <- rD$client

# navigate first site
driver$navigate("https://www.goodreads.com/search?utf8=%E2%9C%93&q=Apocrypha%3A+The+Legend+of+BABYMETAL&search_type=books")

# loop starts here
for(i in 1:nrow(books)) {
  tryCatch({
    x <- books[i,1]
    x <- as.character(x)

    # search
    element <- driver$findElement(using = "css","#search_query_main")
    element$clearElement()
    element$sendKeysToElement(list(x))
    element$sendKeysToElement(list(key="enter"))

    # pause
    t <- sample(y, 1)
    Sys.sleep(t)

    # identify first results and take author name
    element <- driver$findElement(using = "css",".authorName")
    author <- element$getElementText()[[1]]

    # log
    books[i,2] <- author

# print status
    print(i)
  }, error=function(e){cat("Whoops", conditionMessage(e),"\n")})
}

write.xlsx(books,"authors provided.xlsx")

################################################

driver$close()

rD$server$stop()
