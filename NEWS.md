# phlegis (development version)

-   2021-07-17

    -   Added storage functions and a dataset write functions that allow us to
        write all the data into a DigitalOcean space that can be made publicly
        accessible. We use the `{arrow}` package to provide maximum
        interoperability regardless of the language. We can then provide this to
        anyone as the first dataset of the Philippines data warehouse

-   2021-06-16

    -   We can probably reasonably get all bills inHouse and Senate through
        automated means now. We can also get their history (including dates)
        across the two houses and what eventually becomes RA.

    -   The PDF links that are included also are searchable with full text, so
        doing some text analysis might also be useful.

    -   Added a `NEWS.md` file to track changes to the package.
