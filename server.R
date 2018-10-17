
# Server


bins <- c(0, 500, 1000, 1500, 2000, 3000, 4000, 5000, 6000, 8000, Inf)

pal <- colorBin("Blues", domain = nyzip$n, bins = bins)
labels <- sprintf("<strong>%s</strong><strong>%s</strong><strong>%s</strong><br/>%g requests",
                  nyzip$po_name,":", nyzip$zip, nyzip$n ) %>%
          lapply(htmltools::HTML)


function(input, output, session){

  # background map and zoom-in focal location
  output$MapNY <- renderLeaflet({
    leaflet() %>% 
      setView(lng = -73.888, lat = 40.742054, zoom = 11) %>%
      addProviderTiles(providers$Stamen.TonerLite) 
                  })
  
  # polygons by zip code
  leafletProxy('MapNY') %>%
    addPolygons(data = nyzip, weight = 2, opacity = 1, fillOpacity = 0.7,
                fillColor = ~pal(nyzip$n),
                color = "white",
                dashArray = "3",
                highlight = highlightOptions(weight = 5, 
                                             color = "#666", 
                                             dashArray = "",
                                             fillOpacity = 0.7,
                                             bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),
                                                          textsize = "15px",
                                                          direction = "auto")
    ) %>%
    
    clearControls() %>%
    
    addLegend(
      "bottomleft", pal = pal, values = nyzip$n,
      title = 'Volume',
      opacity = 1)
  

    # Annual plot
    output$timemonthly = renderPlotly({
     
        clean = request_yearly %>%
          filter(incident_zip %in% input$zipcode) %>%
          mutate(month = month(created_date)) %>%
          group_by(month) %>% 
          summarize(n = n()) %>%
          ungroup() -> clean
 
        plot_ly(data= clean,
                x = ~ month, y = ~ n, type = 'bar',
                marker = list(color = 'rgb(48, 189, 186)')) %>%
          layout(xaxis = list(title = "", tickangle = -45),
                 yaxis = list(title = ""),
                 title = 'Monthly Fluctuation',
                 margin = list(b = 50),
                 barmode = 'group')
                 
    })
    
      # Daily plot
      output$timehourly = renderPlotly({
        
        clean2 = request_daily %>%
          filter(incident_zip %in% input$zipcode) %>%
          mutate(hour = hour(created_date)) %>%
          group_by(hour) %>% 
          summarize(n = n()) %>%
          ungroup() -> clean2
          
          plot_ly(data = clean2,
                  x = ~ hour, y = ~ n, type = 'bar',
                  marker = list(color = 'rgb(48, 189, 186)')) %>%
          layout(xaxis = list(title = "", tickangle = -45),
                 yaxis = list(title = ""),
                 title = 'Hourly Fluctuation',
                 margin = list(b = 50),
                 barmode = 'group')
      })
      
      # Word cloud
      output$complaints = renderPlot({
        
        complaint1 <- request_yearly %>% 
          filter(incident_zip == input$zipcode) %>% 
          select(complaint_type, descriptor)
        
        complaint1 = Corpus(VectorSource(complaint1))
        toSpace = content_transformer(function(x,pattern) gsub(pattern, " ", x))
        
        complaint1 = tm_map(complaint1, toSpace, "/")
        complaint1 = tm_map(complaint1, toSpace, "\\|")
        complaint1 = tm_map(complaint1, toSpace, "-")     
        
        complaint1 = tm_map(complaint1, content_transformer(tolower))
        complaint1 = tm_map(complaint1, removeNumbers)
        complaint1 = tm_map(complaint1, removeWords, stopwords('english'))
        complaint1 = tm_map(complaint1, removePunctuation)
        complaint1 = tm_map(complaint1, stripWhitespace)
        
        dtm = TermDocumentMatrix(complaint1)
        m = as.matrix(dtm)
        v = sort(rowSums(m), decreasing = TRUE)
        d = data.frame(word = names(v), freq=v)
        
        wordcloud(d$word, freq = d$freq, scale = c(4, 0.5), min.freq = 1, 
                  random.order = FALSE, 
                  rot.per = 0.5,
                  max.words = 300,
                  colors = brewer.pal(10, "Dark2"))
        
      })

  
  
}

