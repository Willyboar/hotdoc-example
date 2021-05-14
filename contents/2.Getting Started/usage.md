Once you have hotdoc installed you can create a new documentation site by type:

    hotdoc new your_site_name

This will create a directory that contains:

 - An empty "contents" directory
 - A hotdoc.nim file
 
 Hotdoc scans contents dir and creates a category for every folder. For every markdown file inside this folders creates a section and prints content as html.

When you are finished type:

    hotdoc build

inside your documentation folder. 

This will create a docs folder containing your documentation site. 

Everytime you are adding categories or files on contents folder run build and your site will be updated.