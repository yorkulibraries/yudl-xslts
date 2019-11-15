## MODS XSLT README

Files in **/home/nruest/xslt-files/**

### For bulk xml files

1. XSLT: mods-purifier-ldsi.xsl
    - Fixes Redmine Tickets: #2831 (related: #1958 , #1959), #2832, #2833, #3128, #3129, #3130, #3131
2.    Validator Script: xml-validator-dir.sh
    - Input:  /path/to/xml/files-directory 
    - Output: copy files to ./bad-xml/* and ./good-xml/*

3. Purifier Script
   - Input:  /path/to/bad-xml/files-directory /path/to/xslt/file 
   - Output: copy files to ./cleaned-xml
   
   
### For single xml file

**Validate/Checker**

``` xmllint --noout --schema /home/nruest/mods.xsd ./path/to/xml/filename.xml ```

**Purifier / Parser**

``` java -jar /tmp/saxon9he.jar -o:./path/to/output/filename.fixed.xml /path/to/bad-xml/mod-filename.xml mods-purifier-ldsi.xsl ```


