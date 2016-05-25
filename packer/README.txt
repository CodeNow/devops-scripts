#### Covert to markdown later

#### Notes

We will start using GDI interrupt mode always


Files:

*.json - packer templates
bin/ - installer executable scripts and wrappers
tmp/ - files ignored by git created on the fly by wrappers / `packer fix`

#### TODO

Jinja2 -> Packer template -> auto-fix -> deploy:

Use a templating language to sub {{ variables }} into the Packer JSON templates, then use packer validate / fix to automatically format the Packer JSON correctly (eg, packer wrapper) and build.
