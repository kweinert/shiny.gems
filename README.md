![r-universe](https://r-lib.r-universe.dev/badges/shiny.gems)

shiny.gems
==========

The `shiny.gems` package showcases some practices and shiny modules that help develop shiny applications. The project is under active development and likely to change.

Installation
------------

You can install the latest development version of the code using the devtools R package.

```
# Install devtools, if you haven't already.
install.packages("devtools")

library(devtools)
install_github("kweinert/shiny.gems")
```

In the context of `shinylive`, you can use the r-universe repository soon.


Getting Started
---------------

#### 01_colormode

```
shiny::runApp(system.file("examples/01_colormode", package="shiny.gems"))
```

The `colormode_ui/srv` shiny module makes use of the `bslib::toggle_dark_mode` function. This example shows how to use the module.




