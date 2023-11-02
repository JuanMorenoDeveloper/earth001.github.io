rm ebook-refactoring.pdf
pandoc -N ebook.md --pdf-engine=latexmk --toc -o ebook-refactoring.pdf
