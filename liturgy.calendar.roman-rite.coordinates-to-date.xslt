<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:strip-space elements="*"/>
    
  <!--xsl:include href="https://github.com/vicmortelmans/BibleConfiguration/raw/master/liturgy.calendar.lib2.xslt"/-->
  <xsl:include href="liturgy.calendar.lib2.xslt"/>    
  <xsl:param name="coordinates" select="'A011'"/>
  <xsl:param name="year" select="'2011'"/>
  <xsl:param name="options" select="'epiphany-alt,corpuschristi-std,ascension-std'"/>
  <xsl:param name="form" select="of"/>

  <xsl:variable name="date"/>
  
  <xsl:template match="liturgicalday[coordinates = $coordinates]">
    <date>
        <xsl:apply-templates select="daterules"/>
    </date>
  </xsl:template>
  
  <xsl:template match="coordinaterules"/>
  <xsl:template match="liturgicalday"/>
</xsl:stylesheet>
