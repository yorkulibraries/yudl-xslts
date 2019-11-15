<xsl:stylesheet version="3.0" xmlns:mods="http://www.loc.gov/mods/v3"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="mods">
<!-- <xsl:output method="xml" indent="yes"/> -->

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

   <!-- 
      FIX: Location/note "note cannot be inside location. workaround put it in holdingSimple." 
      - REDMINE TICKET: Bug #2831 
   -->
   <xsl:template match="/mods:mods/mods:location">
      <xsl:choose>
         <xsl:when test="mods:note" >
            <xsl:copy>
               <xsl:apply-templates select="@*|node()[local-name()!= 'note']"/>
                  <holdingSimple xmlns="http://www.loc.gov/mods/v3">
                     <copyInformation xmlns="http://www.loc.gov/mods/v3">
                        <xsl:apply-templates select="mods:note"/>
                     </copyInformation>
                  </holdingSimple>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>


   <!-- 
      FIX: "... role': Missing child element(s). Expected is roleTerm ..." 
         - REDMINE TICKET: Bug #2833 
   -->
   <xsl:template match="/mods:mods/mods:name/mods:role">
      <xsl:choose>
         <xsl:when test="mods:roleTerm" >
            <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy>
               <roleTerm type="text" xmlns="http://www.loc.gov/mods/v3">
                  <xsl:apply-templates select="@*|node()[local-name()!= 'role']"/>
               </roleTerm>
            </xsl:copy>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- 
      FIX name->roleTerm is invalid . 
      1 - Move roleTerm to name->role->roleTerm 
   -->

   <xsl:template match="/mods:mods/mods:name/mods:roleTerm">
      <role xmlns="http://www.loc.gov/mods/v3">
         <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
         </xsl:copy>
      </role>
   </xsl:template>


   <!-- 
      FIX: "... language': Missing child element(s). Expected is languageTerm ..." 
         - REDMINE TICKET: 2833 
   -->
   <xsl:template match="/mods:mods/mods:language">
      <xsl:choose>
         <xsl:when test="mods:languageTerm" >
            <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy>
               <languageTerm authority="iso639-2b" type="code" xmlns="http://www.loc.gov/mods/v3">
                  <xsl:apply-templates select="@*|node()[local-name()!= 'language']"/>
               </languageTerm>
            </xsl:copy>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>


   <!-- 
      FIX: "... place': Missing child element(s). Expected is placeTerm ..." 
         - REDMINE TICKET: https://redmine.library.yorku.ca/issues/2833 
   -->
   <xsl:template match="/mods:mods/mods:originInfo/mods:place">
      <xsl:choose>
         <xsl:when test="mods:placeTerm" >
            <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy>
               <placeTerm type="text" xmlns="http://www.loc.gov/mods/v3">
                  <xsl:apply-templates select="@*|node()[local-name()!= 'place']"/>
               </placeTerm>
            </xsl:copy>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- 
      FIX physical description invalid errors. 
         - REDMINE TICKETS: #3129
         - Physical Description cannot have text and should be in children (extent, form etc).

   <xsl:template match="/mods:mods/mods:physicalDescription/text()">
      <extent xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="." /></extent>
   </xsl:template>
   -->
   <xsl:template match="/mods:mods/mods:physicalDescription">
      <xsl:variable name="physicalDescriptionText" select="/mods:mods/mods:physicalDescription/text()" />
      <xsl:choose>
         <xsl:when test="text()[normalize-space()] != ''">
            <physicalDescription xmlns="http://www.loc.gov/mods/v3">
               <extent xmlns="http://www.loc.gov/mods/v3">
                     <xsl:value-of select="/mods:mods/mods:physicalDescription/text()[normalize-space()]" />
               </extent>
               <xsl:apply-templates select="node()[local-name() != 'extent']" />
            </physicalDescription>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy>
               <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
         </xsl:otherwise>

      </xsl:choose>
  </xsl:template>
    <!-- FIX physicalDescription has text in it, fixed above, this is clean up -->
    <xsl:template match="/mods:mods/mods:physicalDescription/text()" />


   <!-- 
      FIX physical location invalid errors. 
         - REDMINE TICKETS: #3130 
         - Physical location cannot exist with out location parent.
   -->
   <xsl:template match="/mods:mods/mods:physicalLocation">
      <location xmlns="http://www.loc.gov/mods/v3">
         <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
         </xsl:copy>
      </location>
   </xsl:template>

   <!-- 
      FIX: duplicate location nested inside another location. 
         - REDMINE TICKET: #3131 
         - Case 1: RelatedItem location->location->url not valid. Remove parent location, keep rest 
         - Case 2: one file had nested location->url and also url and another has only nested location->url. 
         - Case 3: relatedItem has invalid attribute type="related". 
         - eg. files: yul_88164_MODS.xml and yul_96303_MODS.xml  or yul_99419_MODS.xml 
    -->

   <xsl:template match="/mods:mods/mods:relatedItem">
      <xsl:choose>
         <!-- Case 1: When location->location is the only child. Remove location, extract url and add that as the child -->
         <xsl:when test="/mods:mods/mods:relatedItem/mods:location/mods:location[count(preceding-sibling::*)+count(following-sibling::*)=0]">
            <xsl:copy>
               <xsl:apply-templates select="@*|node()[local-name() != 'location']"/>
               <location xmlns="http://www.loc.gov/mods/v3">
                  <xsl:apply-templates select="/mods:mods/mods:relatedItem/mods:location/mods:location/mods:url" />
               </location>
            </xsl:copy>
         </xsl:when>
         <!-- Case 2: There is already a url child and nested location with url as well. In which case, nuke the nested location -->
         <xsl:when test="/mods:mods/mods:relatedItem/mods:location/mods:location[count(preceding-sibling::*)+count(following-sibling::*) != 0]">
            <!-- copy relatedItem -->
            <xsl:copy>
               <xsl:apply-templates select="@*|node()[local-name() != 'location']"/>
               <xsl:apply-templates select="mods:location/mods:location"/>
            </xsl:copy>
         </xsl:when>
         <!-- Case 3: -->
         <xsl:when test="/mods:mods/mods:relatedItem[@type ='related']">
            <relatedItem xmlns="http://www.loc.gov/mods/v3">
               <xsl:apply-templates select="node()"/>
            </relatedItem>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy>
               <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- 
      FIX titleInfo errors. REDMINE TICKETS: #3128, RELATED: #2831, #1958/59 
      - title with display attribute is invalid. Moved it out as a note.
      - title with supplied attribute is invalid. Moved it out as a note.
      - titleInfo has a note node, is invalid. Move it outside of titleInfo.
   -->
   <xsl:template match="/mods:mods/mods:titleInfo">
      <xsl:for-each select=".">
         <xsl:choose>
         <!-- displayLabel is not valid title attribute, convert it to note -->
            <xsl:when test="mods:title[@displayLabel]">
               <xsl:copy>
                  <xsl:apply-templates select="@*|node()[not(@displayLabel)]" />
               </xsl:copy>
               <note xmlns="http://www.loc.gov/mods/v3">
                  <xsl:attribute name="displayLabel"><xsl:apply-templates select="mods:title/@displayLabel" /></xsl:attribute>
                  <xsl:apply-templates select="mods:title[@displayLabel]/node()" />
               </note>
            </xsl:when>
            <!-- title supplied="yes" was added via a processing but its invalid mods v3 -->
            <xsl:when test="mods:title[@supplied]">
               <xsl:copy>
                  <xsl:apply-templates select="@*|node()[not(@supplied)]" />
               </xsl:copy>
               <titleInfo xmlns="http://www.loc.gov/mods/v3">
                  <xsl:attribute name="supplied"><xsl:apply-templates select="mods:title/@supplied" /></xsl:attribute>
                     <title xmlns="http://www.loc.gov/mods/v3">
                        <xsl:apply-templates select="mods:title[@supplied]/node()" />
                     </title>
               </titleInfo>
            </xsl:when>
            <!-- titleInfo has a note node, is invalid. Move it outside of titleInfo with attribute 'Title note' -->
            <xsl:when test="mods:note">
               <xsl:copy>
                  <xsl:apply-templates select="@*|node()[local-name()!= 'note']"/>
               </xsl:copy>
               <note xmlns="http://www.loc.gov/mods/v3">
                  <xsl:attribute name="displayLabel">Title note</xsl:attribute>
                  <xsl:apply-templates select="./mods:note/node()" />
               </note>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy>
                  <xsl:apply-templates select="@*|node()"/>
               </xsl:copy>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>


   <!-- FIX: subject/cartographics/note: "note cannot be inside cartographics. workaround put note outside subject." -->
   <!-- REDMINE TICKET: Bug #2832 -->
   <xsl:template match="/mods:mods/mods:subject">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()[local-name()!= 'note']"/>
      </xsl:copy>
      <xsl:if test="./mods:cartographics/mods:note">
         <xsl:copy-of select="/mods:mods/mods:subject/mods:cartographics/mods:note" />
      </xsl:if>
   </xsl:template>
   <xsl:template match="/mods:mods/mods:subject/mods:cartographics/mods:note" />


   <!-- 
      Fix: RelatedItem type="related" not valid. Remove type=related, keep rest 
    <xsl:template match="mods:relatedItem[@type = 'related']">
        <xsl:copy>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
   </xsl:template>

   -->


</xsl:stylesheet>
