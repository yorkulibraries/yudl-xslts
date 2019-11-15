## MODS XSLT README

Files in **/home/nruest/xslt-files/**

### For bulk xml files

1. XSLT: `mods-purifier-ldsi.xsl`
    - Fixes Redmine Tickets: 
    - \#2831 (related: #1958 , #1959), #2832, #2833, #3128, #3129, #3130, #3131

2.    Validator Script: `xml-validator-dir.sh`
    - Input:  /path/to/xml/files-directory 
    - Output: copies files to ./bad-xml/* and ./good-xml/*
     
3. Purifier Script `xml-purifier-dir.sh`
    - Input:  /path/to/bad-xml/files-directory /path/to/xslt/file 
    - Output: copy files to ./cleaned-xml

```
$> git clone https://github.com/yorkulibraries/yudl-xslts.git
$> cd to yudl-xslts
##check to make sure .sh have executable permissions
$> ls -l 
## Validate dumped xml files
$> ./xml-validator-dir.sh /path/to/xml/files-directory 
## Check bad-xml folder if any invalid xml
## Clean them
$> ./xml-purifier-dir.sh /path/to/yudl-xslts/bad-xml /path/to/yudl-xslts/mods-purifier-ldsi.xsl
## Validate cleaned files and note errors. XSLT file may need updating
## Rename/move bad-xml and good-xml folders to something else.
## Run validator again and it will create more bad/good dir. 
$> ./xml-validator-dir.sh /path/to/yudl-xslts/cleaned-xml/
## Check bad-xml folder if any that xslt did not fix.
## See what is the error running single file validator, note the error. 
```
   
   
### For single xml file

**Validate/Checker**

``` xmllint --noout --schema /home/nruest/mods.xsd ./path/to/xml/filename.xml ```

**Purifier / Parser**

``` java -jar /tmp/saxon9he.jar -o:./path/to/output/filename.fixed.xml /path/to/bad-xml/mod-filename.xml mods-purifier-ldsi.xsl ```


