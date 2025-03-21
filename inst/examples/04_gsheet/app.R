# https://stackoverflow.com/questions/63535190/connect-to-googlesheets-via-shiny-in-r-with-googlesheets4
# shiny::runApp(system.file("examples/04_gsheet", package="shiny.gems"))

library(shiny)
library(bslib)
library(googlesheets4)
library(data.table)
library(ggplot2)
library(forecast)

# UI Definition
ui <- page_navbar(
  title = "Weight Tracker",
  nav_panel(
	"Hinzuf\u00fcgen",
    textInput("weight", "Gewicht (kg):", ""),
    actionButton("add_btn", "Eintrag hinzufügen")
  ),
  nav_panel(
    "Diagramm",
    plotOutput("weight_plot")
  ),
  nav_item(a("GSheets",	href="https://docs.google.com/spreadsheets/d/1syvEs3_W43k2bSKq0uOMGC1lKMIjBjUDCrsx80xrlMo"))
)
	
# Server Definition
server <- function(input, output, session) {
  # Authentifizierung beim Start mit googlesheets4
  gs4_auth(cache = ".secrets", email = TRUE)  # Cache für Token, E-Mail für interaktive Auswahl
  
  # Reaktive Werte
  values <- reactiveValues(sheet_id = "1syvEs3_W43k2bSKq0uOMGC1lKMIjBjUDCrsx80xrlMo", data = NULL)
  
  # Initialisierung der Google Sheet
  observe({
    # Authentifizierung prüfen (wird durch gs4_auth() implizit gehandhabt)
    if (is.null(values$sheet_id)) {
      sheet <- gs4_create(
        name = paste0("Weight_Tracker_", Sys.time()),
        sheets = list(data = data.table(timestamp = character(), weight = numeric()))
      )
      values$sheet_id <- as.character(sheet)
    }
    
    # Daten laden
    values$data <- as.data.table(
      read_sheet(values$sheet_id, sheet = "data")
    )
  })
  
  # Daten hinzufügen
  observeEvent(input$add_btn, {
    req(input$weight, values$sheet_id)
    
    # Neue Zeile erstellen
    new_row <- data.table(
      timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      weight = as.numeric(input$weight)
    )
    
    # Daten an Google Sheet anhängen
    sheet_append(
      values$sheet_id,
      new_row,
      sheet = "data"
    )
    
    # Lokale Daten aktualisieren
    values$data <- rbind(values$data, new_row)
    
    # Eingabefeld zurücksetzen
    updateTextInput(session, "weight", value = "")
  })
  
  # Diagramm rendern
  output$weight_plot <- renderPlot({
    req(values$data)
	
	# browser()
    
	x <- data.frame(
		wann=values$data[["timestamp"]],
		zuviel=values$data[["weight"]]-108
	)

	# Create a full daily sequence from min to max date
	# Interpolate weights for all dates
	full_dates <- seq(min(x$wann), max(x$wann), by = "day")  # 20102 to 20147
	interp_weights <- approx(as.numeric(x$wann), x$zuviel, xout = as.numeric(full_dates), method = "linear")$y
	ts_data <- ts(interp_weights, start = as.numeric(min(x$wann)), frequency = 7)

	# Fit exponential smoothing model
	ets_model <- ets(ts_data, model = "AAA", damped = TRUE, alpha = 0.2)
	fitted_values <- fitted(ets_model)

	# Forecast 7 days ahead
	forecast_horizon <- 7
	fc <- forecast(ets_model, h = forecast_horizon)

	# Extend dates for the forecast period
	forecast_dates <- seq(max(x$wann) + 1, by = "day", length.out = forecast_horizon)
	all_dates <- c(full_dates, forecast_dates)

	# Base R plot of the original data (scatter with lines for irregular intervals)
	# Custom date axis
	plot(zuviel ~ wann, data=x, type = "b", pch = 16, col = "blue", lwd = 2,
		 xlab = "Datum", ylab = "kg zuviel", main = "Karstens Gewichtsprojekt",
		 xaxt = "n", xlim = range(all_dates), ylim=c(0, 10))  
	axis(1, at = all_dates, labels = format(all_dates, "%d.%m."), las = 2, cex.axis = 0.7)

	# Add the fitted trend line
	#lines(full_dates, fitted_values, col = "red", lwd = 2, lty = 2)

	# Add vertical grey shading for weekends
	weekend_days <- all_dates[weekdays(all_dates) %in% c("Samstag", "Sonntag")]
	for (day in weekend_days) {
	  rect(day - 0.5, par("usr")[3], day + 0.5, par("usr")[4], 
		   col = rgb(0.5, 0.5, 0.5, 0.2), border = NA)
	}

	# Add the forecast mean (point forecast)
	lines(forecast_dates, fc$mean, col = "red", lwd = 2, lty = 2)

	# Add confidence intervals (80% and 95%)
	polygon(c(forecast_dates, rev(forecast_dates)), 
			c(fc$upper[, "95%"], rev(fc$lower[, "95%"])), 
			col = rgb(1, 0, 0, 0.2), border = NA)
	polygon(c(forecast_dates, rev(forecast_dates)), 
			c(fc$upper[, "80%"], rev(fc$lower[, "80%"])), 
			col = rgb(1, 0, 0, 0.4), border = NA)

	# Add a legend
	legend("bottomleft", legend = c("kg \u00fcber Ziel (108kg)", "Vorhersage", "80% CI", "95% CI"), 
		   col = c("blue", "red", "red", "red"), border=NA, bg = "white", box.col = "black",
		   lty = c(NA, 2, NA, NA), pch = c(16, NA, NA, NA), 
		   lwd = c(NA, 2, NA, NA), 
		   fill = c(NA, NA, rgb(1, 0, 0, 0.4), rgb(1, 0, 0, 0.2)))
  })
  
  # Reactive value that determines the link
  reactive_link <- reactive({
    # Example: Change the link based on some condition
    if (input$some_input == "option1") {
      "https://www.example.com/option1"
    } else {
      "https://www.example.com/option2"
    }
  })

  # Navbar Entry to visit GSheets
  # output$gsheets_link <- renderUI({
    # req(values$sheet_id)
    # sheet_url <- paste0("https://docs.google.com/spreadsheets/d/", values$sheet_id)
	# browser()
    # nav_item(a("GSheets", href = sheet_url))
  # })
}

# App erstellen und mit festem Port starten
app <- shinyApp(ui = ui, server = server)
runApp(app, port = 1221)