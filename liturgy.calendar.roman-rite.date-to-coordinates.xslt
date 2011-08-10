<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    
  <xsl:include href="https://github.com/vicmortelmans/BibleConfiguration/raw/master/liturgy.calendar.lib2.xslt"/>
    
  <xsl:param name="set" select="'Ordinary after Easter'"/>
  <xsl:param name="date" select="'2011/08/09'"/>
  <xsl:param name="epiphany"/>
  <xsl:param name="corpuschristi"/>
  <xsl:param name="ascension"/>
  
  <xsl:variable name="year">
    <xsl:call-template name="liturgical-year">
        <xsl:with-param name="date" select="$date"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:template match="coordinaterules[@set = $set]">
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="coordinaterules"/>
  <xsl:template match="liturgicalday"/>
  
</xsl:stylesheet>