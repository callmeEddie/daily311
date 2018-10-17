
# User Interface

navbarPage(title='311 Requests Spatial Visualization', collapsible = TRUE,
           id='nav',
           #By ZipCode
           tabPanel('By Zip Code',
                    div(class="outer",
                        
                        tags$head(
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                                  ),
                        
                    leafletOutput(outputId = 'MapNY', width='100%', height='100%')),
                    
                    absolutePanel(id = 'controls', 
                                  class = 'panel panel-default', 
                                  fixed = TRUE, 
                                  draggable = TRUE, 
                                  top = 60, left = 'auto', right = 20, bottom = 'auto',
                                  width = 400, height = 'auto',
                                  
                                  fluidRow(column(6, selectInput('zipcode',
                                                                  "Zip Code",
                                                                  listzip$zip)
                                            )
                                  ),
                                  
                                  br(),

                                  plotlyOutput("timemonthly", height=250),
                                  plotlyOutput("timehourly", height=250)
                                  
                    ),
                    
                    absolutePanel(id = 'controls', 
                                  class = 'panel panel-default', 
                                  fixed = TRUE, 
                                  draggable = TRUE, 
                                  top = 10, left = 10, right = 10, bottom = 'auto',
                                  width = 250, height = 'auto',
                                  
                                  fluidRow(
                                  plotOutput('complaints', width = '400px', height = '400px')  
                                  )
                    
                    )
           )
   

)
