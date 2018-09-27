# DHEth

**These cannot be used out of the box at the current stage.** 

These are some queries and scripts linked to the DHEth book project, they are stored here for reference

dheth2fo.xql is a module which assumes a certain collection structure in the exist-db where it is run, and produces a PDF via XSL-FO following the editorial guidelines of Aethiopica. It also assumes a particular configuration for the location of the fonts, which are stored in a separate library.

generateBibliography.xql is used to generate a bibliography.xml file used by the previous script, based on the data and on a specific collection linked to the book. It makes a series of calls to the Zotero API for references formatted according to the HLCES style. The output needs postprocessing because the style includes some italicization which gets escaped in the API responses.  

