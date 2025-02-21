![r-universe](https://kweinert.r-universe.dev/badges/shiny.gems)

shiny.gems
==========

The `shiny.gems` package showcases some practices and shiny modules that help develop shiny applications. The project is under active development and likely to change.

Installation
------------

The current version can be installed from r-universe using

```
install.packages("shiny.gems", repos="https://kweinert.r-universe.dev")
```

You can install the latest development version of the code from Github using the `devtools` R package. This might be interesting as soon there is a development branch.

```
# Install devtools, if you haven't already.
install.packages("devtools")

library(devtools)
install_github("kweinert/shiny.gems")
```

In the context of `shinylive`, the r-universe repository provides a WASM binary. This binary will be downloaded and bundled from `shinylive::export` if the `wasm_packages` is set to `TRUE`.


Getting Started
---------------

#### 01_colormode

```
shiny::runApp(system.file("examples/01_colormode", package="shiny.gems"))
```

The `colormode_ui/srv` shiny module makes use of the `bslib::toggle_dark_mode` function. This example shows how to use the module.




