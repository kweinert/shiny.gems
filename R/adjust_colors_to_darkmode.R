#' Adjust colors based on lightness
#'
#' We may change the colors when entering dark mode. If the color is too dark, we make it a bit lighter. If the color is bright, we make it a bit darker. 
#' We use L from the HCL colorspace to determine the lightness/darkness.
#' We use the colorspace::lighten function. 
#'
#' @param colors, character vector of colors, e.g. hex codes
#' @param threshold, numeric, if the L is below the first value, it gets lightened, if above the second value, it gets darkened. It's possible to pass one value only.
#' @param amount, numeric, how much lighter/darker. Default 0.15
#' @return a character of the same length as colors with the (potentially) modified values.
#' @export
adjust_colors_to_darkmode <- function(colors, threshold = c(30,70), amount = 0.20) {
  if(length(threshold)==1) threshold <- c(threshold,threshold)
  
  hcl_colors <- colors |> colorspace::hex2RGB() |> as("polarLUV")
  lightness <- colorspace::coords(hcl_colors)[, "L"] 
  
  ifelse(lightness < threshold[1], 
	colorspace::lighten(colors, amount = amount, space = "HCL"),
  ifelse(lightness > threshold[2], 
    colorspace::darken(colors, amount = amount, space = "HCL"), 
    colors
  ))
}
