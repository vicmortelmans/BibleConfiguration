<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
   
  <xsl:strip-space elements="*"/>
 
  <!--xsl:include href="https://github.com/vicmortelmans/BibleConfiguration/raw/master/liturgy.calendar.lib2.xslt"/-->
  <xsl:include href="liturgy.calendar.lib2.xslt"/>
    
  <xsl:param name="set"/>
  <xsl:param name="date" select="'2011/08/09'"/>
  <xsl:param name="options" select="'epiphany-alt,corpuschristi-std,ascension-std'"/>
  
  <xsl:variable name="year">
    <xsl:call-template name="liturgical-year">
        <xsl:with-param name="date" select="$date"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:template match="/">
    <results>
       <xsl:apply-templates/>
    </results>
  </xsl:template>

  <xsl:template match="coordinaterules[not($set) or @set = $set]">
    <xsl:variable name="start-date" select="concat($year,'-',@start-date)"/>
    <xsl:variable name="stop-date" select="concat($year,'-',@stop-date)"/>
    <xsl:if test="xs:date($start-date) &lt;= xs:date($date) and
                  xs:date($date) &lt;= xs:date($stop-date)">
      <xsl:variable name="coordinates">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:if test="$coordinates != ''">
        <coordinates set="{@set}">
           <xsl:value-of select="$coordinates"/>
        </coordinates>
      </xsl:if>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="coordinaterules"/>
  <xsl:template match="liturgicalday"/>
  
</xsl:stylesheet>
