TEMPLATE="template.revealjs"
PANDOC_OPTIONS_HTML="--section-divs -t html5 -s --template ${TEMPLATE}"

pandoc ${PANDOC_OPTIONS_HTML} -o $3 $2.md
